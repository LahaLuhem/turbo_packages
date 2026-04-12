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

class _SimpleDto {
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
  group('TDummyFirestoreApi batch operations', () {
    test(
      'Given an open collection stream, '
      'When three creates are enqueued in a batch and commit is called, '
      'Then the stream emits exactly one additional snapshot containing '
      'all three new entities',
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

        // Create a batch and enqueue three creates.
        final batch = api.writeBatch;
        await api.createDocInBatch(
          writeable: _CreateWriteable(name: 'Alice', age: 30, isActive: true),
          id: 'doc-1',
          writeBatch: batch,
        );
        await api.createDocInBatch(
          writeable: _CreateWriteable(name: 'Bob', age: 25, isActive: false),
          id: 'doc-2',
          writeBatch: batch,
        );
        await api.createDocInBatch(
          writeable: _CreateWriteable(name: 'Carol', age: 35, isActive: true),
          id: 'doc-3',
          writeBatch: batch,
        );

        // Store should still be empty before commit.
        expect(dummyStoreForTesting(api), isEmpty);

        // Commit the batch.
        await batch.commit();

        // Store should now have all 3 docs.
        final store = dummyStoreForTesting(api);
        expect(store.length, 3);
        expect(store['doc-1']!['name'], 'Alice');
        expect(store['doc-2']!['name'], 'Bob');
        expect(store['doc-3']!['name'], 'Carol');

        // Allow async stream delivery to propagate.
        await Future<void>.delayed(Duration.zero);

        // Stream should have received exactly one additional emission
        // (initial + one batch commit), not three individual emissions.
        expect(
          emissions.length,
          2,
          reason: 'Should have initial + single batch commit emission',
        );
        expect(emissions[1].length, 3);

        await sub.cancel();
      },
    );

    test(
      'Given a batch that mixes create, update, delete on different ids, '
      'When committed, '
      'Then the store ends in the expected merged state and one single '
      'snapshot is emitted',
      () async {
        final api = _createApi(seed: 42);

        // Seed a doc directly first.
        await api.createDoc(
          writeable: _CreateWriteable(name: 'Alice', age: 30, isActive: true),
          id: 'existing-1',
        );
        await api.createDoc(
          writeable: _CreateWriteable(
            name: 'ToDelete',
            age: 99,
            isActive: false,
          ),
          id: 'delete-me',
        );

        // Open a stream and wait for initial emission.
        final emissions = <List<_SimpleDto>>[];
        final initialEmission = Completer<void>();
        final sub = api.streamAllWithConverter().listen((data) {
          emissions.add(data);
          if (!initialEmission.isCompleted) initialEmission.complete();
        });
        await initialEmission.future.timeout(const Duration(seconds: 2));
        final baselineEmissions = emissions.length;

        // Build a mixed batch.
        final batch = api.writeBatch;
        await api.createDocInBatch(
          writeable: _CreateWriteable(name: 'New', age: 20, isActive: true),
          id: 'new-1',
          writeBatch: batch,
        );
        await api.updateDocInBatch(
          writeable: _UpdateWriteable(name: 'Alice Updated'),
          id: 'existing-1',
          writeBatch: batch,
        );
        await api.deleteDocInBatch(
          id: 'delete-me',
          writeBatch: batch,
        );

        await batch.commit();
        await Future<void>.delayed(Duration.zero);

        // Verify final store state.
        final store = dummyStoreForTesting(api);
        expect(store.containsKey('new-1'), isTrue);
        expect(store['existing-1']!['name'], 'Alice Updated');
        expect(store.containsKey('delete-me'), isFalse);

        // Exactly one new emission for the commit.
        expect(
          emissions.length - baselineEmissions,
          1,
          reason: 'Single emission for entire batch commit',
        );

        await sub.cancel();
      },
    );

    test(
      'Given a runTransaction handler that updates an entity field, '
      'When the transaction completes, '
      'Then the store reflects the update and the returned value is '
      'passed through unchanged',
      () async {
        final api = _createApi(seed: 42);

        // Seed a document.
        await api.createDoc(
          writeable: _CreateWriteable(name: 'Alice', age: 30, isActive: true),
          id: 'doc-1',
        );

        // Run a transaction that updates the entity and returns a string.
        final result = await api.runTransaction<String>((txn) async {
          // Update via the api's updateDoc with transaction parameter.
          await api.updateDoc(
            writeable: _UpdateWriteable(name: 'Alice Updated'),
            id: 'doc-1',
            transaction: txn,
          );
          return 'done';
        });

        // Handler's return value passed through unchanged.
        expect(result, 'done');

        // Store reflects the update.
        final store = dummyStoreForTesting(api);
        expect(store['doc-1']!['name'], 'Alice Updated');
      },
    );

    test(
      'Given an open collection stream, '
      'When a runTransaction handler performs multiple mutations, '
      'Then exactly one new collection emission occurs after the handler '
      'completes',
      () async {
        final api = _createApi(seed: 42);

        // Open a stream and wait for initial emission.
        final emissions = <List<_SimpleDto>>[];
        final initialEmission = Completer<void>();
        final sub = api.streamAllWithConverter().listen((data) {
          emissions.add(data);
          if (!initialEmission.isCompleted) initialEmission.complete();
        });
        await initialEmission.future.timeout(const Duration(seconds: 2));
        final baselineEmissions = emissions.length;

        // Run a transaction with two creates.
        await api.runTransaction((txn) async {
          await api.createDoc(
            writeable: _CreateWriteable(name: 'A', age: 1, isActive: true),
            id: 'txn-1',
            transaction: txn,
          );
          await api.createDoc(
            writeable: _CreateWriteable(name: 'B', age: 2, isActive: false),
            id: 'txn-2',
            transaction: txn,
          );
        });

        await Future<void>.delayed(Duration.zero);

        // Exactly one new emission after the transaction, not two.
        expect(
          emissions.length - baselineEmissions,
          1,
          reason: 'Single emission for entire transaction',
        );
        expect(emissions.last.length, 2);

        await sub.cancel();
      },
    );

    test(
      'Given a committed WriteBatch, '
      'When commit is called again, '
      'Then a StateError is thrown with dummy-mode in the message',
      () async {
        final api = _createApi(seed: 42);
        final batch = api.writeBatch;

        await api.createDocInBatch(
          writeable: _CreateWriteable(name: 'Alice', age: 30, isActive: true),
          id: 'doc-1',
          writeBatch: batch,
        );
        await batch.commit();

        expect(
          () => batch.commit(),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('dummy-mode'),
            ),
          ),
        );
      },
    );

    test(
      'Given a runTransaction handler that returns a specific value, '
      'When awaited, '
      'Then the caller receives that exact value unchanged',
      () async {
        final api = _createApi(seed: 42);

        final result = await api.runTransaction<int>((txn) async {
          return 42;
        });

        expect(result, 42);
      },
    );

    test(
      'Given a batch where the second operation throws, '
      'When commit is called, '
      'Then the store is rolled back to its pre-commit state',
      () async {
        final api = _createApi(seed: 42);

        // Seed an existing doc.
        await api.createDoc(
          writeable: _CreateWriteable(name: 'Alice', age: 30, isActive: true),
          id: 'existing-1',
        );

        final storeBefore = Map<String, Map<String, dynamic>>.of(
          dummyStoreForTesting(api),
        );

        final batch = api.writeBatch;
        await api.createDocInBatch(
          writeable: _CreateWriteable(name: 'New', age: 20, isActive: true),
          id: 'new-1',
          writeBatch: batch,
        );
        // Enqueue an update for a non-existent id — this will throw during
        // commit because the closure checks for the doc's existence.
        await api.updateDocInBatch(
          writeable: _UpdateWriteable(name: 'Ghost'),
          id: 'does-not-exist',
          writeBatch: batch,
        );

        // Commit should throw.
        expect(() => batch.commit(), throwsA(anything));

        // Store should be exactly as it was before commit.
        final storeAfter = dummyStoreForTesting(api);
        expect(storeAfter.length, storeBefore.length);
        expect(
          storeAfter.containsKey('new-1'),
          isFalse,
          reason: 'First create rolled back',
        );
        expect(storeAfter['existing-1']!['name'], 'Alice');
      },
    );

    test(
      'Given a runTransaction handler that throws after mutating the store, '
      'When awaited, '
      'Then the store is rolled back and the error propagates',
      () async {
        final api = _createApi(seed: 42);

        // Seed a doc.
        await api.createDoc(
          writeable: _CreateWriteable(name: 'Alice', age: 30, isActive: true),
          id: 'doc-1',
        );

        final storeBefore = Map<String, Map<String, dynamic>>.of(
          dummyStoreForTesting(api),
        );

        // Run a transaction that creates a doc then throws.
        Object? caughtError;
        try {
          await api.runTransaction((txn) async {
            await api.createDoc(
              writeable: _CreateWriteable(name: 'Bob', age: 25, isActive: true),
              id: 'doc-2',
              transaction: txn,
            );
            throw StateError('intentional failure');
          });
        } catch (e) {
          caughtError = e;
        }
        expect(caughtError, isA<StateError>());

        // Store should be exactly as before the transaction.
        final storeAfter = dummyStoreForTesting(api);
        expect(storeAfter.length, storeBefore.length);
        expect(
          storeAfter.containsKey('doc-2'),
          isFalse,
          reason: 'Transaction create rolled back',
        );
        expect(storeAfter['doc-1']!['name'], 'Alice');
      },
    );

    test(
      'Given a transaction handler, '
      'When the handler reads a stored entity via transaction get, '
      'Then the snapshot contains the stored data',
      () async {
        final api = _createApi(seed: 42);

        // Seed a doc.
        await api.createDoc(
          writeable: _CreateWriteable(name: 'Alice', age: 30, isActive: true),
          id: 'doc-1',
        );

        Map<String, dynamic>? readData;
        await api.runTransaction((txn) async {
          // Create a dummy document reference to read.
          final store = dummyStoreForTesting(api);
          expect(store.containsKey('doc-1'), isTrue);

          // Use the transaction's get through a doc ref returned by createDoc.
          final createResult = await api.createDoc(
            writeable: _CreateWriteable(name: 'Bob', age: 25, isActive: true),
            id: 'doc-2',
            transaction: txn,
          );
          final docRef = (createResult as Success<DocumentReference>).result;

          // Read the doc we just created in the same transaction.
          final snapshot = await txn.get(docRef);
          expect(snapshot.exists, isTrue);
          readData = snapshot.data() as Map<String, dynamic>?;
        });

        expect(readData, isNotNull);
        expect(readData!['name'], 'Bob');
      },
    );
  });
}
