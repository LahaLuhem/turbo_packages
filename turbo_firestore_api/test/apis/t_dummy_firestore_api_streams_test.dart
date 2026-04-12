import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_firestore_api/apis/t_dummy_firestore_api.dart';
import 'package:turbo_firestore_api/exceptions/t_firestore_exception.dart';

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
// Helpers
// ---------------------------------------------------------------------------

TDummyFirestoreApi<_SimpleDto> _createApi({
  int? seed,
  double randomFailurePercentage = 0,
  Duration dummyDelayDuration = Duration.zero,
  int defaultCollectionSize = 5,
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
  group('TDummyFirestoreApi stream overrides', () {
    test(
      'Given streamAllWithConverter is subscribed, '
      'When the first event arrives, '
      'Then the stream is broadcast and the snapshot has defaultCollectionSize entities',
      () async {
        const size = 5;
        final api = _createApi(seed: 42, defaultCollectionSize: size);

        final stream = api.streamAllWithConverter();
        expect(stream.isBroadcast, isTrue);

        final snapshot = await stream.first;
        expect(snapshot.length, size);
      },
    );

    test(
      'Given two subscribers on the same streamAllWithConverter call, '
      'When both receive the first event, '
      'Then both snapshots contain the same entities',
      () async {
        const size = 4;
        final api = _createApi(seed: 42, defaultCollectionSize: size);

        final stream = api.streamAllWithConverter();
        final firstSnapshot = Completer<List<_SimpleDto>>();
        final secondSnapshot = Completer<List<_SimpleDto>>();

        final sub1 = stream.listen((data) {
          if (!firstSnapshot.isCompleted) firstSnapshot.complete(data);
        });
        final sub2 = stream.listen((data) {
          if (!secondSnapshot.isCompleted) secondSnapshot.complete(data);
        });

        final list1 = await firstSnapshot.future.timeout(
          const Duration(seconds: 2),
        );
        final list2 = await secondSnapshot.future.timeout(
          const Duration(seconds: 2),
        );

        expect(list1.length, size);
        expect(list2.length, size);
        for (var i = 0; i < size; i++) {
          expect(list1[i].id, list2[i].id);
          expect(list1[i].name, list2[i].name);
        }

        await sub1.cancel();
        await sub2.cancel();
      },
    );

    test(
      'Given a subscribed streamAllWithConverter, '
      'When the subscription is cancelled, '
      'Then the controller is removed from _collectionControllers',
      () async {
        final api = _createApi(seed: 42);

        final stream = api.streamAllWithConverter();
        final completer = Completer<void>();
        final sub = stream.listen((_) {
          if (!completer.isCompleted) completer.complete();
        });

        // Wait for initial emission so onListen has fired.
        await completer.future.timeout(const Duration(seconds: 2));
        expect(collectionControllerCountForTesting(api), 1);

        await sub.cancel();
        // Allow event loop to process onCancel.
        await Future<void>.delayed(Duration.zero);
        expect(collectionControllerCountForTesting(api), 0);
      },
    );

    test(
      'Given streamDocByIdWithConverter subscribed to id "x", '
      'When the first event arrives, '
      'Then exactly one non-null materialised entity is emitted',
      () async {
        final api = _createApi(seed: 42);

        final stream = api.streamDocByIdWithConverter(id: 'x');
        expect(stream.isBroadcast, isTrue);

        final entity = await stream.first;
        expect(entity, isNotNull);
        expect(entity!.id, 'x');
      },
    );

    test(
      'Given randomFailurePercentage of 100, '
      'When streamAllWithConverter is subscribed, '
      'Then the stream emits an error via addError',
      () async {
        final api = _createApi(
          seed: 42,
          randomFailurePercentage: 100,
          defaultCollectionSize: 3,
        );

        final stream = api.streamAllWithConverter();

        await expectLater(
          stream,
          emitsError(isA<TFirestoreException>()),
        );
      },
    );

    test(
      'Given one collection subscriber, '
      'When emitCollectionsForTesting is called manually, '
      'Then the subscriber receives a new snapshot reflecting the current store',
      () async {
        const size = 3;
        final api = _createApi(seed: 42, defaultCollectionSize: size);

        final stream = api.streamAllWithConverter();
        final events = <List<_SimpleDto>>[];
        final firstEvent = Completer<void>();
        final secondEvent = Completer<void>();

        final sub = stream.listen((data) {
          events.add(data);
          if (events.length == 1 && !firstEvent.isCompleted) {
            firstEvent.complete();
          }
          if (events.length == 2 && !secondEvent.isCompleted) {
            secondEvent.complete();
          }
        });

        await firstEvent.future.timeout(const Duration(seconds: 2));
        expect(events.length, 1);
        expect(events[0].length, size);

        // Add a new doc to the store and trigger manual fan-out.
        final store = dummyStoreForTesting(api);
        final newDoc = generateDocJsonForTesting(api, id: 'manual-new');
        store['manual-new'] = newDoc;
        emitCollectionsForTesting(api);

        await secondEvent.future.timeout(const Duration(seconds: 2));
        expect(events.length, 2);
        expect(events[1].length, size + 1);

        await sub.cancel();
      },
    );

    test(
      'Given a subscribed doc stream for id "y", '
      'When emitDocForTesting("y", null) is called manually, '
      'Then the subscriber receives null as the next event',
      () async {
        final api = _createApi(seed: 42);

        final stream = api.streamDocByIdWithConverter(id: 'y');
        final events = <_SimpleDto?>[];
        final firstEvent = Completer<void>();
        final secondEvent = Completer<void>();

        final sub = stream.listen((data) {
          events.add(data);
          if (events.length == 1 && !firstEvent.isCompleted) {
            firstEvent.complete();
          }
          if (events.length == 2 && !secondEvent.isCompleted) {
            secondEvent.complete();
          }
        });

        await firstEvent.future.timeout(const Duration(seconds: 2));
        expect(events.length, 1);
        expect(events[0], isNotNull);

        emitDocForTesting(api, 'y', null);

        await secondEvent.future.timeout(const Duration(seconds: 2));
        expect(events.length, 2);
        expect(events[1], isNull);

        await sub.cancel();
      },
    );

    test(
      'Given streamByQueryWithConverter with a throwing closure, '
      'When subscribed, '
      'Then the query closure is never invoked and the stream emits from the store',
      () async {
        const size = 3;
        final api = _createApi(seed: 42, defaultCollectionSize: size);

        final stream = api.streamByQueryWithConverter(
          collectionReferenceQuery: (_) =>
              throw StateError('Closure should not be called'),
          whereDescription: 'ignored',
        );

        final snapshot = await stream.first;
        expect(snapshot.length, size);
      },
    );

    test(
      'Given streamByQuery (raw), '
      'When subscribed, '
      'Then the stream emits raw map lists',
      () async {
        const size = 3;
        final api = _createApi(seed: 42, defaultCollectionSize: size);

        final stream = api.streamByQuery(
          collectionReferenceQuery: null,
          whereDescription: 'raw-test',
        );

        final snapshot = await stream.first;
        expect(snapshot.length, size);
        expect(snapshot.first, isA<Map<String, dynamic>>());
        expect(snapshot.first.containsKey('id'), isTrue);
      },
    );

    test(
      'Given streamAll() (raw QuerySnapshot), '
      'When called, '
      'Then it throws UnimplementedError with converter guidance',
      () {
        final api = _createApi(seed: 42);

        expect(
          () => api.streamAll(),
          throwsA(isA<UnimplementedError>()),
        );
      },
    );

    test(
      'Given streamByDocId() (raw DocumentSnapshot), '
      'When called, '
      'Then it throws UnimplementedError with converter guidance',
      () {
        final api = _createApi(seed: 42);

        expect(
          () => api.streamByDocId(id: 'x'),
          throwsA(isA<UnimplementedError>()),
        );
      },
    );
  });
}
