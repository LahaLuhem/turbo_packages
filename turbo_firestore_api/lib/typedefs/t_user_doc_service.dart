import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:turbo_firestore_api/turbo_firestore_api.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';
import 'package:turbolytics/turbolytics.dart';

class TUserDocService<WRITEABLE extends TWriteableId> extends TDocService<WRITEABLE>
    with Turbolytics {
  TUserDocService({
    required super.collection,
    required super.defaultValue,
    super.apiBuilder,
    super.streamBuilder,
    super.initialValue,
    super.initialiseStream = true,
  });

  @override
  Stream<WRITEABLE?> Function(User user) get stream =>
      (user) =>
          streamBuilder?.call(user, api, this) ??
          api.streamByDocIdWithConverter(
            id: user.uid,
          );
}
