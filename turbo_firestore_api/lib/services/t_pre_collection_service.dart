import 'package:firebase_auth/firebase_auth.dart';
import 'package:turbo_firestore_api/abstracts/t_model.dart';
import 'package:turbo_firestore_api/models/t_model_docs.dart';
import 'package:turbo_firestore_api/services/t_collection_service.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

/// A collection service that allows notification before synchronizing data.
///
/// Extends [TCollectionService] to provide a hook for notifying before
/// the local state is updated with new data from Firestore.
///
/// Type Parameters:
/// - [DTO] - The document type, must extend [TWriteableId]
abstract class TPreCollectionService<
  DTO extends TWriteableId,
  MODEL extends TModel<DTO>
>
    extends TCollectionService<DTO, MODEL> {
  /// Creates a new [TPreCollectionService] instance.
  TPreCollectionService({
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

  /// Called before the local state is updated with new data.
  ///
  /// Use this method to perform any necessary operations before
  /// the documents are synchronized with local state.
  ///
  /// Parameters:
  /// - [docs] - The new documents from Firestore
  Future<void> beforeSyncNotifyUpdate(List<DTO> docs);

  /// Handles incoming data updates from Firestore with pre-sync notification.
  ///
  /// This callback is triggered when:
  /// - New document data is received from Firestore
  /// - The user's authentication state changes
  ///
  /// The method:
  /// - Notifies before sync via [beforeSyncNotifyUpdate] if user is authenticated
  /// - Updates local state with new document data
  /// - Marks the service as ready after first update
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
        await beforeSyncNotifyUpdate(docs);
        docsNotifier.update(
          TModelDocs.fromDtos(
            dtos: docs,
            modelBuilder: (dto) => modelBuilder(this, null, dto),
            sortFilteredListsMap: initialSortFilteredListsMap?.call(),
          ),
        );
        markAsReady();
        log.debug('Updated ${docs.length} docs');
      } else {
        log.debug('User is null, clearing docs');
        await beforeSyncNotifyUpdate([]);
        resetLocalDocs();
      }
    };
  }
}
