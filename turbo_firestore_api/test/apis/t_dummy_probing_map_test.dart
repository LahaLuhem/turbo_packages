import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_firestore_api/apis/t_dummy_firestore_api.dart';
import 'package:turbo_firestore_api/generators/t_dummy_schema.dart';
import 'package:turbo_serializable/abstracts/t_writeable.dart';

// ---------------------------------------------------------------------------
// Synthetic fixture DTOs
// ---------------------------------------------------------------------------

class _FlatDto extends TWriteable {
  _FlatDto({
    required this.name,
    required this.age,
    required this.isActive,
  });

  factory _FlatDto.fromJson(Map<String, dynamic> json) => _FlatDto(
    name: json['name'] as String,
    age: json['age'] as int,
    isActive: json['isActive'] as bool,
  );

  final String name;
  final int age;
  final bool isActive;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'isActive': isActive,
    };
  }
}

class _NestedChild {
  _NestedChild({required this.street, required this.zip});

  factory _NestedChild.fromJson(Map<String, dynamic> json) => _NestedChild(
    street: json['street'] as String,
    zip: json['zip'] as int,
  );

  final String street;
  final int zip;
}

class _NestedParent extends TWriteable {
  _NestedParent({required this.title, required this.address});

  factory _NestedParent.fromJson(Map<String, dynamic> json) => _NestedParent(
    title: json['title'] as String,
    address: _NestedChild.fromJson(json['address'] as Map<String, dynamic>),
  );

  final String title;
  final _NestedChild address;

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'address': {
        'street': address.street,
        'zip': address.zip,
      },
    };
  }
}

class _ListDto extends TWriteable {
  _ListDto({required this.name, required this.tags});

  factory _ListDto.fromJson(Map<String, dynamic> json) => _ListDto(
    name: json['name'] as String,
    tags: (json['tags'] as List<dynamic>).cast<String>(),
  );

  final String name;
  final List<String> tags;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tags': tags,
    };
  }
}

class _UnsupportedTypeDto extends TWriteable {
  _UnsupportedTypeDto({required this.name, required this.link});

  factory _UnsupportedTypeDto.fromJson(Map<String, dynamic> json) => _UnsupportedTypeDto(
    name: json['name'] as String,
    link: json['link'] as Uri,
  );

  final String name;
  final Uri link;

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'link': link.toString(),
    };
  }
}

class _RawMapDto extends TWriteable {
  _RawMapDto({required this.label, required this.metadata});

  factory _RawMapDto.fromJson(Map<String, dynamic> json) => _RawMapDto(
    label: json['label'] as String,
    metadata: json['metadata'] as Map<String, dynamic>,
  );

  final String label;
  final Map<String, dynamic> metadata;

  @override
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'metadata': metadata,
    };
  }
}

class _TimestampDto extends TWriteable {
  _TimestampDto({required this.createdAt, required this.score});

  factory _TimestampDto.fromJson(Map<String, dynamic> json) => _TimestampDto(
    createdAt: json['createdAt'] as Timestamp,
    score: json['score'] as double,
  );

  final Timestamp createdAt;
  final double score;

  @override
  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt,
      'score': score,
    };
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('_TDummyProbingMap.probe', () {
    test(
      'Given a flat DTO with String, int, and bool fields, '
      'When probed, '
      'Then the schema reports three leaves with matching types and empty unresolved',
      () {
        final schema = probeDummySchemaForTesting<_FlatDto>(
          _FlatDto.fromJson,
        );

        expect(schema.fields.length, 3);
        expect(schema.unresolved, isEmpty);

        final nameField = schema.fields['name'];
        expect(nameField, isA<TDummySchemaLeaf>());
        expect((nameField! as TDummySchemaLeaf).type, String);

        final ageField = schema.fields['age'];
        expect(ageField, isA<TDummySchemaLeaf>());
        expect((ageField! as TDummySchemaLeaf).type, int);

        final isActiveField = schema.fields['isActive'];
        expect(isActiveField, isA<TDummySchemaLeaf>());
        expect((isActiveField! as TDummySchemaLeaf).type, bool);
      },
    );

    test(
      'Given a DTO with a nested DTO field, '
      'When probed, '
      'Then the parent schema contains a branch whose inner schema has the nested fields',
      () {
        final schema = probeDummySchemaForTesting<_NestedParent>(
          _NestedParent.fromJson,
        );

        expect(schema.fields.length, 2);
        expect(schema.unresolved, isEmpty);

        // title is a flat leaf.
        final titleField = schema.fields['title'];
        expect(titleField, isA<TDummySchemaLeaf>());
        expect((titleField! as TDummySchemaLeaf).type, String);

        // address is a branch with nested schema.
        final addressField = schema.fields['address'];
        expect(addressField, isA<TDummySchemaBranch>());

        final nested = (addressField! as TDummySchemaBranch).nested;
        expect(nested.fields.length, 2);
        expect(nested.unresolved, isEmpty);

        expect(
          (nested.fields['street']! as TDummySchemaLeaf).type,
          String,
        );
        expect(
          (nested.fields['zip']! as TDummySchemaLeaf).type,
          int,
        );
      },
    );

    test(
      'Given a DTO that reads a list field as List<dynamic>, '
      'When probed, '
      'Then the schema contains a leaf of type List<dynamic> and the probe does not crash',
      () {
        final schema = probeDummySchemaForTesting<_ListDto>(
          _ListDto.fromJson,
        );

        expect(schema.fields.length, 2);

        final tagsField = schema.fields['tags'];
        expect(tagsField, isA<TDummySchemaLeaf>());
        expect((tagsField! as TDummySchemaLeaf).type, List<dynamic>);
      },
    );

    test(
      'Given a DTO that casts a field to an unsupported type (Uri), '
      'When probed, '
      'Then the field lands in unresolved and the probe terminates',
      () {
        final schema = probeDummySchemaForTesting<_UnsupportedTypeDto>(
          _UnsupportedTypeDto.fromJson,
        );

        // name should resolve successfully.
        expect(schema.fields.containsKey('name'), isTrue);
        expect(
          (schema.fields['name']! as TDummySchemaLeaf).type,
          String,
        );

        // link is unsupported — should be in unresolved.
        expect(schema.unresolved, contains('link'));
        expect(schema.fields.containsKey('link'), isFalse);
      },
    );

    test(
      'Given the same probe invocation run twice, '
      'When the schemas are compared structurally, '
      'Then they are equal',
      () {
        final schemaA = probeDummySchemaForTesting<_FlatDto>(
          _FlatDto.fromJson,
        );
        final schemaB = probeDummySchemaForTesting<_FlatDto>(
          _FlatDto.fromJson,
        );

        expect(schemaA.fields.length, schemaB.fields.length);
        expect(schemaA.unresolved.length, schemaB.unresolved.length);

        for (final key in schemaA.fields.keys) {
          final a = schemaA.fields[key]! as TDummySchemaLeaf;
          final b = schemaB.fields[key]! as TDummySchemaLeaf;
          expect(a.type, b.type, reason: 'Type mismatch for field: $key');
        }
      },
    );

    test(
      'Given a DTO that reads metadata as a raw Map<String, dynamic> without nesting, '
      'When probed, '
      'Then the field resolves as a leaf of type Map<String, dynamic>, not a branch',
      () {
        final schema = probeDummySchemaForTesting<_RawMapDto>(
          _RawMapDto.fromJson,
        );

        expect(schema.fields.length, 2);
        expect(schema.unresolved, isEmpty);

        final metadataField = schema.fields['metadata'];
        expect(metadataField, isA<TDummySchemaLeaf>());
        expect(
          (metadataField! as TDummySchemaLeaf).type,
          Map<String, dynamic>,
        );
      },
    );

    test(
      'Given a DTO with Timestamp and double fields, '
      'When probed, '
      'Then the schema resolves Timestamp and double with correct types',
      () {
        final schema = probeDummySchemaForTesting<_TimestampDto>(
          _TimestampDto.fromJson,
        );

        expect(schema.fields.length, 2);
        expect(schema.unresolved, isEmpty);

        final createdAtField = schema.fields['createdAt'];
        expect(createdAtField, isA<TDummySchemaLeaf>());
        expect((createdAtField! as TDummySchemaLeaf).type, Timestamp);

        final scoreField = schema.fields['score'];
        expect(scoreField, isA<TDummySchemaLeaf>());
        expect((scoreField! as TDummySchemaLeaf).type, double);
      },
    );
  });
}
