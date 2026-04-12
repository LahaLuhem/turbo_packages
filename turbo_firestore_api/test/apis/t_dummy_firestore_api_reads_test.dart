import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_firestore_api/apis/t_dummy_firestore_api.dart';
import 'package:turbo_firestore_api/exceptions/t_firestore_exception.dart';
import 'package:turbo_response/turbo_response.dart';

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'isActive': isActive,
        if (createdAt != null) 'createdAt': createdAt,
        if (updatedAt != null) 'updatedAt': updatedAt,
      };
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

TDummyFirestoreApi<_SimpleDto> _createApi({
  int? seed,
  String Function()? collectionPath,
  double randomFailurePercentage = 0,
  Duration dummyDelayDuration = Duration.zero,
  int defaultCollectionSize = 5,
}) =>
    TDummyFirestoreApi<_SimpleDto>(
      firebaseFirestore: FakeFirebaseFirestore(),
      collectionPath: collectionPath ?? () => 'testCollection',
      fromJson: _SimpleDto.fromJson,
      toJson: (dto) => dto.toJson(),
      seed: seed,
      randomFailurePercentage: randomFailurePercentage,
      dummyDelayDuration: dummyDelayDuration,
      defaultCollectionSize: defaultCollectionSize,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TDummyFirestoreApi read overrides', () {
    test(
      'Given an empty store, '
      'When getByIdWithConverter is called twice with the same id, '
      'Then both calls return the same entity with matching fields',
      () async {
        final api = _createApi(seed: 42);

        final first = await api.getByIdWithConverter(id: 'doc-1');
        final second = await api.getByIdWithConverter(id: 'doc-1');

        final entity1 = (first as Success<_SimpleDto>).result;
        final entity2 = (second as Success<_SimpleDto>).result;

        expect(entity1.id, 'doc-1');
        expect(entity2.id, 'doc-1');
        expect(entity1.name, entity2.name);
        expect(entity1.age, entity2.age);
        expect(entity1.isActive, entity2.isActive);
      },
    );

    test(
      'Given an empty store, '
      'When getById (raw) is called, '
      'Then mutating the returned map does not affect subsequent reads',
      () async {
        final api = _createApi(seed: 42);

        final firstResponse = await api.getById(id: 'raw-1');
        final firstMap =
            (firstResponse as Success<Map<String, dynamic>>).result;

        // Mutate the returned map.
        firstMap['name'] = 'MUTATED';

        final secondResponse = await api.getById(id: 'raw-1');
        final secondMap =
            (secondResponse as Success<Map<String, dynamic>>).result;

        expect(secondMap['name'], isNot('MUTATED'));
      },
    );

    test(
      'Given an empty store, '
      'When listAllWithConverter is called, '
      'Then exactly defaultCollectionSize entities are returned '
      'and a second call returns the same list',
      () async {
        const size = 7;
        final api = _createApi(seed: 42, defaultCollectionSize: size);

        final first = await api.listAllWithConverter();
        final list1 = (first as Success<List<_SimpleDto>>).result;
        expect(list1.length, size);

        final second = await api.listAllWithConverter();
        final list2 = (second as Success<List<_SimpleDto>>).result;
        expect(list2.length, size);

        for (var i = 0; i < size; i++) {
          expect(list2[i].id, list1[i].id);
          expect(list2[i].name, list1[i].name);
          expect(list2[i].age, list1[i].age);
        }
      },
    );

    test(
      'Given two api instances with the same seed and path, '
      'When listAllWithConverter is called on both, '
      'Then the entity lists are field-by-field equal',
      () async {
        final apiA = _createApi(seed: 99, defaultCollectionSize: 5);
        final apiB = _createApi(seed: 99, defaultCollectionSize: 5);

        final listA =
            ((await apiA.listAllWithConverter()) as Success<List<_SimpleDto>>)
                .result;
        final listB =
            ((await apiB.listAllWithConverter()) as Success<List<_SimpleDto>>)
                .result;

        expect(listA.length, listB.length);
        for (var i = 0; i < listA.length; i++) {
          expect(listA[i].id, listB[i].id);
          expect(listA[i].name, listB[i].name);
          expect(listA[i].age, listB[i].age);
          expect(listA[i].isActive, listB[i].isActive);
        }
      },
    );

    test(
      'Given an empty store, '
      'When docExists is called for an unknown id, '
      'Then it returns false; '
      'after getByIdWithConverter seeds that id it returns true',
      () async {
        final api = _createApi(seed: 42);

        final existsBefore = await api.docExists(id: 'probe-1');
        expect(existsBefore, isFalse);

        // Seed the doc via a converter read.
        await api.getByIdWithConverter(id: 'probe-1');

        final existsAfter = await api.docExists(id: 'probe-1');
        expect(existsAfter, isTrue);
      },
    );

    test(
      'Given dummyDelayDuration of 50ms, '
      'When getByIdWithConverter is called, '
      'Then the call takes at least 45ms',
      () async {
        final api = _createApi(
          seed: 1,
          dummyDelayDuration: const Duration(milliseconds: 50),
        );

        final sw = Stopwatch()..start();
        await api.getByIdWithConverter(id: 'latency-test');
        sw.stop();

        expect(
          sw.elapsedMilliseconds,
          greaterThanOrEqualTo(45),
          reason: 'Latency too short',
        );
      },
    );

    test(
      'Given randomFailurePercentage of 100, '
      'When TurboResponse-returning reads are called, '
      'Then every response is TurboResponse.fail with a TFirestoreException',
      () async {
        final api = _createApi(
          seed: 42,
          randomFailurePercentage: 100,
          defaultCollectionSize: 3,
        );

        final get1 = await api.getByIdWithConverter(id: 'fail-1');
        expect(get1, isA<Fail<_SimpleDto>>());
        expect((get1 as Fail<_SimpleDto>).error, isA<TFirestoreException>());

        final get2 = await api.getById(id: 'fail-2');
        expect(get2, isA<Fail<Map<String, dynamic>>>());
        expect(
          (get2 as Fail<Map<String, dynamic>>).error,
          isA<TFirestoreException>(),
        );

        final list1 = await api.listAllWithConverter();
        expect(list1, isA<Fail<List<_SimpleDto>>>());
        expect(
          (list1 as Fail<List<_SimpleDto>>).error,
          isA<TFirestoreException>(),
        );

        final list2 = await api.listAll();
        expect(list2, isA<Fail<List<Map<String, dynamic>>>>());
        expect(
          (list2 as Fail<List<Map<String, dynamic>>>).error,
          isA<TFirestoreException>(),
        );
      },
    );

    test(
      'Given randomFailurePercentage of 100, '
      'When docExists is called, '
      'Then it throws a TFirestoreException',
      () async {
        final api = _createApi(
          seed: 42,
          randomFailurePercentage: 100,
        );

        expect(
          () => api.docExists(id: 'throw-test'),
          throwsA(isA<TFirestoreException>()),
        );
      },
    );

    test(
      'Given a seeded store, '
      'When listAllWithConverter is called, '
      'Then seeded createdAt values are spread across distinct days',
      () async {
        const size = 5;
        final api = _createApi(seed: 42, defaultCollectionSize: size);

        final list =
            ((await api.listAllWithConverter()) as Success<List<_SimpleDto>>)
                .result;

        final dates = list.map((e) {
          final ts = e.createdAt;
          expect(ts, isNotNull, reason: 'createdAt must be set for seeded doc');
          final dt = ts!.toDate();
          // Normalize to date-only for day comparison.
          return DateTime(dt.year, dt.month, dt.day);
        }).toSet();

        expect(
          dates.length,
          size,
          reason: 'Each seeded entity must have a distinct createdAt day',
        );
      },
    );

    test(
      'Given the query seam, '
      'When applyDummyQueryFilterAndSortForTesting is called, '
      'Then it returns input unchanged',
      () {
        final api = _createApi(seed: 42);

        final input = [
          {'a': 1},
          {'b': 2},
        ];
        final output = applyDummyQueryFilterAndSortForTesting(
          api,
          whereDescription: 'test',
          input: input,
        );

        expect(identical(output, input), isTrue);
      },
    );

    test(
      'Given a listByQuery call with a closure that throws, '
      'When listByQueryWithConverter is called, '
      'Then the query closure is never invoked '
      'and the call succeeds from the store',
      () async {
        final api = _createApi(seed: 42, defaultCollectionSize: 3);

        final result = await api.listByQueryWithConverter(
          collectionReferenceQuery: (_) =>
              throw StateError('Closure should not be called'),
          whereDescription: 'ignored',
        );

        final list = (result as Success<List<_SimpleDto>>).result;
        expect(list.length, 3);
      },
    );

    test(
      'Given defaultCollectionSize of 0, '
      'When listAllWithConverter is called, '
      'Then it returns an empty list',
      () async {
        final api = _createApi(seed: 42, defaultCollectionSize: 0);

        final result = await api.listAllWithConverter();
        final list = (result as Success<List<_SimpleDto>>).result;

        expect(list, isEmpty);
      },
    );
  });
}
