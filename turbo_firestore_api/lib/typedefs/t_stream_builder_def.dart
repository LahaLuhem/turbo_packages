import 'package:firebase_auth/firebase_auth.dart';
import 'package:turbo_firestore_api/abstracts/t_model.dart';
import 'package:turbo_firestore_api/turbo_firestore_api.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

typedef TCollectionStreamBuilderDef<DTO extends TWriteableId, MODEL extends TModel<DTO>> =
    Stream<List<DTO>> Function(
      User user,
      TFirestoreApi<DTO> api,
      TCollectionService<DTO, MODEL> service,
    );

typedef TDocStreamBuilderDef<DTO extends TWriteableId, MODEL extends TModel<DTO>> =
    Stream<DTO?> Function(
      User user,
      TFirestoreApi<DTO> api,
      TDocService<DTO, MODEL> service,
    );
