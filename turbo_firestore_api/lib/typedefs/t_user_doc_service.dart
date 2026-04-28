import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:turbo_firestore_api/abstracts/t_model.dart';
import 'package:turbo_firestore_api/enums/t_user_id_location.dart';
import 'package:turbo_firestore_api/turbo_firestore_api.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';
import 'package:turbolytics/turbolytics.dart';

class TUserDocService<DTO extends TWriteableId, MODEL extends TModel<DTO>> extends TDocService<DTO, MODEL>
    with Turbolytics {
  TUserDocService({
    required super.collection,
    required super.defaultValue,
    this.userIdLocation = UserIdLocation.docId,
    super.apiBuilder,
    super.streamBuilder,
    super.initialValue,
    super.initialiseStream = true,
  });

  final UserIdLocation userIdLocation;

  @override
  Stream<DTO?> Function(User user) get stream =>
      (user) =>
          streamBuilder?.call(user, api, this) ??
          switch (userIdLocation) {
            UserIdLocation.docId => api.streamByDocIdWithConverter(
              id: user.uid,
            ),
            UserIdLocation.field => api.streamByQueryWithConverter(
              whereDescription: '${api.userIdFieldName} == ${user.uid}',
              collectionReferenceQuery: (collectionReference) => collectionReference.where(
                api.userIdFieldName,
                isEqualTo: user.uid,
              ),
            ).map((event) => event.firstOrNull),
          };
}
