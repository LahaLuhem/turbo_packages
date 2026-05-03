import 'package:turbo_firestore_api/abstracts/t_model.dart';
import 'package:turbo_firestore_api/models/t_firestore_collection.dart';
import 'package:turbo_firestore_api/models/t_vars.dart';
import 'package:turbo_firestore_api/services/t_collection_service.dart';
import 'package:turbo_firestore_api/services/t_doc_service.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

typedef TCollectionValueBuilderDef<
  DTO extends TWriteableId,
  MODEL extends TModel<DTO>
> =
    List<DTO> Function(
      TVars vars,
      TFirestoreCollection<DTO> collection,
      TCollectionService<DTO, MODEL> service,
    );

typedef TDocValueBuilderDef<
  DTO extends TWriteableId,
  MODEL extends TModel<DTO>
> =
    DTO Function(
      TVars vars,
      TFirestoreCollection<DTO> collection,
      TDocService<DTO, MODEL> service,
    );
