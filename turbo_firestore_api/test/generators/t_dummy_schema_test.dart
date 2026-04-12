import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_firestore_api/generators/t_dummy_schema.dart';

/// Exhaustive switch-expression helper with no default branch.
/// Proves the sealed hierarchy is analyzer-enforced.
String _describeField(TDummySchemaField field) => switch (field) {
  TDummySchemaLeaf(:final type) => 'leaf:$type',
  TDummySchemaBranch(:final nested) =>
    'branch:${nested.fields.length} fields',
};

void main() {
  group('TDummySchema', () {
    test(
      'Given a flat schema with two leaf fields, '
      'When fields are inspected, '
      'Then each field reports the expected Type',
      () {
        const schema = TDummySchema(
          fields: {
            'name': TDummySchemaLeaf(String),
            'age': TDummySchemaLeaf(int),
          },
          unresolved: {},
        );

        expect(schema.fields.length, 2);

        final nameField = schema.fields['name'];
        expect(nameField, isA<TDummySchemaLeaf>());
        expect((nameField! as TDummySchemaLeaf).type, String);

        final ageField = schema.fields['age'];
        expect(ageField, isA<TDummySchemaLeaf>());
        expect((ageField! as TDummySchemaLeaf).type, int);

        expect(schema.unresolved, isEmpty);
      },
    );

    test(
      'Given a schema with one branch field, '
      'When the branch is destructured, '
      'Then the nested TDummySchema is accessible and carries its own fields',
      () {
        const nestedSchema = TDummySchema(
          fields: {
            'street': TDummySchemaLeaf(String),
            'zip': TDummySchemaLeaf(int),
          },
          unresolved: {'country'},
        );

        const schema = TDummySchema(
          fields: {
            'name': TDummySchemaLeaf(String),
            'address': TDummySchemaBranch(nestedSchema),
          },
          unresolved: {},
        );

        final addressField = schema.fields['address'];
        expect(addressField, isA<TDummySchemaBranch>());

        final branch = addressField! as TDummySchemaBranch;
        expect(branch.nested.fields.length, 2);
        expect(
          (branch.nested.fields['street']! as TDummySchemaLeaf).type,
          String,
        );
        expect(
          (branch.nested.fields['zip']! as TDummySchemaLeaf).type,
          int,
        );
        expect(branch.nested.unresolved, contains('country'));
      },
    );

    test(
      'Given a sealed TDummySchemaField value, '
      'When pattern-matched in a switch expression, '
      'Then both variants are handled with no default branch',
      () {
        const leaf = TDummySchemaLeaf(double);
        const branch = TDummySchemaBranch(
          TDummySchema(
            fields: {'x': TDummySchemaLeaf(bool)},
            unresolved: {},
          ),
        );

        expect(_describeField(leaf), 'leaf:double');
        expect(_describeField(branch), 'branch:1 fields');
      },
    );
  });
}
