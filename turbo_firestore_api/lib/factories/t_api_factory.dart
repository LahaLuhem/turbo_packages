import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:turbo_firestore_api/abstracts/i_firestore_cache_service.dart';
import 'package:turbo_firestore_api/apis/t_firestore_api.dart';
import 'package:turbo_firestore_api/models/t_firestore_collection.dart';
import 'package:turbo_firestore_api/util/t_firestore_logger.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

class TApiFactory<DTO extends TWriteableId> {
  TApiFactory({required TFirestoreCollection<DTO> collection}) : _collection = collection;

  final TFirestoreCollection<DTO> _collection;

  TFirestoreApi<DTO> create({
    FirebaseFirestore? firebaseFirestore,
    GetOptions? getOptions,
    String Function(String collectionName)? path,
    TFirestoreLogger? logger,
    bool? isCollectionGroup,
    IFirestoreCacheService? firestoreCacheService,
  }) => _collection.api(
    firebaseFirestore: firebaseFirestore,
    firestoreCacheService: firestoreCacheService,
    getOptions: getOptions,
    isCollectionGroup: isCollectionGroup,
    logger: logger,
    path: path,
  );
}
