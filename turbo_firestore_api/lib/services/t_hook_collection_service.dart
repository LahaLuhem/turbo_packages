import 'package:firebase_auth/firebase_auth.dart';
import 'package:turbo_firestore_api/models/t_id_docs.dart';
import 'package:turbo_firestore_api/services/t_collection_service.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

/// A collection service that allows notification both before and after synchronizing data.
///
/// Extends [TCollectionService] to provide hooks for notifying both before and after
/// the local state is updated with new data from Firestore.
///
/// Type Parameters:
/// - [WRITEABLE] - The document type, must extend [TWriteableId]
abstract class THookCollectionService<WRITEABLE extends TWriteableId>
    extends TCollectionService<WRITEABLE> {
  /// Creates a new [THookCollectionService] instance.
  THookCollectionService({
    required super.collection,
    super.apiBuilder,
    super.initialiseStream = true,
  });

  /// Called before the local state is updated with new data.
  ///
  /// Use this method to perform any necessary operations before
  /// the documents are synchronized with local state.
  ///
  /// Parameters:
  /// - [docs] - The new documents from Firestore
  Future<void> beforeSyncNotifyUpdate(List<WRITEABLE> docs);

  /// Called after the local state has been updated with new data.
  ///
  /// Use this method to perform any necessary operations after
  /// the documents have been synchronized with local state.
  ///
  /// Parameters:
  /// - [docs] - The new documents from Firestore
  Future<void> afterSyncNotifyUpdate(List<WRITEABLE> docs);

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
  /// - [value] - The new document values from Firestore
  /// - [user] - The current Firebase user
  @override
  Future<void> Function(List<WRITEABLE>? value, User? user) get onData {
    return (value, user) async {
      final docs = value ?? defaultValues();
      if (user != null) {
        log.debug('Updating docs for user ${user.uid}');
        await beforeSyncNotifyUpdate(docs);
        docsNotifier.update(TIdDocs(docs));
        markAsReady();
        await afterSyncNotifyUpdate(docs);
        log.debug('Updated ${docs.length} docs');
      } else {
        log.debug('User is null, clearing docs');
        await beforeSyncNotifyUpdate([]);
        resetLocalDocs();
        await afterSyncNotifyUpdate([]);
      }
    };
  }
}
