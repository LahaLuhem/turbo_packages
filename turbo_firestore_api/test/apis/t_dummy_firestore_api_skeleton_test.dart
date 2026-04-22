import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_firestore_api/apis/t_dummy_firestore_api.dart';
import 'package:turbo_firestore_api/enums/t_operation_type.dart';
import 'package:turbo_firestore_api/exceptions/t_firestore_exception.dart';
import 'package:turbo_firestore_api/generators/t_dummy_schema.dart';
import 'package:turbo_serializable/abstracts/t_writeable.dart';

// ---------------------------------------------------------------------------
// Synthetic fixture DTO
// ---------------------------------------------------------------------------

class _SimpleDto extends TWriteable {
  _SimpleDto({required this.name, required this.age, required this.isActive});

  factory _SimpleDto.fromJson(Map<String, dynamic> json) => _SimpleDto(
    name: json['name'] as String,
    age: json['age'] as int,
    isActive: json['isActive'] as bool,
  );

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
  String Function()? collectionPath,
  double randomFailurePercentage = 0,
  Duration dummyDelayDuration = const Duration(milliseconds: 225),
  List<Duration>? dummyDelayRange,
}) => TDummyFirestoreApi<_SimpleDto>(
  firebaseFirestore: FakeFirebaseFirestore(),
  collectionPath: collectionPath ?? () => 'testCollection',
  fromJson: _SimpleDto.fromJson,
  toJson: (dto) => dto.toJson(),
  seed: seed,
  randomFailurePercentage: randomFailurePercentage,
  dummyDelayDuration: dummyDelayDuration,
  dummyDelayRange: dummyDelayRange,
);

/// Recursively compares two [TDummySchema] instances for structural equality.
void _expectSchemasEqual(TDummySchema a, TDummySchema b) {
  expect(a.fields.length, b.fields.length, reason: 'Field count mismatch');
  expect(a.unresolved.length, b.unresolved.length);

  for (final key in a.fields.keys) {
    final fieldA = a.fields[key];
    final fieldB = b.fields[key];
    expect(fieldB, isNotNull, reason: 'Missing field: $key');

    switch (fieldA!) {
      case TDummySchemaLeaf(:final type):
        expect(fieldB, isA<TDummySchemaLeaf>());
        expect(
          (fieldB! as TDummySchemaLeaf).type,
          type,
          reason: 'Type mismatch for field: $key',
        );
      case TDummySchemaBranch(:final nested):
        expect(fieldB, isA<TDummySchemaBranch>());
        _expectSchemasEqual(
          nested,
          (fieldB! as TDummySchemaBranch).nested,
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TDummyFirestoreApi skeleton', () {
    test(
      'Given a synthetic DTO, '
      'When a TDummyFirestoreApi is constructed, '
      'Then the probed schema matches a standalone probe result',
      () {
        final api = _createApi(seed: 42);
        final standaloneSchema = probeDummySchemaForTesting<_SimpleDto>(
          _SimpleDto.fromJson,
        );
        final apiSchema = dummySchemaForTesting(api);

        _expectSchemasEqual(apiSchema, standaloneSchema);

        // Registry is functional — generates values of expected types.
        final registry = dummyRegistryForTesting(api);
        final nameResult = registry.generate(field: 'name', type: String);
        expect(nameResult, isA<String>());

        final ageResult = registry.generate(field: 'age', type: int);
        expect(ageResult, isA<int>());
      },
    );

    test(
      'Given two TDummyFirestoreApi instances with the same seed and path, '
      'When _genDummyId is called ten times on each, '
      'Then both produce identical id lists',
      () {
        final apiA = _createApi(seed: 99);
        final apiB = _createApi(seed: 99);

        final idsA = List.generate(10, (_) => genDummyIdForTesting(apiA));
        final idsB = List.generate(10, (_) => genDummyIdForTesting(apiB));

        expect(idsA, idsB);

        // Verify id format.
        for (final id in idsA) {
          expect(id, startsWith('dummy_testCollection_'));
        }
      },
    );

    test(
      'Given dummyDelayDuration of 50ms, '
      'When _applyLatency is awaited, '
      'Then the elapsed duration is within 45ms to 75ms',
      () async {
        final api = _createApi(
          seed: 1,
          dummyDelayDuration: const Duration(milliseconds: 50),
        );

        final sw = Stopwatch()..start();
        await applyDummyLatencyForTesting(api);
        sw.stop();

        expect(
          sw.elapsedMilliseconds,
          greaterThanOrEqualTo(45),
          reason: 'Latency too short',
        );
        expect(
          sw.elapsedMilliseconds,
          lessThanOrEqualTo(75),
          reason: 'Latency too long',
        );
      },
    );

    test(
      'Given randomFailurePercentage of 0, '
      'When _rollFailureException runs 100 times, '
      'Then it returns null on every call',
      () {
        final api = _createApi(seed: 1, randomFailurePercentage: 0);

        for (var i = 0; i < 100; i++) {
          final result = rollDummyFailureExceptionForTesting(
            api,
            operationType: TOperationType.read,
          );
          expect(result, isNull, reason: 'Expected null at iteration $i');
        }
      },
    );

    test(
      'Given randomFailurePercentage of 100, '
      'When _rollFailureException runs 100 times, '
      'Then it returns a TFirestoreException subtype on every call '
      'and the subtypes vary across the pool',
      () {
        final api = _createApi(seed: 1, randomFailurePercentage: 100);
        final runtimeTypes = <Type>{};

        for (var i = 0; i < 100; i++) {
          final result = rollDummyFailureExceptionForTesting(
            api,
            operationType: TOperationType.read,
            id: 'doc_$i',
          );
          expect(result, isA<TFirestoreException>());
          runtimeTypes.add(result.runtimeType);
        }

        // With 100 rolls and 6 subtypes, more than 1 subtype must appear.
        expect(
          runtimeTypes.length,
          greaterThan(1),
          reason: 'Expected multiple exception subtypes across 100 rolls',
        );
      },
    );

    test(
      'Given an instance with registered controllers, '
      'When dispose is called, '
      'Then every controller is closed',
      () async {
        final api = _createApi(seed: 1);

        final collCtrl = StreamController<List<_SimpleDto>>.broadcast();
        final docCtrl = StreamController<_SimpleDto?>.broadcast();

        addCollectionControllerForTesting(api, collCtrl);
        addDocControllerForTesting(api, 'doc1', docCtrl);

        expect(collCtrl.isClosed, isFalse);
        expect(docCtrl.isClosed, isFalse);

        await api.dispose();

        expect(collCtrl.isClosed, isTrue);
        expect(docCtrl.isClosed, isTrue);
      },
    );
  });
}
