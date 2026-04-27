import 'dart:async';

import 'package:flutter/material.dart';
import 'package:turbo_firestore_api/dtos/t_cached_query.dart';
import 'package:turbo_firestore_api/extensions/completer_extension.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:turbolytics/turbolytics.dart';

class TFirestoreCache {
  const TFirestoreCache({
    required IFirestoreCacheService firestoreCacheService,
    this.cacheInvalidationTime = const TimeOfDay(hour: 4, minute: 0),
    this.cacheInvalidationDuration,
    this.cacheInvalidationWeekday = DateTime.monday,
  }) : _firestoreCacheService = firestoreCacheService;

  final IFirestoreCacheService _firestoreCacheService;
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

  TCachedQuery? _validateCacheEntry({required DateTime now, required TCachedQuery cachedQuery}) {
    if (isValid(now: now, cachedAt: cachedQuery.createdAt)) {
      return cachedQuery;
    }
    _firestoreCacheService.delete(cachedQuery.id);
    return null;
  }

  Future<Map<String, dynamic>?> get({
    required String path,
    required String id,
  }) async {
    await _firestoreCacheService.isReady;
    final cachedQuery = await _firestoreCacheService.getCachedQuery(_genId(id, path));
    if (cachedQuery == null) return null;
    final doc = cachedQuery.doc;
    if (doc == null) {
      TLog(location: 'TFirestoreCache').warning(
        'Cached query for $id at $path has no doc, deleting cache entry',
      );
      await _deleteCachedDoc(id, path);
      return null;
    }
    final validatedCacheEntry = _validateCacheEntry(
      now: DateTime.now(),
      cachedQuery: cachedQuery,
    );
    if (validatedCacheEntry == null) {
      TLog(location: 'TFirestoreCache').info(
        'Cached query for $id at $path is invalid, deleting cache entry.',
      );
      await _deleteCachedDoc(id, path);
      return null;
    }
    return doc;
  }

  FutureOr<void> _deleteCachedDoc(String id, String path) =>
      _firestoreCacheService.delete(_genId(id, path));

  Future<List<Map<String, dynamic>>?> list({
    required String path,
    required String query,
  }) async {
    await _firestoreCacheService.isReady;
    final cachedQuery = await _firestoreCacheService.getCachedQuery(_genId(query, path));
    if (cachedQuery == null) return null;
    final docs = cachedQuery.docs;
    if (docs == null || docs.isEmpty) {
      TLog(location: 'TFirestoreCache').warning(
        'Cached query for $query at $path has no docs, deleting cache entry',
      );
      await _deleteCachedDoc(query, path);
      return null;
    }
    final validatedCacheEntry = _validateCacheEntry(
      now: DateTime.now(),
      cachedQuery: cachedQuery,
    );
    if (validatedCacheEntry == null) {
      TLog(location: 'TFirestoreCache').info(
        'Cached query for $query at $path is invalid, deleting cache entry.',
      );
      await _deleteCachedDoc(query, path);
      return null;
    }
    return docs;
  }

  Future<TurboResponse> saveDoc({
    required String docId,
    required String path,
    required Map<String, dynamic> doc,
  }) async {
    await _firestoreCacheService.isReady;
    final now = DateTime.now();
    final cachedQuery = TCachedQuery(
      query: _genId(docId, path),
      doc: doc,
      docs: null,
      createdAt: now,
      updatedAt: now,
    );
    await _firestoreCacheService.writeCachedQuery(cachedQuery: cachedQuery);
    return const TurboResponse.successAsBool();
  }

  Future<TurboResponse> saveDocs({
    required String query,
    required String path,
    required List<Map<String, dynamic>> docs,
  }) async {
    await _firestoreCacheService.isReady;
    final now = DateTime.now();
    final cachedQuery = TCachedQuery(
      query: _genId(query, path),
      doc: null,
      docs: docs,
      createdAt: now,
      updatedAt: now,
    );
    await _firestoreCacheService.writeCachedQuery(cachedQuery: cachedQuery);
    return const TurboResponse.successAsBool();
  }

  String _genId(String id, String path) => id + '@' + path;
}

abstract class IFirestoreCacheService {
  IFirestoreCacheService() {
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
