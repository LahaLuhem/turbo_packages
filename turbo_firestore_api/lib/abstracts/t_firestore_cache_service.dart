import 'dart:async';

import 'package:flutter/material.dart';
import 'package:turbo_firestore_api/dtos/t_cached_query.dart';
import 'package:turbo_firestore_api/extensions/completer_extension.dart';
import 'package:turbo_firestore_api/models/t_firestore_collection.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';
import 'package:turbolytics/turbolytics.dart';

class TFirestoreCache<
  WRITEABLE extends TWriteableId,
  COLLECTION extends TFirestoreCollection<WRITEABLE>
> {
  const TFirestoreCache({
    required TFirestoreCacheService firestoreCacheService,
    required this.collection,
    this.cacheInvalidationTime = const TimeOfDay(hour: 4, minute: 0),
    this.cacheInvalidationDuration,
    this.cacheInvalidationWeekday = DateTime.monday,
  }) : _firestoreCacheService = firestoreCacheService;

  final TFirestoreCacheService _firestoreCacheService;
  final COLLECTION collection;
  final TimeOfDay cacheInvalidationTime;
  final Duration? cacheInvalidationDuration;
  final int cacheInvalidationWeekday;

  bool isValid({required DateTime now, required DateTime cachedAt}) {
    if (cacheInvalidationDuration != null) {
      return now.difference(cachedAt) < cacheInvalidationDuration!;
    }
    final nextInvalidation = DateTime(
      now.year,
      now.month,
      now.day,
      cacheInvalidationTime.hour,
      cacheInvalidationTime.minute,
    );
    if (now.weekday != cacheInvalidationWeekday) {
      final daysUntilInvalidation = (cacheInvalidationWeekday - now.weekday + 7) % 7;
      nextInvalidation.add(Duration(days: daysUntilInvalidation));
    }
    return cachedAt.isAfter(nextInvalidation);
  }

  TCachedQuery? validate({required DateTime now, required TCachedQuery cachedQuery}) {
    if (isValid(now: now, cachedAt: cachedQuery.createdAt)) {
      return cachedQuery;
    }
    _firestoreCacheService.delete(cachedQuery.id);
    return null;
  }

  Future<WRITEABLE?> get({
    required String path,
    required String id,
  }) async {
    await _firestoreCacheService.isReady;
    final cachedQuery = await _firestoreCacheService.getCachedQuery(_genId(id, path));
    if (cachedQuery == null) return null;
    if (cachedQuery.docIds.isEmpty) {
      TLog(location: 'TFirestoreCache').warning(
        'Cached query for $id at $path has no docIds, deleting cache entry',
      );
      await _deleteCachedDoc(id, path);
      return null;
    }
    if (cachedQuery.docIds.length != 1) {
      TLog(location: 'TFirestoreCache').warning(
        'Cached query for $id at $path has multiple docIds, expected 1. Deleting cache entry.',
      );
      await _deleteCachedDoc(id, path);
    }
    final validatedCache = validate(
      now: DateTime.now(),
      cachedQuery: cachedQuery,
    );
    if (validatedCache == null) {
      TLog(location: 'TFirestoreCache').info(
        'Cached query for $id at $path is invalid, deleting cache entry.',
      );
      await _deleteCachedDoc(id, path);
      return null;
    }
    final result = await _firestoreCacheService.read(validatedCache.docIds.first);
    if (result == null) {
      TLog(location: 'TFirestoreCache').warning(
        'Cached query for $id at $path has docId ${validatedCache.docIds.first} but no cached doc found. Deleting cache entry.',
      );
      await _deleteCachedDoc(id, path);
      return null;
    }
    return collection.fromJson(result);
  }

  FutureOr<void> _deleteCachedDoc(String id, String path) =>
      _firestoreCacheService.delete(_genId(id, path));

  Future<List<WRITEABLE>?> list({
    required String path,
    required String query,
  }) async {
    await _firestoreCacheService.isReady;
    final cachedQuery = await _firestoreCacheService.getCachedQuery(_genId(query, path));
    if (cachedQuery == null) return null;
    if (cachedQuery.docIds.isEmpty) {
      TLog(location: 'TFirestoreCache').warning(
        'Cached query for $query at $path has no docIds, deleting cache entry',
      );
      await _deleteCachedDoc(query, path);
      return null;
    }
    final validatedCache = validate(
      now: DateTime.now(),
      cachedQuery: cachedQuery,
    );
    if (validatedCache == null) {
      TLog(location: 'TFirestoreCache').info(
        'Cached query for $query at $path is invalid, deleting cache entry.',
      );
      await _deleteCachedDoc(query, path);
      return null;
    }
    final results = <WRITEABLE>[];
    for (final docId in cachedQuery.docIds) {
      final result = await _firestoreCacheService.read(docId);
      if (result == null) continue;
      results.add(collection.fromJson(result));
    }
    return results;
  }

  Future<TurboResponse> saveDoc({
    required String id,
    required String path,
    required WRITEABLE doc,
  }) => saveQuery(
    query: id,
    path: path,
    docs: [doc],
  );

  Future<TurboResponse> saveQuery({
    required String query,
    required String path,
    required List<WRITEABLE> docs,
  }) async {
    await _firestoreCacheService.isReady;
    final docIds = <String>{};
    for (final doc in docs) {
      final id = doc.id;
      await _firestoreCacheService.write(id, collection.toJson(doc));
      docIds.add(id);
    }
    final now = DateTime.now();
    final cachedQuery = TCachedQuery(
      query: _genId(query, path),
      docIds: docIds,
      createdAt: now,
      updatedAt: now,
    );
    await _firestoreCacheService.writeCachedQuery(cachedQuery: cachedQuery);
    return const TurboResponse.successAsBool();
  }

  String _genId(String id, String path) => id + '@' + path;
}

abstract class TFirestoreCacheService {
  TFirestoreCacheService() {
    initialise();
  }

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\
  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @mustCallSuper
  Future<void> initialise() async {
    await onInit();
    _isReady.completeIfNotComplete();
  }

  @mustCallSuper
  Future<void> dispose() async {
    await onDispose();
    _isReady = Completer();
  }

  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  FutureOr<void> write(String id, Map<String, dynamic> object);
  FutureOr<Map<String, dynamic>?> read(String id);
  FutureOr<void> delete(String id);

  Future<void> onInit();
  Future<void> onDispose();

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  var _isReady = Completer();

  // 🛠 UTIL ---------------------------------------------------------------------------------- \\
  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  Future get isReady => _isReady.future;

  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\
  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  FutureOr<void> writeCachedQuery({required TCachedQuery cachedQuery}) async => await write(
    cachedQuery.id,
    cachedQuery.toJson(),
  );

  FutureOr<TCachedQuery?> getCachedQuery(String id) async {
    final json = await read(id);
    if (json == null) return null;
    return TCachedQuery.fromJson(json);
  }
}
