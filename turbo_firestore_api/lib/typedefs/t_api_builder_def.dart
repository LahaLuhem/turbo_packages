import 'package:firebase_auth/firebase_auth.dart';
import 'package:turbo_firestore_api/abstracts/i_firestore_cache_service.dart';
import 'package:turbo_firestore_api/abstracts/t_model.dart';
import 'package:turbo_firestore_api/apis/t_firestore_api.dart';
import 'package:turbo_firestore_api/factories/t_api_factory.dart';
import 'package:turbo_firestore_api/services/t_collection_service.dart';
import 'package:turbo_firestore_api/services/t_doc_service.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

typedef TCollectionApiBuilderDef<DTO extends TWriteableId, MODEL extends TModel<DTO>> =
    TFirestoreApi<DTO, MODEL> Function(
      User? user,
      TApiFactory<DTO, MODEL> factory,
      TCollectionService<DTO, MODEL> service,
      IFirestoreCacheService? firestoreCacheService,
    );

typedef TDocApiBuilderDef<DTO extends TWriteableId, MODEL extends TModel<DTO>> =
    TFirestoreApi<DTO, MODEL> Function(
      User? user,
      TApiFactory<DTO, MODEL> collection,
      TDocService<DTO, MODEL> service,
      IFirestoreCacheService? firestoreCacheService,
    );
