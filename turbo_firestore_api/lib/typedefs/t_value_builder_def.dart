import 'package:firebase_auth/firebase_auth.dart';
import 'package:turbo_firestore_api/models/t_firestore_collection.dart';
import 'package:turbo_firestore_api/models/t_vars.dart';
import 'package:turbo_firestore_api/services/t_collection_service.dart';
import 'package:turbo_firestore_api/services/t_doc_service.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

typedef TCollectionValueBuilderDef<WRITEABLE extends TWriteableId> =
    List<WRITEABLE> Function(
      TVars vars,
      TFirestoreCollection<WRITEABLE> collection,
      TCollectionService<WRITEABLE> service,
    );

typedef TDocValueBuilderDef<WRITEABLE extends TWriteableId> =
    WRITEABLE Function(
      TVars vars,
      TFirestoreCollection<WRITEABLE> collection,
      TDocService<WRITEABLE> service,
    );
