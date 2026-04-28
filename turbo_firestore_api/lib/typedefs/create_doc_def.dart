import 'package:turbo_firestore_api/abstracts/t_model.dart';
import 'package:turbo_firestore_api/models/t_vars.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

typedef CreateDocDef<DTO extends TWriteableId, MODEL extends TModel<DTO>> =
    DTO Function(TVars vars);
