import 'package:firebase_auth/firebase_auth.dart';
import 'package:turbo_firestore_api/abstracts/t_model.dart';
import 'package:turbo_firestore_api/services/t_doc_service.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

/// A document service that allows notification after synchronizing data.
///
/// Extends [TDocService] to provide a hook for notifying after
/// the local state has been updated with new data from Firestore.
///
/// Type Parameters:
/// - [DTO] - The document type, must extend [TWriteableId]
abstract class TPostDocService<DTO extends TWriteableId, MODEL extends TModel<DTO>>
    extends TDocService<DTO, MODEL> {
  /// Creates a new [TPostDocService] instance.
  TPostDocService({
    required super.collection,
    required super.defaultValue,
    required super.modelBuilder,
    super.onMissingRemoteValue,
    super.apiBuilder,
    super.initialValue,
    super.initialiseStream = true,
    super.streamBuilder,
    super.afterLocalNotifyUpdate,
    super.beforeLocalNotifyUpdate,
    super.firestoreCacheService,
  });

  /// Called after the local state has been updated with new data.
  ///
  /// Use this method to perform any necessary operations after
  /// the document has been synchronized with local state.
  ///
  /// Parameters:
  /// - [doc] - The new document from Firestore
  Future<void> afterSyncNotifyUpdate(DTO? doc);

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
  Future<void> Function(DTO? value, User? user) get onData {
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
