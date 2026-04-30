import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide Type;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:turbo_firestore_api/abstracts/i_firestore_cache_service.dart';
import 'package:turbo_firestore_api/abstracts/t_model.dart';
import 'package:turbo_firestore_api/factories/t_api_factory.dart';
import 'package:turbo_firestore_api/turbo_firestore_api.dart';
import 'package:turbo_firestore_api/typedefs/t_model_builder_def.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:turbo_serializable/abstracts/t_writeable.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';
import 'package:turbolytics/turbolytics.dart';

/// A service for managing a single Firestore document with synchronized local state.
///
/// Extends [TAuthSyncService] to provide functionality for managing a single document
/// that needs to be synchronized between Firestore and local state. It handles:
/// - Local state management with optimistic updates
/// - Remote state synchronization
/// - Transaction support
/// - Error handling
/// - Automatic user authentication state sync
/// - Before/after update notifications
///
/// Type Parameters:
/// - [DTO] - The document type, must extend [TWriteableId]
class TDocService<DTO extends TWriteableId, MODEL extends TModel<DTO>> extends TAuthSyncService<DTO>
    with Turbolytics {
  /// Creates a new [TDocService] instance.
  ///
  /// Parameters:
  /// - [collection] - The Firestore collection definition that this service manages
  /// - [apiBuilder] - Optional builder function to create the Firestore API instance
  /// - [initialiseStream] - Whether to automatically initialize the Firestore stream on service
  TDocService({
    required this.defaultValue,
    required this.modelBuilder,
    this.apiBuilder,
    this.streamBuilder,
    required this.collection,
    super.initialiseStream = TFirestoreApiDefaults.initialiseStream,
    this.initialValue,
    this.firestoreCacheService,
    this.afterLocalNotifyUpdate,
    this.beforeLocalNotifyUpdate,
  });

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\
  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  @protected
  /// The Firestore collection definition that this service manages.
  final TFirestoreCollection<DTO> collection;

  @protected
  /// Optional builder function to create the Firestore API instance. If not provided, the API will be created using the collection's `api()` method.
  final TDocApiBuilderDef<DTO, MODEL>? apiBuilder;

  @protected
  /// Optional builder function to create the Firestore stream. If not provided, the stream will be created using the API's `streamAllWithConverter()` method.
  final TDocStreamBuilderDef<DTO, MODEL>? streamBuilder;

  @protected
  /// Function to convert between DTO and MODEL for local state management.
  final TDocModelBuilderDef<DTO, MODEL> modelBuilder;

  @protected
  /// Function to provide initial document value.
  final TDocValueBuilderDef<DTO, MODEL>? initialValue;

  @protected
  /// Function to provide default document value.
  final TDocValueBuilderDef<DTO, MODEL> defaultValue;

  @protected
  /// Optional Firestore cache service for caching document data locally.
  final IFirestoreCacheService? firestoreCacheService;

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  /// Disposes of the document service and releases resources.
  ///
  /// This method:
  /// - Disposes of the local document state
  /// - Completes the ready state if not already completed
  /// - Calls the parent class dispose method
  ///
  /// This method must be called when the service is no longer needed
  /// to prevent memory leaks.
  @override
  @mustCallSuper
  Future<void> dispose() {
    _doc.dispose();
    _isReady.completeIfNotComplete();
    return super.dispose();
  }

  /// Marks the service as ready by completing the ready state.
  void markAsReady() => _isReady.completeIfNotComplete();

  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  @override
  Stream<DTO?> Function(User user) get stream =>
      (user) =>
          streamBuilder?.call(user, api, this) ?? api.streamByDocIdWithConverter(id: user.uid);

  /// Handles incoming data updates from Firestore.
  ///
  /// This callback is triggered when:
  /// - New document data is received from Firestore
  /// - The user's authentication state changes
  ///
  /// The method:
  /// - Updates local state with new document data if user is authenticated
  /// - Clears local state if user is not authenticated
  /// - Marks the service as ready after first update
  ///
  /// Parameters:
  /// - [value] - The new document value from Firestore
  /// - [user] - The current Firebase user
  @override
  Future<void> Function(DTO? value, User? user) get onData {
    return (value, user) async {
      if (user != null) {
        log.debug('Updating doc for user ${user.uid}');
        if (value != null) {
          upsertLocalDoc(
            id: value.id,
            doc: (current, _) => value,
          );
        } else {
          _doc.update(defaultDoc());
        }
        _isReady.completeIfNotComplete();
        log.debug('Updated doc');
      } else {
        log.debug('User is null, clearing doc');
        _doc.update(defaultDoc());
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
    log.warning('Document service stream error: $error');
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

  /// Local state for the document.
  late final _doc = TNotifier<MODEL>(initialDoc(), forceUpdate: true);

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
            defaultId: api.defaultIdValue,
            unknownId: api.unknownValue,
            unknownValue: api.unknownValue,
          )
          as V;

  /// Called before local state is updated.
  ValueChanged<DTO?>? beforeLocalNotifyUpdate;

  /// Called after local state is updated.
  ValueChanged<DTO?>? afterLocalNotifyUpdate;

  /// Future that completes when the service is ready.
  Future<void> get isReady => _isReady.future;

  /// Listenable for the document state.
  Listenable get listenable => _doc;

  /// Value listenable for the document state.
  ValueListenable<MODEL> get doc => _doc;

  /// Whether a document exists in local state.

  /// The document ID.
  String get id => _doc.value.id;

  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\

  @protected
  DTO initialDto() => initialValue?.call(vars(), collection, this) ?? defaultDto();

  @protected
  MODEL initialDoc() => modelBuilder(this, null, initialDto());

  @protected
  DTO defaultDto() => defaultValue.call(vars(), collection, this);

  @protected
  MODEL defaultDoc() => modelBuilder(this, null, defaultDto());

  // ⚙️ LOCAL MUTATORS ------------------------------------------------------------------------ \\

  /// Clears the local document state.
  void clearLocalDoc({bool doNotifyListeners = true}) {
    log.debug('Clearing local doc');
    if (doNotifyListeners) {
      beforeLocalNotifyUpdate?.call(null);
    }
    _doc.update(
      defaultDoc(),
      doNotifyListeners: doNotifyListeners,
    );
    if (doNotifyListeners) {
      afterLocalNotifyUpdate?.call(null);
    }
  }

  /// Forces a rebuild of the local state.
  void rebuild() => _doc.rebuild();

  /// Deletes a document from local state.
  ///
  /// Parameters:
  /// - [id] - The document ID
  /// - [doNotifyListeners] - Whether to notify listeners of the change
  @protected
  void deleteLocalDoc({
    required String id,
    bool doNotifyListeners = true,
  }) {
    log.debug('Deleting local doc with id: $id');
    if (doNotifyListeners) {
      beforeLocalNotifyUpdate?.call(null);
    }
    _doc.update(
      defaultDoc(),
      doNotifyListeners: doNotifyListeners,
    );
    if (doNotifyListeners) {
      afterLocalNotifyUpdate?.call(null);
    }
  }

  /// Creates a new document in local state.
  ///
  /// Parameters:
  /// - [doc] - The document to create
  /// - [doNotifyListeners] - Whether to notify listeners of the change
  @protected
  DTO createLocalDoc({
    required CreateDocDef<DTO, MODEL> doc,
    bool doNotifyListeners = true,
  }) {
    final pDoc = doc(vars());
    log.debug('Creating local doc with id: ${pDoc.id}');
    if (doNotifyListeners) {
      beforeLocalNotifyUpdate?.call(pDoc);
    }
    _doc.update(
      modelBuilder(this, null, pDoc),
      doNotifyListeners: doNotifyListeners,
    );
    if (doNotifyListeners) {
      afterLocalNotifyUpdate?.call(pDoc);
    }
    return pDoc;
  }

  /// Updates an existing document in local state.
  ///
  /// Parameters:
  /// - [id] - The document ID
  /// - [doc] - The document update function
  /// - [doNotifyListeners] - Whether to notify listeners of the change
  @protected
  DTO updateLocalDoc({
    required String id,
    required UpdateDocDef<DTO, MODEL> doc,
    bool doNotifyListeners = true,
  }) {
    final pDoc = doc(_doc.value, vars(id: id));
    log.debug('Updating local doc with id: ${pDoc.id}');
    if (doNotifyListeners) {
      beforeLocalNotifyUpdate?.call(pDoc);
    }
    _doc.update(modelBuilder(this, null, pDoc), doNotifyListeners: doNotifyListeners);
    if (doNotifyListeners) {
      afterLocalNotifyUpdate?.call(pDoc);
    }
    return pDoc;
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
    final pDoc = doc(_doc.value, vars(id: id));
    log.debug('Upserting local doc with id: $id');
    if (doNotifyListeners) {
      beforeLocalNotifyUpdate?.call(pDoc);
    }
    _doc.update(modelBuilder(this, null, pDoc), doNotifyListeners: doNotifyListeners);
    if (doNotifyListeners) {
      afterLocalNotifyUpdate?.call(pDoc);
    }
    return pDoc;
  }

  // 🕹️ LOCAL & REMOTE MUTATORS --------------------------------------------------------------- \\

  /// Deletes a document both locally and from Firestore.
  ///
  /// Performs an optimistic delete by updating the local state first,
  /// then syncing with Firestore. If the remote delete fails, the local
  /// state remains updated.
  ///
  /// Parameters:
  /// - [id] - The document ID
  /// - [doNotifyListeners] - Whether to notify listeners of the change
  /// - [transaction] - Optional transaction for atomic operations
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

  /// Updates a document both locally and in Firestore.
  ///
  /// Performs an optimistic update by updating the local state first,
  /// then syncing with Firestore. If the remote update fails, the local
  /// state remains updated.
  ///
  /// Parameters:
  /// - [id] - The document ID
  /// - [doc] - The function to update the document
  /// - [remoteUpdateRequestBuilder] - Optional function to build the remote update request
  /// - [doNotifyListeners] - Whether to notify listeners of the change
  /// - [transaction] - Optional transaction for atomic operations
  ///
  /// Returns a [TurboResponse] with the updated document reference
  @protected
  Future<TurboResponse<DTO>> updateDoc({
    Transaction? transaction,
    required String id,
    required UpdateDocDef<DTO, MODEL> doc,
    TWriteable Function(DTO doc)? remoteUpdateRequestBuilder,
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
        writeable: remoteUpdateRequestBuilder?.call(pDoc) ?? pDoc as TWriteable,
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
  /// - [id] - The document ID
  /// - [doc] - The function to create the document
  /// - [doNotifyListeners] - Whether to notify listeners of the change
  /// - [transaction] - Optional transaction for atomic operations
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
    TWriteableId Function(DTO doc)? remoteUpdateRequestBuilder,
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
        writeable: remoteUpdateRequestBuilder?.call(pDoc) ?? pDoc as TWriteableId,
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
}
