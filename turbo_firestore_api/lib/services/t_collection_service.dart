import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide Type;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:turbo_firestore_api/abstracts/i_firestore_cache_service.dart';
import 'package:turbo_firestore_api/abstracts/t_model.dart';
import 'package:turbo_firestore_api/factories/t_api_factory.dart';
import 'package:turbo_firestore_api/models/t_model_docs.dart';
import 'package:turbo_firestore_api/turbo_firestore_api.dart';
import 'package:turbo_firestore_api/typedefs/t_model_builder_def.dart';
import 'package:turbo_firestore_api/typedefs/t_model_docs_builder_def.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:turbo_serializable/abstracts/t_serializable.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';
import 'package:turbolytics/turbolytics.dart';

/// A service for managing a collection of Firestore documents with synchronized local state.
///
/// The [TCollectionService] provides a robust foundation for managing collections of documents
/// that need to be synchronized between Firestore and local state. It handles:
/// - Local state management with optimistic updates
/// - Remote state synchronization
/// - Batch operations
/// - Transaction support
/// - Error handling
/// - Automatic user authentication state sync
///
/// Type Parameters:
/// - [DTO] - The document type, must extend [TWriteableId]
///
/// Example:
/// ```dart
/// class UserService extends TurboCollectionService<User, UserApi> {
///   UserService({required super.api});
///
///   Future<void> updateUserName(String userId, String newName) async {
///     final user = findById(userId);
///     final updated = user.copyWith(name: newName);
///     await updateDoc(doc: updated);
///   }
/// }
/// ```
///
/// Features:
/// - Automatic local state updates before remote operations
/// - Optimistic UI updates with rollback on failure
/// - Batch operations for multiple documents
/// - Transaction support for atomic operations
/// - Automatic stream update blocking during mutations
/// - Error handling and logging
/// - User authentication state synchronization
class TCollectionService<DTO extends TWriteableId, MODEL extends TModel<DTO>>
    extends TAuthSyncService<List<DTO>>
    with Turbolytics {
  /// Creates a new [TCollectionService] instance.
  ///
  /// Parameters:
  /// - [api] - The Firestore API instance for remote operations
  TCollectionService({
    required this.collection,
    required this.modelBuilder,
    this.modelDocsBuilder,
    this.apiBuilder,
    this.streamBuilder,
    this.initialValue,
    this.defaultValue,
    super.initialiseStream = true,
    this.firestoreCacheService,
  });

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\
  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  @protected
  /// The Firestore collection definition that this service manages.
  final TFirestoreCollection<DTO> collection;

  @protected
  /// Optional builder function to create the Firestore API instance. If not provided, the API will be created using the collection's `api()` method.
  final TCollectionApiBuilderDef<DTO, MODEL>? apiBuilder;

  @protected
  /// Optional builder function to create the Firestore stream. If not provided, the stream will be created using the API's `streamAllWithConverter()` method.
  final TCollectionStreamBuilderDef<DTO, MODEL>? streamBuilder;

  @protected
  /// Function to convert Firestore documents into local model instances.
  final TCollectionModelBuilderDef<DTO, MODEL> modelBuilder;

  @protected
  /// Optional builder function to create the local model documents state from a list of DTOs. If not provided, the state will be created using `TModelDocs.fromDtos()`.
  final TModelDocsBuilderDef<DTO, MODEL>? modelDocsBuilder;

  @protected
  /// Function to provide initial document value.
  final TCollectionValueBuilderDef<DTO, MODEL>? initialValue;

  @protected
  /// Function to provide default document value.
  final TCollectionValueBuilderDef<DTO, MODEL>? defaultValue;

  @protected
  /// Optional Firestore cache service for caching document data locally.
  final IFirestoreCacheService? firestoreCacheService;

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  /// Disposes of the service by cleaning up resources.
  ///
  /// Disposes the [docs] TNotifier and completes the [_isReady] completer
  /// if not already completed. Then calls the parent dispose method.
  @override
  Future<void> dispose() {
    docsNotifier.dispose();
    _isReady.completeIfNotComplete();
    return super.dispose();
  }

  /// Marks the service as ready by completing the ready state.
  void markAsReady() => _isReady.completeIfNotComplete();

  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  @override
  Stream<List<DTO>> Function(User user) get stream =>
      (user) => streamBuilder?.call(user, api, this) ?? api.streamAllWithConverter();

  /// Handles data updates from the Firestore stream.
  ///
  /// Updates the local state when new data arrives from Firestore.
  /// If [user] is null, clears the local state.
  @override
  Future<void> Function(List<DTO>? value, User? user) get onData {
    return (value, user) async {
      final docs = value ?? defaultValues();
      if (user != null) {
        log.debug('Updating docs for user ${user.uid}');
        docsNotifier.update(
          modelDocsBuilder?.call(api, this, modelBuilder, docs) ??
              TModelDocs.fromDtos(
                dtos: docs,
                modelBuilder: (dto) => modelBuilder(this, null, dto),
              ),
        );
        _isReady.completeIfNotComplete();
        log.debug('Updated ${docsNotifier.value.length} docs');
      } else {
        log.debug('User is null, clearing docs');
        resetLocalDocs();
      }
    };
  }

  /// Called when a stream error occurs.
  ///
  /// Override this method to handle specific Firestore error types.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void onError(TurboFirestoreException error) {
  ///   if (error is TurboFirestorePermissionDeniedException) {
  ///     // Handle permission errors
  ///     showPermissionErrorDialog();
  ///   } else if (error is TurboFirestoreUnavailableException) {
  ///     // Handle service unavailability
  ///     showOfflineMessage();
  ///   } else {
  ///     // Handle other errors
  ///     showGenericErrorMessage();
  ///   }
  /// }
  /// ```
  ///
  /// Parameters:
  /// - [error] - The Firestore exception that occurred
  @override
  void onError(TFirestoreException error) {
    _isReady.completeIfNotComplete();
    log.warning('Collection service stream error: $error');
    super.onError(error);
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  /// The Firestore API instance for remote operations.
  late final TFirestoreApi<DTO> api =
      apiBuilder?.call(
        user,
        TApiFactory<DTO>(collection: collection),
        this,
        firestoreCacheService,
      ) ??
      collection.api(
        firestoreCacheService: firestoreCacheService,
        isCollectionGroup: collection.isCollectionGroup,
      );

  /// Local state for documents, indexed by their IDs.
  @protected
  late final docsNotifier = TNotifier<TModelDocs<DTO, MODEL>>(
    initialDocs(),
    forceUpdate: true,
  );

  /// Completer that resolves when the service is ready.
  final _isReady = Completer<void>();

  // 🛠 UTIL ---------------------------------------------------------------------------------- \\
  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// Returns a new instance of [V] with basic variables filled in.
  V vars<V extends TVars>({String? id}) =>
      TVars(
            id: id ?? api.genId,
            now: DateTime.now(),
            userId: userId,
            defaultId: api.defaultId,
            unknownId: api.unknownId,
          )
          as V;

  @Deprecated('Use TCollectionService.docs')
  ValueListenable<TModelDocs<DTO, MODEL>> get docsPerId => docsNotifier;

  /// A listenable that provides the current documents indexed by their IDs.
  ValueListenable<TModelDocs<DTO, MODEL>> get docs => docsNotifier;

  /// Whether the collection has any documents.
  bool get hasDocs => docsNotifier.value.isNotEmpty;

  /// Whether a document with the given ID exists.
  bool exists(String id) => docsNotifier.value.exists(id);

  /// Finds a document by its ID. Throws if not found.
  MODEL findById(String id) => docsNotifier.value.get(id)!;

  /// Finds a document by its ID. Returns null if not found.
  MODEL? tryFindById(String? id) => docsNotifier.value.get(id);

  /// Future that completes when the service is ready to use.
  Future<void> get isReady => _isReady.future;

  /// Listenable for the document collection state.
  Listenable get listenable => docs;

  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\

  @protected
  TModelDocs<DTO, MODEL> defaultDocs() =>
      modelDocsBuilder?.call(api, this, modelBuilder, defaultValues()) ??
      TModelDocs.fromDtos(
        dtos: defaultValues(),
        modelBuilder: (dto) => modelBuilder(this, null, dto),
      );

  @protected
  TModelDocs<DTO, MODEL> initialDocs() =>
      modelDocsBuilder?.call(api, this, modelBuilder, initialValues() ?? defaultValues()) ??
      TModelDocs.fromDtos(
        dtos: initialValues() ?? defaultValues(),
        modelBuilder: (dto) => modelBuilder(this, null, dto),
      );

  @protected
  List<DTO>? initialValues() => initialValue?.call(vars(), collection, this);

  @protected
  List<DTO> defaultValues() => defaultValue?.call(vars(), collection, this) ?? [];

  // ⚙️ LOCAL MUTATORS ------------------------------------------------------------------------ \\

  /// Resets the local documents to their initial value.
  void resetLocalDocs({bool doNotifyListeners = true}) {
    log.debug('Resetting local docs to initial value');
    docsNotifier.update(
      initialDocs(),
      doNotifyListeners: doNotifyListeners,
    );
  }

  /// Clears all documents from local state.
  void clearLocalDocs({bool doNotifyListeners = true}) {
    log.debug('Clearing all local docs');
    docsNotifier.update(
      TModelDocs.empty(
        modelBuilder: (dto) => modelBuilder(this, null, dto),
      ),
      doNotifyListeners: doNotifyListeners,
    );
  }

  /// Forces a rebuild of the local state.
  void rebuild() => docsNotifier.rebuild();

  /// Deletes a document from local state.
  ///
  /// Parameters:
  /// - [id] - The ID of the document to delete
  /// - [doNotifyListeners] - Whether to notify listeners of the change
  @protected
  void deleteLocalDoc({
    required String id,
    bool doNotifyListeners = true,
  }) {
    log.debug('Deleting local doc with id: $id');
    docsNotifier.updateCurrent(
      (value) => value..remove(id),
      doNotifyListeners: doNotifyListeners,
    );
  }

  /// Deletes multiple documents from local state.
  ///
  /// Parameters:
  /// - [ids] - The IDs of the documents to delete
  /// - [doNotifyListeners] - Whether to notify listeners of the changes
  @protected
  void deleteLocalDocs({
    required List<String> ids,
    bool doNotifyListeners = true,
  }) {
    log.debug('Deleting ${ids.length} local docs');
    for (final id in ids) {
      deleteLocalDoc(id: id, doNotifyListeners: false);
    }
    if (doNotifyListeners) docsNotifier.rebuild();
  }

  /// Updates an existing document in local state.
  ///
  /// Parameters:
  /// - [id] - The ID of the document to update
  /// - [doc] - The definition of how to update the document
  /// - [doNotifyListeners] - Whether to notify listeners of the change
  @protected
  DTO updateLocalDoc({
    required String id,
    required UpdateDocDef<DTO, MODEL> doc,
    bool doNotifyListeners = true,
  }) {
    log.debug('Updating local doc with id: $id');
    final pDoc = doc(
      findById(id),
      vars(id: id),
    );
    docsNotifier.updateCurrent(
      (value) => value
        ..updateDto(
          pDoc,
        ),
      doNotifyListeners: doNotifyListeners,
    );
    return pDoc;
  }

  /// Creates a new document in local state.
  ///
  /// Parameters:
  /// - [id] - The ID of the document to create
  /// - [doc] - The definition of how to create the document
  /// - [doNotifyListeners] - Whether to notify listeners of the change
  @protected
  DTO createLocalDoc({
    required CreateDocDef<DTO, MODEL> doc,
    bool doNotifyListeners = true,
  }) {
    final pDoc = doc(
      vars(),
    );
    log.debug('Creating local doc with id: ${pDoc.id}');
    docsNotifier.updateCurrent(
      (value) => value..updateDto(pDoc),
      doNotifyListeners: doNotifyListeners,
    );
    return pDoc;
  }

  /// Updates multiple existing documents in local state.
  ///
  /// Parameters:
  /// - [ids] - The IDs of the documents to update
  /// - [doc] - The definition of how to update the documents
  /// - [doNotifyListeners] - Whether to notify listeners of the changes
  @protected
  List<DTO> updateLocalDocs({
    required List<String> ids,
    required UpdateDocDef<DTO, MODEL> doc,
    bool doNotifyListeners = true,
  }) {
    log.debug('Updating ${ids.length} local docs');
    final pDocs = <DTO>[];
    for (final id in ids) {
      final pDoc = updateLocalDoc(id: id, doc: doc, doNotifyListeners: false);
      pDocs.add(pDoc);
    }
    if (doNotifyListeners) docsNotifier.rebuild();
    return pDocs;
  }

  /// Creates multiple new documents in local state.
  ///
  /// Parameters:
  /// - [ids] - The IDs of the documents to create
  /// - [docs] - The definition of how to create the documents
  /// - [doNotifyListeners] - Whether to notify listeners of the changes
  @protected
  List<DTO> createLocalDocs({
    required List<CreateDocDef<DTO, MODEL>> docs,
    bool doNotifyListeners = true,
  }) {
    log.debug('Creating ${docsNotifier.value.length} local docs');
    final pDocs = <DTO>[];
    for (final doc in docs) {
      final pDoc = createLocalDoc(doc: doc, doNotifyListeners: false);
      pDocs.add(pDoc);
    }
    if (doNotifyListeners) docsNotifier.rebuild();
    return pDocs;
  }

  /// Upserts (updates or inserts) multiple documents in local state.
  ///
  /// This method will either update existing documents or create new ones
  /// if they don't exist. The [doc] function receives each current document
  /// (or null if it doesn't exist) and should return the new document state.
  ///
  /// Parameters:
  /// - [ids] - The IDs of the documents to upsert
  /// - [doc] - The definition of how to upsert the documents
  /// - [doNotifyListeners] - Whether to notify listeners of the changes
  ///
  /// Returns the list of upserted documents
  @protected
  List<DTO> upsertLocalDocs({
    required List<String> ids,
    required UpsertDocDef<DTO, MODEL> doc,
    bool doNotifyListeners = true,
  }) {
    log.debug('Upserting ${ids.length} local docs');
    final pDocs = <DTO>[];
    for (final id in ids) {
      final pDoc = upsertLocalDoc(
        id: id,
        doc: doc,
        doNotifyListeners: false,
      );
      pDocs.add(pDoc);
    }
    if (doNotifyListeners) docsNotifier.rebuild();
    return pDocs;
  }

  /// Upserts (updates or inserts) a document in local state.
  ///
  /// This method will either update an existing document or create a new one
  /// if it doesn't exist. The [doc] function receives the current document
  /// (or null if it doesn't exist) and should return the new document state.
  ///
  /// Parameters:
  /// - [id] - The ID of the document to upsert
  /// - [doc] - The definition of how to upsert the document
  /// - [doNotifyListeners] - Whether to notify listeners of the change
  ///
  /// Returns the upserted document
  @protected
  DTO upsertLocalDoc({
    required String id,
    required UpsertDocDef<DTO, MODEL> doc,
    bool doNotifyListeners = true,
  }) {
    log.debug('Upserting local doc with id: $id');
    final pDoc = doc(tryFindById(id), vars(id: id));
    docsNotifier.updateCurrent(
      (value) => value..updateDto(pDoc),
      doNotifyListeners: doNotifyListeners,
    );
    return pDoc;
  }

  /// Upserts (updates or inserts) a document both locally and in Firestore.
  ///
  /// This method will either update an existing document or create a new one
  /// if it doesn't exist. The [doc] function receives the current document
  /// (or null if it doesn't exist) and should return the new document state.
  ///
  /// Performs an optimistic upsert by updating the local state first,
  /// then syncing with Firestore. If the remote upsert fails, the local
  /// state remains updated.
  ///
  /// Parameters:
  /// - [transaction] - Optional transaction for atomic operations
  /// - [id] - The ID of the document to upsert
  /// - [doc] - The definition of how to upsert the document
  /// - [remoteUpdateRequestBuilder] - Optional builder to modify the document before upserting
  /// - [doNotifyListeners] - Whether to notify listeners of the change
  ///
  /// Returns a [TurboResponse] with the upserted document reference
  @protected
  Future<TurboResponse<DTO>> upsertDoc({
    Transaction? transaction,
    required String id,
    required UpsertDocDef<DTO, MODEL> doc,
    TSerializable Function(DTO doc)? remoteUpdateRequestBuilder,
    bool doNotifyListeners = true,
  }) async {
    try {
      log.debug('Upserting doc with id: $id');
      final pDoc = upsertLocalDoc(
        id: id,
        doc: doc,
        doNotifyListeners: doNotifyListeners,
      );
      final future = api.createDoc(
        writeable: remoteUpdateRequestBuilder?.call(pDoc) ?? pDoc as TSerializable,
        id: id,
        transaction: transaction,
        merge: true,
      );
      final turboResponse = await future;
      if (transaction != null) {
        turboResponse.throwWhenFail();
      }
      return turboResponse.mapSuccess((_) => pDoc);
    } catch (error, stackTrace) {
      if (transaction != null) rethrow;
      log.error(
        '$error caught while upserting doc',
        error: error,
        stackTrace: stackTrace,
      );
      return TurboResponse.fail(error: error);
    }
  }

  // 🕹️ LOCAL & REMOTE MUTATORS --------------------------------------------------------------- \\

  /// Updates a document both locally and in Firestore.
  ///
  /// Performs an optimistic update by updating the local state first,
  /// then syncing with Firestore. If the remote update fails, the local
  /// state remains updated.
  ///
  /// Parameters:
  /// - [transaction] - Optional transaction for atomic operations
  /// - [id] - The ID of the document to update
  /// - [doc] - The definition of how to update the document
  /// - [remoteUpdateRequestBuilder] - Optional builder to modify the document before updating
  /// - [doNotifyListeners] - Whether to notify listeners of the change
  ///
  /// Returns a [TurboResponse] with the updated document reference
  @protected
  Future<TurboResponse<DTO>> updateDoc({
    Transaction? transaction,
    required String id,
    required UpdateDocDef<DTO, MODEL> doc,
    TWriteableId Function(DTO doc)? remoteUpdateRequestBuilder,
    bool doNotifyListeners = true,
  }) async {
    try {
      log.debug('Updating doc with id: $id');
      final pDoc = updateLocalDoc(
        id: id,
        doc: doc,
        doNotifyListeners: doNotifyListeners,
      );
      final future = api.updateDoc(
        writeable: remoteUpdateRequestBuilder?.call(pDoc) ?? pDoc as TWriteableId,
        id: id,
        transaction: transaction,
      );
      final turboResponse = await future;
      if (transaction != null) {
        turboResponse.throwWhenFail();
      }
      return turboResponse.mapSuccess((_) => pDoc);
    } catch (error, stackTrace) {
      if (transaction != null) rethrow;
      log.error(
        '$error caught while updating doc',
        error: error,
        stackTrace: stackTrace,
      );
      return TurboResponse.fail(error: error);
    }
  }

  /// Creates a new document both locally and in Firestore.
  ///
  /// Performs an optimistic create by updating the local state first,
  /// then syncing with Firestore. If the remote create fails, the local
  /// state remains updated.
  ///
  /// Parameters:
  /// - [transaction] - Optional transaction for atomic operations
  /// - [id] - The ID of the document to create
  /// - [doc] - The definition of how to create the document
  /// - [doNotifyListeners] - Whether to notify listeners of the change
  ///
  /// Returns a [TurboResponse] with the created document reference
  @protected
  Future<TurboResponse<DTO>> createDoc({
    Transaction? transaction,
    required CreateDocDef<DTO, MODEL> doc,
    bool doNotifyListeners = true,
  }) async {
    try {
      final pDoc = createLocalDoc(
        doc: doc,
        doNotifyListeners: doNotifyListeners,
      );
      log.debug('Creating doc with id: ${pDoc.id}');
      final future = api.createDoc(
        writeable: pDoc,
        id: pDoc.id,
        transaction: transaction,
      );
      final turboResponse = await future;
      if (transaction != null) {
        turboResponse.throwWhenFail();
      }
      return turboResponse.mapSuccess((_) => pDoc);
    } catch (error, stackTrace) {
      if (transaction != null) rethrow;
      log.error(
        '$error caught while creating doc',
        error: error,
        stackTrace: stackTrace,
      );
      return TurboResponse.fail(error: error);
    }
  }

  /// Updates multiple documents both locally and in Firestore.
  ///
  /// Performs optimistic updates by updating the local state first,
  /// then syncing with Firestore. Uses a batch operation for multiple
  /// documents unless a transaction is provided.
  ///
  /// Parameters:
  /// - [transaction] - Optional transaction for atomic operations
  /// - [ids] - The IDs of the documents to update
  /// - [doc] - The definition of how to update the documents
  /// - [doNotifyListeners] - Whether to notify listeners of the changes
  ///
  /// Returns a [TurboResponse] indicating success or failure
  @protected
  Future<TurboResponse<List<DTO>>> updateDocs({
    Transaction? transaction,
    required List<String> ids,
    required UpdateDocDef<DTO, MODEL> doc,
    bool doNotifyListeners = true,
  }) async {
    try {
      log.debug('Updating ${ids.length} docs');
      final pDocs = updateLocalDocs(
        ids: ids,
        doc: doc,
        doNotifyListeners: doNotifyListeners,
      );
      if (transaction != null) {
        for (final pDoc in pDocs) {
          (await api.updateDoc(
            id: pDoc.id,
            transaction: transaction,
            writeable: pDoc as TWriteableId,
          )).throwWhenFail();
        }
        return TurboResponse.success(result: pDocs);
      } else {
        final batch = api.writeBatch;
        for (final pDoc in pDocs) {
          await api.updateDocInBatch(
            id: pDoc.id,
            writeBatch: batch,
            writeable: pDoc as TWriteableId,
          );
        }
        final future = batch.commit();
        await future;
        return TurboResponse.success(result: pDocs);
      }
    } catch (error, stackTrace) {
      if (transaction != null) rethrow;
      log.error(
        '${error.runtimeType} caught while updating docs',
        error: error,
        stackTrace: stackTrace,
      );
      return TurboResponse.fail(error: error);
    }
  }

  /// Creates multiple documents both locally and in Firestore.
  ///
  /// Performs optimistic creates by updating the local state first,
  /// then syncing with Firestore. Uses a batch operation for multiple
  /// documents unless a transaction is provided.
  ///
  /// Parameters:
  /// - [transaction] - Optional transaction for atomic operations
  /// - [ids] - The IDs of the documents to create
  /// - [doc] - The definition of how to create the documents
  /// - [doNotifyListeners] - Whether to notify listeners of the changes
  ///
  /// Returns a [TurboResponse] indicating success or failure
  @protected
  Future<TurboResponse<List<DTO>>> createDocs({
    Transaction? transaction,
    required List<CreateDocDef<DTO, MODEL>> docs,
    bool doNotifyListeners = true,
  }) async {
    try {
      final pDocs = createLocalDocs(
        docs: docs,
        doNotifyListeners: doNotifyListeners,
      );
      log.debug('Creating ${pDocs.length} docs');
      if (transaction != null) {
        for (final pDoc in pDocs) {
          (await api.createDoc(
            id: pDoc.id,
            transaction: transaction,
            writeable: pDoc,
          )).throwWhenFail();
        }
        return TurboResponse.success(result: pDocs);
      } else {
        final batch = api.writeBatch;
        for (final pDoc in pDocs) {
          await api.createDocInBatch(
            id: pDoc.id,
            writeBatch: batch,
            writeable: pDoc,
          );
        }
        final future = batch.commit();
        await future;
        return TurboResponse.success(result: pDocs);
      }
    } catch (error, stackTrace) {
      if (transaction != null) rethrow;
      log.error(
        '${error.runtimeType} caught while creating docs',
        error: error,
        stackTrace: stackTrace,
      );
      return TurboResponse.fail(error: error);
    }
  }

  /// Deletes a document both locally and from Firestore.
  ///
  /// Performs an optimistic delete by updating the local state first,
  /// then syncing with Firestore. If the remote delete fails, the local
  /// state remains updated.
  ///
  /// Parameters:
  /// - [transaction] - Optional transaction for atomic operations
  /// - [id] - The ID of the document to delete
  /// - [doNotifyListeners] - Whether to notify listeners of the change
  ///
  /// Returns a [TurboResponse] indicating success or failure
  @protected
  Future<TurboResponse<void>> deleteDoc({
    required String id,
    bool doNotifyListeners = true,
    Transaction? transaction,
  }) async {
    try {
      log.debug('Deleting doc with id: $id');
      deleteLocalDoc(
        id: id,
        doNotifyListeners: doNotifyListeners,
      );
      final future = api.deleteDoc(
        id: id,
        transaction: transaction,
      );
      final turboResponse = await future;
      if (transaction != null) {
        turboResponse.throwWhenFail();
      }
      return turboResponse;
    } catch (error, stackTrace) {
      if (transaction != null) rethrow;
      log.error(
        '$error caught while deleting doc',
        error: error,
        stackTrace: stackTrace,
      );
      return TurboResponse.fail(error: error);
    }
  }

  /// Deletes multiple documents both locally and from Firestore.
  ///
  /// Performs optimistic deletes by updating the local state first,
  /// then syncing with Firestore. Uses a batch operation for multiple
  /// documents unless a transaction is provided.
  ///
  /// Parameters:
  /// - [transaction] - Optional transaction for atomic operations
  /// - [ids] - The IDs of the documents to delete
  /// - [doNotifyListeners] - Whether to notify listeners of the changes
  ///
  /// Returns a [TurboResponse] indicating success or failure
  @protected
  Future<TurboResponse<void>> deleteDocs({
    Transaction? transaction,
    required List<String> ids,
    bool doNotifyListeners = true,
  }) async {
    try {
      log.debug('Deleting ${ids.length} docs');
      deleteLocalDocs(
        ids: ids,
        doNotifyListeners: doNotifyListeners,
      );
      if (transaction != null) {
        for (final id in ids) {
          (await api.deleteDoc(
            id: id,
            transaction: transaction,
          )).throwWhenFail();
        }
        return const TurboResponse.successAsBool();
      } else {
        final batch = api.writeBatch;
        for (final id in ids) {
          await api.deleteDocInBatch(
            id: id,
            writeBatch: batch,
          );
        }
        final future = batch.commit();
        await future;
        return const TurboResponse.successAsBool();
      }
    } catch (error, stackTrace) {
      if (transaction != null) rethrow;
      log.error(
        '${error.runtimeType} caught while deleting docs',
        error: error,
        stackTrace: stackTrace,
      );
      return TurboResponse.fail(error: error);
    }
  }

  /// Upserts (updates or inserts) multiple documents both locally and in Firestore.
  ///
  /// This method will either update existing documents or create new ones
  /// if they don't exist. The [doc] function receives each current document
  /// (or null if it doesn't exist) and should return the new document state.
  ///
  /// Performs optimistic upserts by updating the local state first,
  /// then syncing with Firestore. Uses a batch operation for multiple
  /// documents unless a transaction is provided.
  ///
  /// Parameters:
  /// - [transaction] - Optional transaction for atomic operations
  /// - [ids] - The IDs of the documents to upsert
  /// - [doc] - The definition of how to upsert the documents
  /// - [doNotifyListeners] - Whether to notify listeners of the changes
  ///
  /// Returns a [TurboResponse] with the list of upserted documents
  @protected
  Future<TurboResponse<List<DTO>>> upsertDocs({
    Transaction? transaction,
    required List<String> ids,
    required UpsertDocDef<DTO, MODEL> doc,
    bool doNotifyListeners = true,
  }) async {
    try {
      log.debug('Upserting ${ids.length} docs');
      final pDocs = upsertLocalDocs(
        ids: ids,
        doc: doc,
        doNotifyListeners: doNotifyListeners,
      );
      if (transaction != null) {
        for (final pDoc in pDocs) {
          (await api.createDoc(
            writeable: pDoc,
            id: pDoc.id,
            transaction: transaction,
            merge: true,
          )).throwWhenFail();
        }
        return TurboResponse.success(result: pDocs);
      } else {
        final batch = api.writeBatch;
        for (final pDoc in pDocs) {
          await api.createDocInBatch(
            id: pDoc.id,
            writeBatch: batch,
            writeable: pDoc,
            merge: true,
          );
        }
        final future = batch.commit();
        await future;
        return TurboResponse.success(result: pDocs);
      }
    } catch (error, stackTrace) {
      if (transaction != null) rethrow;
      log.error(
        '${error.runtimeType} caught while upserting docs',
        error: error,
        stackTrace: stackTrace,
      );
      return TurboResponse.fail(error: error);
    }
  }

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\
}
