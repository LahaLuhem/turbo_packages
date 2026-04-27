import 'package:firebase_auth/firebase_auth.dart';
import 'package:turbo_firestore_api/abstracts/i_firestore_cache_service.dart';
import 'package:turbo_firestore_api/apis/t_firestore_api.dart';
import 'package:turbo_firestore_api/factories/t_api_factory.dart';
import 'package:turbo_firestore_api/services/t_collection_service.dart';
import 'package:turbo_firestore_api/services/t_doc_service.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

typedef TCollectionApiBuilderDef<WRITEABLE extends TWriteableId> =
    TFirestoreApi<WRITEABLE> Function(
      User? user,
      TApiFactory<WRITEABLE> factory,
      TCollectionService<WRITEABLE> service,
      IFirestoreCacheService? firestoreCacheService,
    );

typedef TDocApiBuilderDef<WRITEABLE extends TWriteableId> =
    TFirestoreApi<WRITEABLE> Function(
      User? user,
      TApiFactory<WRITEABLE> collection,
      TDocService<WRITEABLE> service,
      IFirestoreCacheService? firestoreCacheService,
    );
