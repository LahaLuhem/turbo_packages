/// A serialization abstraction for the turbo ecosystem with multi-format support.
///
/// This library provides abstract base classes for objects that need to be
/// serialized to multiple data formats (JSON, YAML, Markdown, XML) and
/// validated before being written to storage systems like Firestore.
///
/// ## Core Classes
///
/// - [TWriteable]: Base class for objects that can be written to Firestore
///   with validation support
/// - [TWriteableId]: Base class for writeable objects with string identifiers
/// - [TSerializable]: Base class for objects that can be serialized to
///   multiple formats (JSON, YAML, Markdown, XML)
/// - [TSerializableId]: Base class for serializable objects with identifiers
///
/// ## Usage
///
/// ### Basic Serializable Object
///
/// ```dart
/// class User extends TSerializable {
///   User({required this.name, required this.age});
///
///   final String name;
///   final int age;
///
///   @override
///   Map<String, dynamic> toJson() => {
///     'name': name,
///     'age': age,
///   };
///
///   @override
///   String Function(Map<String, dynamic> json)? get yamlBuilder =>
///       (json) => 'name: ${json['name']}\nage: ${json['age']}';
/// }
/// ```
///
/// ### Serializable Object with ID
///
/// ```dart
/// class Document extends TSerializableId {
///   Document({required this.id, required this.content});
///
///   @override
///   final String id;
///   final String content;
///
///   @override
///   Map<String, dynamic> toJson() => {
///     'id': id,
///     'content': content,
///   };
/// }
/// ```
///
/// ## Validation
///
/// All classes support validation through the [TWriteable.validate] method:
///
/// ```dart
/// @override
/// TurboResponse<T>? validate<T>() {
///   if (name.isEmpty) {
///     return TurboResponse.fail(error: 'Name cannot be empty');
///   }
///   return null;
/// }
/// ```
library turbo_serializable;

export 'abstracts/t_serializable.dart';
export 'abstracts/t_serializable_custom_id.dart';
export 'abstracts/t_serializable_id.dart';
export 'abstracts/t_writeable.dart';
export 'abstracts/t_writeable_custom_id.dart';
export 'abstracts/t_writeable_id.dart';
export 'extensions/ts_map_extension.dart';
export 'extensions/ts_string_extension.dart';
export 'markdown/factories/t_md_factory.dart';
export 'markdown/typedefs/t_markdown_typedefs.dart';
export 'xml/factories/t_xml_factory.dart';
export 'xml/typedefs/t_xml_typedefs.dart';
export 'yaml/factories/t_yaml_factory.dart';
export 'yaml/typedefs/t_yaml_typedefs.dart';
