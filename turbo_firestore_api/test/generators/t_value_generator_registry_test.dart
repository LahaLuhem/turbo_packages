import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_firestore_api/generators/t_dummy_schema.dart';
import 'package:turbo_firestore_api/generators/t_value_generator_registry.dart';

/// Minimal schema with no unresolved fields for most tests.
const _baseSchema = TDummySchema(
  fields: {
    'email': TDummySchemaLeaf(String),
    'price': TDummySchemaLeaf(double),
    'age': TDummySchemaLeaf(int),
    'isActive': TDummySchemaLeaf(bool),
    'createdAt': TDummySchemaLeaf(DateTime),
  },
  unresolved: {},
);

/// Schema with an unresolved field.
const _unresolvedSchema = TDummySchema(
  fields: {
    'name': TDummySchemaLeaf(String),
  },
  unresolved: {'mystery', 'unknownNumber'},
);

void main() {
  group('TValueGeneratorRegistry', () {
    test(
      'Given a caller field override for email, '
      'When generate is called for the email field, '
      'Then the caller override is returned and the bundled heuristic is not invoked',
      () {
        final registry = TValueGeneratorRegistry.build(
          fieldGenerators: {'email': () => 'override@test.com'},
          typeGenerators: {String: () => 'type-override'},
          schema: _baseSchema,
          random: Random(42),
        );

        final result = registry.generate(field: 'email', type: String);

        expect(result, 'override@test.com');
      },
    );

    test(
      'Given a caller type override for String and no field override, '
      'When generate is called for the email field, '
      'Then the caller type override is returned, not the bundled email heuristic',
      () {
        final registry = TValueGeneratorRegistry.build(
          typeGenerators: {String: () => 'type-level-override'},
          schema: _baseSchema,
          random: Random(42),
        );

        final result = registry.generate(field: 'email', type: String);

        expect(result, 'type-level-override');
      },
    );

    test(
      'Given no caller overrides, '
      'When generate is called for the email field with type String, '
      'Then the output contains exactly one @ character',
      () {
        final registry = TValueGeneratorRegistry.build(
          schema: _baseSchema,
          random: Random(42),
        );

        final result = registry.generate(field: 'email', type: String);

        expect(result, isA<String>());
        final str = result as String;
        expect(str.split('@').length, 2);
        expect(str.split('@')[0], isNotEmpty);
        expect(str.split('@')[1], isNotEmpty);
      },
    );

    test(
      'Given no caller overrides, '
      'When generate is called for the price field with type double, '
      'Then the result is a positive double from the bundled price heuristic',
      () {
        final registry = TValueGeneratorRegistry.build(
          schema: _baseSchema,
          random: Random(42),
        );

        final result = registry.generate(field: 'price', type: double);

        expect(result, isA<double>());
        expect(result as double, greaterThanOrEqualTo(0));
      },
    );

    test(
      'Given an unresolved String field in the schema, '
      'When generate is called for it, '
      'Then the string placeholder value is returned',
      () {
        final registry = TValueGeneratorRegistry.build(
          schema: _unresolvedSchema,
          random: Random(42),
        );

        final result = registry.generate(field: 'mystery', type: String);

        expect(result, TValueGeneratorRegistry.placeholderString);
      },
    );

    test(
      'Given an unresolved double field in the schema, '
      'When generate is called for it, '
      'Then the double placeholder value is returned',
      () {
        final registry = TValueGeneratorRegistry.build(
          schema: _unresolvedSchema,
          random: Random(42),
        );

        final result = registry.generate(
          field: 'unknownNumber',
          type: double,
        );

        expect(result, TValueGeneratorRegistry.placeholderDouble);
      },
    );

    test(
      'Given two registries built with the same seed and same inputs, '
      'When generate is called in the same order on both, '
      'Then both produce identical outputs',
      () {
        final registryA = TValueGeneratorRegistry.build(
          schema: _baseSchema,
          random: Random(42),
        );
        final registryB = TValueGeneratorRegistry.build(
          schema: _baseSchema,
          random: Random(42),
        );

        final fields = [
          (field: 'email', type: String),
          (field: 'price', type: double),
          (field: 'age', type: int),
          (field: 'isActive', type: bool),
          (field: 'createdAt', type: DateTime),
        ];

        for (final entry in fields) {
          final a = registryA.generate(field: entry.field, type: entry.type);
          final b = registryB.generate(field: entry.field, type: entry.type);

          if (a is DateTime && b is DateTime) {
            expect(
              a.millisecondsSinceEpoch,
              b.millisecondsSinceEpoch,
              reason: 'Determinism failed for field: ${entry.field}',
            );
          } else if (a is Timestamp && b is Timestamp) {
            expect(
              a.millisecondsSinceEpoch,
              b.millisecondsSinceEpoch,
              reason: 'Determinism failed for field: ${entry.field}',
            );
          } else {
            expect(
              a,
              b,
              reason: 'Determinism failed for field: ${entry.field}',
            );
          }
        }
      },
    );

    test(
      'Given a field name like customerEmail, '
      'When generate is called with it and type String, '
      'Then the substring match resolves it via the email heuristic',
      () {
        final registry = TValueGeneratorRegistry.build(
          schema: _baseSchema,
          random: Random(42),
        );

        final result = registry.generate(
          field: 'customerEmail',
          type: String,
        );

        expect(result, isA<String>());
        final str = result as String;
        expect(str.split('@').length, 2);
        expect(str.split('@')[0], isNotEmpty);
        expect(str.split('@')[1], isNotEmpty);
      },
    );

    test(
      'Given no matching field heuristic or caller override, '
      'When generate is called for List, Map, and DocumentReference types, '
      'Then the results are empty list, empty map, and null respectively',
      () {
        final registry = TValueGeneratorRegistry.build(
          schema: _baseSchema,
          random: Random(42),
        );

        final listResult = registry.generate(
          field: 'tags',
          type: List<dynamic>,
        );
        final mapResult = registry.generate(
          field: 'metadata',
          type: Map<String, dynamic>,
        );
        final docRefResult = registry.generate(
          field: 'docRef',
          type: DocumentReference<Map<String, dynamic>>,
        );

        expect(listResult, isA<List>());
        expect(listResult as List, isEmpty);
        expect(mapResult, isA<Map>());
        expect(mapResult as Map, isEmpty);
        expect(docRefResult, isNull);
      },
    );
  });
}
