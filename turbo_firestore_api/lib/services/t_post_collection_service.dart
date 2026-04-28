import 'package:firebase_auth/firebase_auth.dart';
import 'package:turbo_firestore_api/abstracts/t_model.dart';
import 'package:turbo_firestore_api/models/t_model_docs.dart';
import 'package:turbo_firestore_api/services/t_collection_service.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

/// A collection service that allows notification after synchronizing data.
///
/// Extends [TCollectionService] to provide a hook for notifying after
/// the local state has been updated with new data from Firestore.
///
/// Type Parameters:
/// - [DTO] - The document type, must extend [TWriteableId]
abstract class TPostCollectionService<DTO extends TWriteableId, MODEL extends TModel<DTO>>
    extends TCollectionService<DTO, MODEL> {
  /// Creates a new [TPostCollectionService] instance.
  TPostCollectionService({
    required super.collection,
    required super.modelBuilder,
    super.apiBuilder,
    super.initialiseStream = true,
    super.defaultValue,
    super.firestoreCacheService,
    super.initialValue,
    super.modelDocsBuilder,
    super.streamBuilder,
  });

  /// Called after the local state has been updated with new data.
  ///
  /// Use this method to perform any necessary operations after
  /// the documents have been synchronized with local state.
  ///
  /// Parameters:
  /// - [docs] - The new documents from Firestore
  Future<void> afterSyncNotifyUpdate(List<DTO> docs);

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
  /// - [value] - The new document values from Firestore
  /// - [user] - The current Firebase user
  @override
  Future<void> Function(List<DTO>? value, User? user) get onData {
    return (value, user) async {
      final docs = value ?? defaultValues();
      if (user != null) {
        log.debug('Updating docs for user ${user.uid}');
        docsNotifier.update(
          TModelDocs.fromDtos(
            dtos: docs,
            modelBuilder: (dto) => modelBuilder(this, null, dto),
            sortFilteredListsMap: initialSortFilteredListsMap?.call(),
          ),
        );
        markAsReady();
        await afterSyncNotifyUpdate(docs);
        log.debug('Updated ${docs.length} docs');
      } else {
        log.debug('User is null, clearing docs');
        resetLocalDocs();
        await afterSyncNotifyUpdate([]);
      }
    };
  }
}
