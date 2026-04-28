import 'package:turbo_firestore_api/abstracts/t_model.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

typedef TModelBuilderDef<DTO extends TWriteableId, MODEL extends TModel<DTO>> =
    MODEL Function(DTO dto);
