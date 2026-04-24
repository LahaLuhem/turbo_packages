import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:turbo_firestore_api/turbo_firestore_api.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';
import 'package:turbolytics/turbolytics.dart';

class TUserCollectionService<WRITEABLE extends TWriteableId> extends TCollectionService<WRITEABLE>
    with Turbolytics {
  TUserCollectionService({
    required super.collection,
    super.apiBuilder,
    super.streamBuilder,
    super.initialValue,
    super.defaultValue,
    super.initialiseStream = true,
  });

  @override
  Stream<List<WRITEABLE>> Function(User user) get stream =>
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
