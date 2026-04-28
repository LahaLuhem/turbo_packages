import 'package:turbo_firestore_api/abstracts/t_model.dart';
import 'package:turbo_firestore_api/apis/t_firestore_api.dart';
import 'package:turbo_firestore_api/models/t_model_docs.dart';
import 'package:turbo_firestore_api/services/t_collection_service.dart';
import 'package:turbo_firestore_api/typedefs/t_model_builder_def.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

typedef TModelDocsBuilderDef<DTO extends TWriteableId, MODEL extends TModel<DTO>> =
    TModelDocs<DTO, MODEL> Function(
      TFirestoreApi<DTO> api,
      TCollectionService<DTO, MODEL> service,
      TCollectionModelBuilderDef<DTO, MODEL> modelBuilder,
      List<DTO> dtos,
    );
