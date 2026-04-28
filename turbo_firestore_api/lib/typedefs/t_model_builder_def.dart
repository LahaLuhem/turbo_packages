import 'package:turbo_firestore_api/abstracts/t_model.dart';
import 'package:turbo_firestore_api/apis/t_firestore_api.dart';
import 'package:turbo_firestore_api/services/t_collection_service.dart';
import 'package:turbo_firestore_api/services/t_doc_service.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

typedef TModelBuilderDef<DTO extends TWriteableId, MODEL extends TModel<DTO>> =
    MODEL Function(
      DTO dto,
    );

typedef TCollectionModelBuilderDef<DTO extends TWriteableId, MODEL extends TModel<DTO>> =
    MODEL Function(
      TFirestoreApi<DTO> api,
      TCollectionService<DTO, MODEL> service,
      DTO dto,
    );

typedef TDocModelBuilderDef<DTO extends TWriteableId, MODEL extends TModel<DTO>> =
    MODEL Function(
      TFirestoreApi<DTO> api,
      TDocService<DTO, MODEL> service,
      DTO dto,
    );
