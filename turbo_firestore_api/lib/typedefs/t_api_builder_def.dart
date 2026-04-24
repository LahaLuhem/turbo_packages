import 'package:turbo_firestore_api/apis/t_firestore_api.dart';
import 'package:turbo_firestore_api/models/t_firestore_collection.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

typedef TApiBuilderDef<WRITEABLE extends TWriteableId> =
    TFirestoreApi<WRITEABLE> Function(
      TFirestoreCollection<WRITEABLE> collection,
    );
