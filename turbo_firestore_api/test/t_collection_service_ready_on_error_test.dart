import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_firestore_api/apis/t_firestore_api.dart';
import 'package:turbo_firestore_api/enums/t_operation_type.dart';
import 'package:turbo_firestore_api/exceptions/t_firestore_exception.dart';
import 'package:turbo_firestore_api/services/t_collection_service.dart';
import 'package:turbo_serializable/abstracts/t_writeable_id.dart';

class _FakeWriteable extends TWriteableId {
  _FakeWriteable(this.id);

  @override
  final String id;

  @override
  Map<String, dynamic> toJson() => {'id': id};
}

class _FakeFirestoreApi extends TFirestoreApi<_FakeWriteable> {
  _FakeFirestoreApi()
    : super(
        firebaseFirestore: FakeFirebaseFirestore(),
        collectionPath: () => 'fakeCollection',
        toJson: (value) => value.toJson(),
        fromJson: (json) => _FakeWriteable(json['id'] as String),
      );
}

class _FakeCollectionService
    extends TCollectionService<_FakeWriteable, _FakeFirestoreApi> {
  _FakeCollectionService()
    : super(api: _FakeFirestoreApi(), initialiseStream: false);

  @override
  FutureOr<Stream<List<_FakeWriteable>?>> Function(User user) get stream =>
      (user) async => const Stream.empty();
}

void main() {
  test(
    'Given a collection service stream error, '
    'When onError is called before any successful data event, '
    'Then isReady still completes so dependent UI does not wait forever',
    () async {
      final service = _FakeCollectionService();

      service.onError(
        TurboFirestorePermissionDeniedException(
          message: 'Denied',
          originalException: FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
            message: 'Denied',
          ),
          operationType: TOperationType.stream,
        ),
      );

      await expectLater(
        service.isReady.timeout(const Duration(milliseconds: 100)),
        completes,
      );

      await service.dispose();
    },
  );
}
