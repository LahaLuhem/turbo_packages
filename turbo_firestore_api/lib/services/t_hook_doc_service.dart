import 'package:firebase_auth/firebase_auth.dart';
import 'package:turbo_firestore_api/abstracts/t_model.dart';
import 'package:turbo_firestore_api/services/t_doc_service.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

/// A document service that allows notification both before and after synchronizing data.
///
/// Extends [TDocService] to provide hooks for notifying both before and after
/// the local state is updated with new data from Firestore.
///
/// Type Parameters:
/// - [DTO] - The document type, must extend [TWriteableId]
abstract class THookDocService<
  DTO extends TWriteableId,
  MODEL extends TModel<DTO>
>
    extends TDocService<DTO, MODEL> {
  /// Creates a new [THookDocService] instance.
  THookDocService({
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

  /// Called before the local state is updated with new data.
  ///
  /// Use this method to perform any necessary operations before
  /// the document is synchronized with local state.
  ///
  /// Parameters:
  /// - [doc] - The new document from Firestore
  Future<void> beforeSyncNotifyUpdate(DTO? doc);

  /// Called after the local state has been updated with new data.
  ///
  /// Use this method to perform any necessary operations after
  /// the document has been synchronized with local state.
  ///
  /// Parameters:
  /// - [doc] - The new document from Firestore
  Future<void> afterSyncNotifyUpdate(DTO? doc);

  /// Handles incoming data updates from Firestore with pre and post-sync notifications.
  ///
  /// This callback is triggered when:
  /// - New document data is received from Firestore
  /// - The user's authentication state changes
  ///
  /// The method:
  /// - Notifies before sync via [beforeSyncNotifyUpdate] if user is authenticated
  /// - Updates local state with new document data
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
          await beforeSyncNotifyUpdate(value);
          upsertLocalDoc(
            id: value.id,
            doc: (current, _) => value,
          );
          markAsReady();
          await afterSyncNotifyUpdate(value);
        } else {
          await beforeSyncNotifyUpdate(null);
          clearLocalDoc();
          await afterSyncNotifyUpdate(null);
        }
        log.debug('Updated doc');
      } else {
        log.debug('User is null, clearing doc');
        await beforeSyncNotifyUpdate(null);
        clearLocalDoc();
        await afterSyncNotifyUpdate(null);
      }
    };
  }
}
