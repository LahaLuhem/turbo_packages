import 'package:turbo_firestore_api/abstracts/t_model.dart';
import 'package:turbo_firestore_api/services/t_collection_service.dart';
import 'package:turbo_firestore_api/services/t_doc_service.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

typedef TModelBuilderDef<DTO extends TWriteableId, MODEL extends TModel<DTO>> =
    MODEL Function(
      DTO dto,
    );

typedef TCollectionModelBuilderDef<DTO extends TWriteableId, MODEL extends TModel<DTO>> =
    MODEL Function(
      TCollectionService<DTO, MODEL> service,
      dynamic state,
      DTO dto,
    );

typedef TDocModelBuilderDef<DTO extends TWriteableId, MODEL extends TModel<DTO>> =
    MODEL Function(
      TDocService<DTO, MODEL> service,
      dynamic state,
      DTO dto,
    );
