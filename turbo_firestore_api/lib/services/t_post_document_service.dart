import 'package:firebase_auth/firebase_auth.dart';
import 'package:turbo_firestore_api/apis/t_firestore_api.dart';
import 'package:turbo_firestore_api/services/t_document_service.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

/// A document service that allows notification after synchronizing data.
///
/// Extends [TDocumentService] to provide a hook for notifying after
/// the local state has been updated with new data from Firestore.
///
/// Type Parameters:
/// - [T] - The document type, must extend [TWriteableId]
/// - [API] - The Firestore API type, must extend [TFirestoreApi]
abstract class TPostDocumentService<
  T extends TWriteableId,
  API extends TFirestoreApi<T>
>
    extends TDocumentService<T, API> {
  /// Creates a new [TPostDocumentService] instance.
  TPostDocumentService({required super.api});

  /// Called after the local state has been updated with new data.
  ///
  /// Use this method to perform any necessary operations after
  /// the document has been synchronized with local state.
  ///
  /// Parameters:
  /// - [doc] - The new document from Firestore
  Future<void> afterSyncNotifyUpdate(T? doc);

  /// Handles incoming data updates from Firestore with post-sync notification.
  ///
  /// This callback is triggered when:
  /// - New document data is received from Firestore
  /// - The user's authentication state changes
  ///
  /// The method:
  /// - Updates local state with new document data if user is authenticated
  /// - Marks the service as ready after first update
  /// - Notifies after sync via [afterSyncNotifyUpdate]
  /// - Clears local state if user is not authenticated
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
          final pDoc = upsertLocalDoc(
            id: value.id,
            doc: (current, _) => value,
          );
          markAsReady();
          await afterSyncNotifyUpdate(pDoc);
        } else {
          clearLocalDoc();
          await afterSyncNotifyUpdate(value);
        }
        log.debug('Updated doc');
      } else {
        log.debug('User is null, clearing doc');
        clearLocalDoc();
        await afterSyncNotifyUpdate(null);
      }
    };
  }
}
