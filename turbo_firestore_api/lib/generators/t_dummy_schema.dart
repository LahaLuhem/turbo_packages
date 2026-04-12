/// A single field entry in a [TDummySchema], representing either a flat
/// resolved type or a nested DTO sub-schema.
///
/// Consumers encounter this type when walking the schema tree produced by the
/// probing phase, typically via exhaustive `switch` expressions.
sealed class TDummySchemaField {
  const TDummySchemaField();
}

/// A flat field whose resolved runtime type was determined by a successful cast
/// during probing.
///
/// Consumers encounter this variant for primitive and simple Firestore types
/// such as `String`, `int`, `DateTime`, `Timestamp`, etc.
final class TDummySchemaLeaf extends TDummySchemaField {
  const TDummySchemaLeaf(this.type);

  /// The runtime [Type] that the probing phase resolved for this field.
  final Type type;
}

/// A nested DTO field whose probing recursed into another `fromJson` invocation
/// and produced its own sub-schema.
///
/// Consumers encounter this variant when a field maps to another DTO rather
/// than a primitive type.
final class TDummySchemaBranch extends TDummySchemaField {
  const TDummySchemaBranch(this.nested);

  /// The recursively-discovered schema for the nested DTO.
  final TDummySchema nested;
}

/// The output of the probing phase: a recursive description of an entity's
/// field names, their resolved types or nested sub-schemas, and any fields that
/// could not be resolved.
///
/// Consumers encounter this type when building a [TValueGeneratorRegistry] or
/// when the dummy API walks the schema tree to generate fake documents.
final class TDummySchema {
  const TDummySchema({
    required this.fields,
    required this.unresolved,
  });

  /// Maps each resolved field name to its [TDummySchemaField] — either a
  /// [TDummySchemaLeaf] for flat types or a [TDummySchemaBranch] for nested
  /// DTOs.
  final Map<String, TDummySchemaField> fields;

  /// Field names that could not be resolved to any candidate type during
  /// probing. The registry generates visible placeholder values for these.
  final Set<String> unresolved;
}
