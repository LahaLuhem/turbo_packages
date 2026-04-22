import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_firestore_api/apis/t_dummy_firestore_api.dart';
import 'package:turbo_response/turbo_response.dart';
import 'package:turbo_serializable/abstracts/t_writeable.dart';

// ---------------------------------------------------------------------------
// Synthetic fixture DTO
// ---------------------------------------------------------------------------

class _SimpleDto extends TWriteable {
  _SimpleDto({
    required this.id,
    required this.name,
    required this.age,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory _SimpleDto.fromJson(Map<String, dynamic> json) => _SimpleDto(
    id: json['id'] as String,
    name: json['name'] as String,
    age: json['age'] as int,
    isActive: json['isActive'] as bool,
    createdAt: json['createdAt'] as Timestamp?,
    updatedAt: json['updatedAt'] as Timestamp?,
  );

  final String id;
  final String name;
  final int age;
  final bool isActive;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt!,
      if (updatedAt != null) 'updatedAt': updatedAt!,
    };
  }
}

// ---------------------------------------------------------------------------
// Synthetic writeables
// ---------------------------------------------------------------------------

class _CreateWriteable extends TWriteable {
  _CreateWriteable({
    required this.name,
    required this.age,
    required this.isActive,
  });

  final String name;
  final int age;
  final bool isActive;

  @override
  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'isActive': isActive,
  };
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

TDummyFirestoreApi<_SimpleDto> _createApi({
  int? seed,
  double randomFailurePercentage = 0,
  Duration dummyDelayDuration = Duration.zero,
  int defaultCollectionSize = 0,
}) => TDummyFirestoreApi<_SimpleDto>(
  firebaseFirestore: FakeFirebaseFirestore(),
  collectionPath: () => 'testCollection',
  fromJson: _SimpleDto.fromJson,
  toJson: null,
  seed: seed,
  randomFailurePercentage: randomFailurePercentage,
  dummyDelayDuration: dummyDelayDuration,
  defaultCollectionSize: defaultCollectionSize,
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TDummyFirestoreApi DocumentReference', () {
    test(
      'Given createDoc returns a DocumentReference, '
      'When .id and .path are read, '
      'Then they match the expected id and path',
      () async {
        final api = _createApi(seed: 42);
        final pathSnapshot = dummyPathSnapshotForTesting(api);

        final response = await api.createDoc(
          writeable: _CreateWriteable(name: 'Alice', age: 30, isActive: true),
          id: 'doc-1',
        );

        final docRef = (response as Success<DocumentReference>).result;
        expect(docRef.id, 'doc-1');
        expect(docRef.path, '$pathSnapshot/doc-1');
      },
    );

    test(
      'Given a DocumentReference from createDoc, '
      'When .get() is awaited, '
      'Then the snapshot exists and contains the created entity data',
      () async {
        final api = _createApi(seed: 42);

        final response = await api.createDoc(
          writeable: _CreateWriteable(name: 'Alice', age: 30, isActive: true),
          id: 'doc-1',
        );

        final docRef = (response as Success<DocumentReference>).result;
        final snapshot = await docRef.get();

        expect(snapshot.exists, isTrue);
        expect(snapshot.id, 'doc-1');

        final data = snapshot.data() as Map<String, dynamic>;
        expect(data['name'], 'Alice');
        expect(data['age'], 30);
        expect(data['isActive'], isTrue);
      },
    );

    test(
      'Given a DocumentReference, '
      'When .update({name: newValue}) is awaited, '
      'Then a subsequent .get() reflects the updated value',
      () async {
        final api = _createApi(seed: 42);

        final response = await api.createDoc(
          writeable: _CreateWriteable(name: 'Alice', age: 30, isActive: true),
          id: 'doc-1',
        );

        final docRef = (response as Success<DocumentReference>).result;
        await docRef.update({'name': 'Alice Updated'});

        final snapshot = await docRef.get();
        final data = snapshot.data() as Map<String, dynamic>;
        expect(data['name'], 'Alice Updated');
        // Unchanged fields preserved.
        expect(data['age'], 30);
        expect(data['isActive'], isTrue);
        // updatedAt timestamp applied.
        expect(data['updatedAt'], isA<Timestamp>());
      },
    );

    test(
      'Given a DocumentReference, '
      'When .delete() is awaited, '
      'Then a subsequent .get() yields a snapshot with exists = false',
      () async {
        final api = _createApi(seed: 42);

        final response = await api.createDoc(
          writeable: _CreateWriteable(name: 'Alice', age: 30, isActive: true),
          id: 'doc-1',
        );

        final docRef = (response as Success<DocumentReference>).result;
        await docRef.delete();

        final snapshot = await docRef.get();
        expect(snapshot.exists, isFalse);
        expect(snapshot.data(), isNull);
      },
    );

    test(
      'Given an active .snapshots() subscription on a DocumentReference, '
      'When .delete() is called on the same id, '
      'Then the subscriber receives a snapshot with exists = false',
      () async {
        final api = _createApi(seed: 42);

        final response = await api.createDoc(
          writeable: _CreateWriteable(name: 'Alice', age: 30, isActive: true),
          id: 'doc-1',
        );

        final docRef = (response as Success<DocumentReference>).result;
        final snapshots = <DocumentSnapshot>[];
        final initialEmission = Completer<void>();
        final sub = docRef.snapshots().listen((snapshot) {
          snapshots.add(snapshot);
          if (!initialEmission.isCompleted) initialEmission.complete();
        });

        // Wait for initial snapshot.
        await initialEmission.future.timeout(const Duration(seconds: 2));
        expect(snapshots.length, 1);
        expect(snapshots.first.exists, isTrue);

        // Delete the document.
        await docRef.delete();

        // Allow stream propagation.
        await Future<void>.delayed(Duration.zero);

        expect(snapshots.length, 2);
        expect(snapshots.last.exists, isFalse);
        expect(snapshots.last.data(), isNull);

        await sub.cancel();
      },
    );

    test(
      'Given a DocumentReference, '
      'When .collection("children") is called, '
      'Then an UnimplementedError with dummy-mode message is thrown',
      () async {
        final api = _createApi(seed: 42);

        final response = await api.createDoc(
          writeable: _CreateWriteable(name: 'Alice', age: 30, isActive: true),
          id: 'doc-1',
        );

        final docRef = (response as Success<DocumentReference>).result;
        expect(
          () => docRef.collection('children'),
          throwsA(
            isA<UnimplementedError>().having(
              (e) => e.message,
              'message',
              contains('dummy-mode'),
            ),
          ),
        );
      },
    );

    test(
      'Given getDocRefById is called, '
      'When the store is empty, '
      'Then it returns a ref without mutating or seeding the store',
      () {
        final api = _createApi(seed: 42);

        final docRef = api.getDocRefById(id: 'lazy-ref');

        expect(docRef.id, 'lazy-ref');
        // Store should remain empty — no seeding or auto-creation.
        expect(dummyStoreForTesting(api), isEmpty);
      },
    );

    test(
      'Given getDocRefByIdWithConverter is called for an existing doc, '
      'When .get() is awaited, '
      'Then the snapshot data is a typed entity',
      () async {
        final api = _createApi(seed: 42);

        // Create a document first.
        await api.createDoc(
          writeable: _CreateWriteable(name: 'Alice', age: 30, isActive: true),
          id: 'doc-1',
        );

        final docRef = api.getDocRefByIdWithConverter(id: 'doc-1');
        final snapshot = await docRef.get();

        expect(snapshot.exists, isTrue);
        final data = snapshot.data();
        expect(data, isA<_SimpleDto>());
        expect((data as _SimpleDto).name, 'Alice');
        expect(data.age, 30);
      },
    );
  });
}
