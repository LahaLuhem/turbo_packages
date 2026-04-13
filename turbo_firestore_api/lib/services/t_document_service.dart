import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' hide Type;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:turbo_firestore_api/apis/t_firestore_api.dart';
import 'package:turbo_firestore_api/constants/t_values.dart';
import 'package:turbo_firestore_api/exceptions/t_firestore_exception.dart';
import 'package:turbo_firestore_api/models/t_auth_vars.dart';
import 'package:turbo_firestore_api/services/t_auth_sync_service.dart';
import 'package:turbo_firestore_api/typedefs/create_doc_def.dart';
import 'package:turbo_firestore_api/typedefs/t_locator_def.dart';
import 'package:turbo_firestore_api/typedefs/update_doc_def.dart';
import 'package:turbo_firestore_api/typedefs/upsert_doc_def.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:turbo_serializable/abstracts/t_writeable.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';
import 'package:turbolytics/turbolytics.dart';

import '../extensions/completer_extension.dart';

part 'after_sync_t_document_service.dart';
part 'before_after_sync_t_document_service.dart';
part 'before_sync_t_document_service.dart';

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
/// - [T] - The document type, must extend [TWriteableId]
/// - [API] - The Firestore API type, must extend [TFirestoreApi]
abstract class TDocumentService<
  T extends TWriteableId,
  API extends TFirestoreApi<T>
>
    extends TAuthSyncService<T?>
    with Turbolytics {
  /// Creates a new [TDocumentService] instance.
  ///
  /// Parameters:
  /// - [api] - The Firestore API instance for remote operations
  TDocumentService({
    required this.api,
  });

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\
  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  /// The Firestore API instance used for remote operations.
  final API api;

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

  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

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
  Future<void> Function(T? value, User? user) get onData {
    return (value, user) async {
      if (user != null) {
        log.debug('Updating doc for user ${user.uid}');
        if (value != null) {
          upsertLocalDoc(
            id: value.id,
            doc: (current, _) => value,
          );
        } else {
          _doc.update(null);
        }
        _isReady.completeIfNotComplete();
        log.debug('Updated doc');
      } else {
        log.debug('User is null, clearing doc');
        _doc.update(null);
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

  /// Local state for the document.
  late final _doc = TNotifier<T?>(
    initialValueLocator?.call() ?? defaultValueLocator?.call(),
    forceUpdate: true,
  );

  /// Completer that resolves when the service is ready.
  final _isReady = Completer<void>();

  // 🛠 UTIL ---------------------------------------------------------------------------------- \\
  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// Returns a new instance of [V] with basic variables filled in.
  V turboVars<V extends TAuthVars>({String? id}) {
    return TAuthVars(
          id: id ?? api.genId,
          now: DateTime.now(),
          userId: cachedUserId ?? TValues.noAuthId,
        )
        as V;
  }

  /// Function to provide initial document value.
  TLocatorDef<T>? initialValueLocator;

  /// Function to provide default document value.
  TLocatorDef<T>? defaultValueLocator;

  /// Called before local state is updated.
  ValueChanged<T?>? beforeLocalNotifyUpdate;

  /// Called after local state is updated.
  ValueChanged<T?>? afterLocalNotifyUpdate;

  /// Future that completes when the service is ready.
  Future<void> get isReady => _isReady.future;

  /// Listenable for the document state.
  Listenable get listenable => _doc;

  /// Value listenable for the document state.
  ValueListenable<T?> get doc => _doc;

  /// Whether a document exists in local state.

  /// The document ID.
  String? get id => _doc.value?.id;

  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\
  // ⚙️ LOCAL MUTATORS ------------------------------------------------------------------------ \\

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
    _doc.update(null, doNotifyListeners: doNotifyListeners);
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
  T createLocalDoc({
    required CreateDocDef<T> doc,
    bool doNotifyListeners = true,
  }) {
    final pDoc = doc(turboVars());
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
  T updateLocalDoc({
    required String id,
    required UpdateDocDef<T> doc,
    bool doNotifyListeners = true,
  }) {
    if (_doc.value == null) {
      throw StateError('Cannot update non-existent document');
    }
    final pDoc = doc(_doc.value!, turboVars(id: id));
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
  T upsertLocalDoc({
    required String id,
    required UpsertDocDef<T> doc,
    bool doNotifyListeners = true,
  }) {
    final pDoc = doc(_doc.value, turboVars(id: id));
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
      final doc = _doc.value;
      if (doc == null) {
        throw StateError('Document not found');
      }
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
  Future<TurboResponse<T>> updateDoc({
    Transaction? transaction,
    required String id,
    required UpdateDocDef<T> doc,
    TWriteable Function(T doc)? remoteUpdateRequestBuilder,
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
  Future<TurboResponse<T>> createDoc({
    Transaction? transaction,
    required CreateDocDef<T> doc,
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
  Future<TurboResponse<T>> upsertDoc({
    Transaction? transaction,
    required String id,
    required UpsertDocDef<T> doc,
    TWriteableId Function(T doc)? remoteUpdateRequestBuilder,
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
        writeable:
            remoteUpdateRequestBuilder?.call(pDoc) ?? pDoc as TWriteableId,
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
