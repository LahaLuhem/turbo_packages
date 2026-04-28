import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:turbo_firestore_api/abstracts/t_model.dart';
import 'package:turbo_firestore_api/turbo_firestore_api.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';
import 'package:turbolytics/turbolytics.dart';

class TUserCollectionService<DTO extends TWriteableId, MODEL extends TModel<DTO>>
    extends TCollectionService<DTO, MODEL>
    with Turbolytics {
  TUserCollectionService({
    required super.collection,
    required super.modelBuilder,
    super.apiBuilder,
    super.streamBuilder,
    super.initialValue,
    super.defaultValue,
    super.initialiseStream = true,
    super.firestoreCacheService,
    super.modelDocsBuilder,
  });

  @override
  Stream<List<DTO>> Function(User user) get stream =>
      (user) =>
          streamBuilder?.call(user, api, this) ??
          api.streamByQueryWithConverter(
            whereDescription: '${api.userIdFieldName} == ${user.uid}',
            collectionReferenceQuery: (collectionReference) => collectionReference.where(
              api.userIdFieldName,
              isEqualTo: user.uid,
            ),
          );
}
