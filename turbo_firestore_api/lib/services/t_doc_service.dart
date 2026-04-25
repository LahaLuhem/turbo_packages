import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide Type;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:turbo_firestore_api/factories/t_api_factory.dart';
import 'package:turbo_firestore_api/turbo_firestore_api.dart';
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
/// - [WRITEABLE] - The document type, must extend [TWriteableId]
class TDocService<WRITEABLE extends TWriteableId> extends TAuthSyncService<WRITEABLE>
    with Turbolytics {
  /// Creates a new [TDocService] instance.
  ///
  /// Parameters:
  /// - [collection] - The Firestore collection definition that this service manages
  /// - [apiBuilder] - Optional builder function to create the Firestore API instance
  /// - [initialiseStream] - Whether to automatically initialize the Firestore stream on service
  TDocService({
    required this.defaultValue,
    this.apiBuilder,
    this.streamBuilder,
    required this.collection,
    super.initialiseStream = true,
    this.initialValue,
  });

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\
  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  @protected
  /// The Firestore collection definition that this service manages.
  final TFirestoreCollection<WRITEABLE> collection;

  @protected
  /// Optional builder function to create the Firestore API instance. If not provided, the API will be created using the collection's `api()` method.
  final TDocApiBuilderDef<WRITEABLE>? apiBuilder;

  @protected
  /// Optional builder function to create the Firestore stream. If not provided, the stream will be created using the API's `streamAllWithConverter()` method.
  final TDocStreamBuilderDef<WRITEABLE>? streamBuilder;

  @protected
  /// Function to provide initial document value.
  final TDocValueBuilderDef<WRITEABLE>? initialValue;

  @protected
  /// Function to provide default document value.
  final TDocValueBuilderDef<WRITEABLE> defaultValue;

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
  Stream<WRITEABLE?> Function(User user) get stream =>
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
  Future<void> Function(WRITEABLE? value, User? user) get onData {
    return (value, user) async {
      if (user != null) {
        log.debug('Updating doc for user ${user.uid}');
        if (value != null) {
          upsertLocalDoc(
            id: value.id,
            doc: (current, _) => value,
          );
        } else {
          _doc.update(
            defaultValue.call(vars(), collection, this),
          );
        }
        _isReady.completeIfNotComplete();
        log.debug('Updated doc');
      } else {
        log.debug('User is null, clearing doc');
        _doc.update(
          defaultValue.call(vars(), collection, this),
        );
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
  late final TFirestoreApi<WRITEABLE> api =
      apiBuilder?.call(user, TApiFactory<WRITEABLE>(collection: collection), this) ??
      collection.api();

  /// Local state for the document.
  late final _doc = TNotifier<WRITEABLE>(
    initialValue?.call(vars(), collection, this) ?? (defaultValue.call(vars(), collection, this)),
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
            defaultId: collection.defaultId,
            unknownId: collection.unknownIdFallback,
          )
          as V;

  /// Called before local state is updated.
  ValueChanged<WRITEABLE?>? beforeLocalNotifyUpdate;

  /// Called after local state is updated.
  ValueChanged<WRITEABLE?>? afterLocalNotifyUpdate;

  /// Future that completes when the service is ready.
  Future<void> get isReady => _isReady.future;

  /// Listenable for the document state.
  Listenable get listenable => _doc;

  /// Value listenable for the document state.
  ValueListenable<WRITEABLE> get doc => _doc;

  /// Whether a document exists in local state.

  /// The document ID.
  String get id => _doc.value.id;

  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\
  // ⚙️ LOCAL MUTATORS ------------------------------------------------------------------------ \\

  /// Clears the local document state.
  void clearLocalDoc({bool doNotifyListeners = true}) {
    log.debug('Clearing local doc');
    if (doNotifyListeners) {
      beforeLocalNotifyUpdate?.call(null);
    }
    _doc.update(
      defaultValue.call(vars(), collection, this),
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
      defaultValue.call(vars(), collection, this),
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
  WRITEABLE createLocalDoc({
    required CreateDocDef<WRITEABLE> doc,
    bool doNotifyListeners = true,
  }) {
    final pDoc = doc(vars());
    log.debug('Creating local doc with id: ${pDoc.id}');
    if (doNotifyListeners) {
      beforeLocalNotifyUpdate?.call(pDoc);
    }
    _doc.update(pDoc, doNotifyListeners: doNotifyListeners);
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
  WRITEABLE updateLocalDoc({
    required String id,
    required UpdateDocDef<WRITEABLE> doc,
    bool doNotifyListeners = true,
  }) {
    final pDoc = doc(_doc.value, vars(id: id));
    log.debug('Updating local doc with id: ${pDoc.id}');
    if (doNotifyListeners) {
      beforeLocalNotifyUpdate?.call(pDoc);
    }
    _doc.update(pDoc, doNotifyListeners: doNotifyListeners);
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
  WRITEABLE upsertLocalDoc({
    required String id,
    required UpsertDocDef<WRITEABLE> doc,
    bool doNotifyListeners = true,
  }) {
    final pDoc = doc(_doc.value, vars(id: id));
    log.debug('Upserting local doc with id: $id');
    if (doNotifyListeners) {
      beforeLocalNotifyUpdate?.call(pDoc);
    }
    _doc.update(pDoc, doNotifyListeners: doNotifyListeners);
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
  Future<TurboResponse<WRITEABLE>> updateDoc({
    Transaction? transaction,
    required String id,
    required UpdateDocDef<WRITEABLE> doc,
    TWriteable Function(WRITEABLE doc)? remoteUpdateRequestBuilder,
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
  Future<TurboResponse<WRITEABLE>> createDoc({
    Transaction? transaction,
    required CreateDocDef<WRITEABLE> doc,
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
  Future<TurboResponse<WRITEABLE>> upsertDoc({
    Transaction? transaction,
    required String id,
    required UpsertDocDef<WRITEABLE> doc,
    TWriteableId Function(WRITEABLE doc)? remoteUpdateRequestBuilder,
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
