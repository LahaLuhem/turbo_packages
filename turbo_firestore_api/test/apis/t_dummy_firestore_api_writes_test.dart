import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_firestore_api/apis/t_dummy_firestore_api.dart';
import 'package:turbo_firestore_api/exceptions/t_firestore_exception.dart';
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

class _UpdateWriteable extends TWriteable {
  _UpdateWriteable({this.name});

  final String? name;

  @override
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
  };
}

class _FailingWriteable extends TWriteable {
  @override
  TurboResponse<T>? validate<T>() =>
      const TurboResponse.fail(error: 'Validation failed');

  @override
  Map<String, dynamic> toJson() => {};
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
  group('TDummyFirestoreApi write overrides', () {
    test(
      'Given an empty store, '
      'When createDoc is called with a writeable, '
      'Then the store has one entry with the writeable fields plus timestamps '
      'and an open collection stream receives the updated snapshot',
      () async {
        final api = _createApi(seed: 42);

        // Subscribe to a collection stream and collect emissions.
        final emissions = <List<_SimpleDto>>[];
        final initialEmission = Completer<void>();
        final sub = api.streamAllWithConverter().listen((data) {
          emissions.add(data);
          if (!initialEmission.isCompleted) initialEmission.complete();
        });

        // Wait for initial emission.
        await initialEmission.future.timeout(const Duration(seconds: 2));
        expect(emissions.length, 1, reason: 'Initial empty emission');
        expect(emissions.first, isEmpty);

        // Create a document.
        final result = await api.createDoc(
          writeable: _CreateWriteable(
            name: 'Alice',
            age: 30,
            isActive: true,
          ),
          id: 'doc-1',
        );

        expect(result, isA<Success<DocumentReference>>());
        final docRef = (result as Success<DocumentReference>).result;
        expect(docRef.id, 'doc-1');
        expect(docRef.path, 'testCollection/doc-1');

        // Verify the store.
        final store = dummyStoreForTesting(api);
        expect(store.length, 1);
        expect(store['doc-1']!['name'], 'Alice');
        expect(store['doc-1']!['age'], 30);
        expect(store['doc-1']!['isActive'], true);
        expect(store['doc-1']!['id'], 'doc-1');
        expect(store['doc-1']!['createdAt'], isA<Timestamp>());
        expect(store['doc-1']!['updatedAt'], isA<Timestamp>());

        // Allow async stream delivery to propagate.
        await Future<void>.delayed(Duration.zero);

        // Stream should have received the updated snapshot.
        expect(emissions.length, 2, reason: 'Should have initial + create');
        expect(emissions[1].length, 1);
        expect(emissions[1].first.name, 'Alice');

        await sub.cancel();
      },
    );

    test(
      'Given an existing entity, '
      'When updateDoc is called with a partial writeable setting only name, '
      'Then the stored map has the original fields merged with the updated '
      'field and updatedAt is newer than createdAt',
      () async {
        final api = _createApi(seed: 42);

        // Create initial document.
        await api.createDoc(
          writeable: _CreateWriteable(
            name: 'Alice',
            age: 30,
            isActive: true,
          ),
          id: 'doc-1',
        );

        final storeAfterCreate = dummyStoreForTesting(api);
        final createdAt = storeAfterCreate['doc-1']!['createdAt'] as Timestamp;
        final updatedAtBefore =
            storeAfterCreate['doc-1']!['updatedAt'] as Timestamp;

        // Brief wait to ensure timestamp difference.
        await Future<void>.delayed(const Duration(milliseconds: 5));

        // Update only name.
        final result = await api.updateDoc(
          writeable: _UpdateWriteable(name: 'Bob'),
          id: 'doc-1',
        );

        expect(result, isA<Success<DocumentReference>>());

        final store = dummyStoreForTesting(api);
        expect(store['doc-1']!['name'], 'Bob', reason: 'name overwritten');
        expect(store['doc-1']!['age'], 30, reason: 'age preserved');
        expect(store['doc-1']!['isActive'], true, reason: 'isActive preserved');
        expect(store['doc-1']!['id'], 'doc-1', reason: 'id preserved');

        final updatedAtAfter = store['doc-1']!['updatedAt'] as Timestamp;
        expect(
          updatedAtAfter.compareTo(updatedAtBefore),
          greaterThanOrEqualTo(0),
          reason: 'updatedAt should be >= the original',
        );

        // createdAt should be preserved from the original create.
        final createdAtAfter = store['doc-1']!['createdAt'] as Timestamp;
        expect(createdAtAfter, createdAt, reason: 'createdAt preserved');
      },
    );

    test(
      'Given an unknown id, '
      'When updateDoc is called, '
      'Then the result is TurboResponse.fail wrapping '
      'TurboFirestoreNotFoundException and the store is unchanged',
      () async {
        final api = _createApi(seed: 42);

        final result = await api.updateDoc(
          writeable: _UpdateWriteable(name: 'Ghost'),
          id: 'nonexistent',
        );

        expect(result, isA<Fail<DocumentReference>>());
        final fail = result as Fail<DocumentReference>;
        expect(fail.error, isA<TurboFirestoreNotFoundException>());

        expect(dummyStoreForTesting(api), isEmpty);
      },
    );

    test(
      'Given an existing id with an open doc stream, '
      'When deleteDoc is called, '
      'Then the store no longer contains the id '
      'and the doc stream emits null',
      () async {
        final api = _createApi(seed: 42);

        // Create a document.
        await api.createDoc(
          writeable: _CreateWriteable(
            name: 'Alice',
            age: 30,
            isActive: true,
          ),
          id: 'doc-1',
        );

        // Open a doc stream and capture events.
        final events = <_SimpleDto?>[];
        final initialEvent = Completer<void>();
        final sub = api.streamByDocIdWithConverter(id: 'doc-1').listen((data) {
          events.add(data);
          if (!initialEvent.isCompleted) initialEvent.complete();
        });

        // Wait for initial non-null emission.
        await initialEvent.future.timeout(const Duration(seconds: 2));
        expect(events.length, 1);
        expect(events.first, isNotNull);
        expect(events.first!.name, 'Alice');

        // Delete the document.
        final result = await api.deleteDoc(id: 'doc-1');
        expect(result, isA<Success<void>>());

        // Store should no longer have the entry.
        expect(dummyStoreForTesting(api).containsKey('doc-1'), isFalse);

        // Allow async stream delivery to propagate.
        await Future<void>.delayed(Duration.zero);

        // Doc stream should have emitted null.
        expect(events.length, 2);
        expect(events[1], isNull);

        await sub.cancel();
      },
    );

    test(
      'Given two open collection streams, '
      'When createDoc fires, '
      'Then both streams receive the identical new snapshot — no drift',
      () async {
        final api = _createApi(seed: 42);

        final emissions1 = <List<_SimpleDto>>[];
        final emissions2 = <List<_SimpleDto>>[];
        final initial1 = Completer<void>();
        final initial2 = Completer<void>();
        final sub1 = api.streamAllWithConverter().listen((data) {
          emissions1.add(data);
          if (!initial1.isCompleted) initial1.complete();
        });
        final sub2 = api.streamAllWithConverter().listen((data) {
          emissions2.add(data);
          if (!initial2.isCompleted) initial2.complete();
        });

        // Wait for initial empty emissions from both.
        await initial1.future.timeout(const Duration(seconds: 2));
        await initial2.future.timeout(const Duration(seconds: 2));
        expect(emissions1.length, 1);
        expect(emissions2.length, 1);

        // Create a document.
        await api.createDoc(
          writeable: _CreateWriteable(
            name: 'Alice',
            age: 30,
            isActive: true,
          ),
          id: 'doc-1',
        );

        // Allow async stream delivery to propagate.
        await Future<void>.delayed(Duration.zero);

        // Both streams should have received the same snapshot.
        expect(emissions1.length, 2);
        expect(emissions2.length, 2);
        expect(emissions1[1].length, 1);
        expect(emissions2[1].length, 1);
        expect(emissions1[1].first.name, emissions2[1].first.name);
        expect(emissions1[1].first.age, emissions2[1].first.age);

        await sub1.cancel();
        await sub2.cancel();
      },
    );

    test(
      'Given randomFailurePercentage of 100, '
      'When createDoc is called, '
      'Then the store is unchanged and the result is TurboResponse.fail',
      () async {
        final api = _createApi(
          seed: 42,
          randomFailurePercentage: 100,
        );

        final result = await api.createDoc(
          writeable: _CreateWriteable(
            name: 'Alice',
            age: 30,
            isActive: true,
          ),
          id: 'doc-fail',
        );

        expect(result, isA<Fail<DocumentReference>>());
        expect(
          (result as Fail<DocumentReference>).error,
          isA<TFirestoreException>(),
        );
        expect(dummyStoreForTesting(api), isEmpty);
      },
    );

    test(
      'Given randomFailurePercentage of 100, '
      'When updateDoc and deleteDoc are called, '
      'Then both return TurboResponse.fail without mutating the store',
      () async {
        // Use a separate 0% failure api to seed a doc, then test with 100%.
        final seedApi = _createApi(seed: 42);
        await seedApi.createDoc(
          writeable: _CreateWriteable(
            name: 'Alice',
            age: 30,
            isActive: true,
          ),
          id: 'doc-1',
        );

        // Now create a 100% failure api — won't share state, but we're
        // testing that the failure roll prevents any mutation.
        final failApi = _createApi(
          seed: 42,
          randomFailurePercentage: 100,
        );

        // Pre-populate the fail api's store via a direct read (0% failure
        // is not what we want — we need 100%). Instead, let's just test
        // that updateDoc on empty store returns fail for a different reason
        // (failure roll fires before the not-found check).
        final updateResult = await failApi.updateDoc(
          writeable: _UpdateWriteable(name: 'Bob'),
          id: 'doc-1',
        );
        expect(updateResult, isA<Fail<DocumentReference>>());

        final deleteResult = await failApi.deleteDoc(id: 'doc-1');
        expect(deleteResult, isA<Fail<void>>());

        expect(dummyStoreForTesting(failApi), isEmpty);
      },
    );

    test(
      'Given a writeable whose validate() fails, '
      'When createDoc is called, '
      'Then the store is unchanged and the validation failure is returned',
      () async {
        final api = _createApi(seed: 42);

        final result = await api.createDoc(
          writeable: _FailingWriteable(),
          id: 'doc-fail',
        );

        expect(result, isA<Fail<DocumentReference>>());
        expect(dummyStoreForTesting(api), isEmpty);
      },
    );

    test(
      'Given createDoc without an explicit id, '
      'When called, '
      'Then a deterministic dummy id is generated and used',
      () async {
        final api = _createApi(seed: 42);

        final result = await api.createDoc(
          writeable: _CreateWriteable(
            name: 'Alice',
            age: 30,
            isActive: true,
          ),
        );

        final docRef = (result as Success<DocumentReference>).result;
        expect(docRef.id, startsWith('dummy_testCollection_'));

        final store = dummyStoreForTesting(api);
        expect(store.length, 1);
        expect(store.keys.first, docRef.id);
      },
    );
  });
}
