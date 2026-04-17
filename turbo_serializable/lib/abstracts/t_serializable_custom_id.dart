import 'package:turbo_serializable/abstracts/t_writeable_custom_id.dart';

/// Abstract base class providing serialization for objects with typed identifiers.
///
/// Extends [TWriteableCustomId] and adds convenience methods for converting
/// the object into YAML, Markdown, and XML representations. This class
/// provides type-safe ID handling through the generic type parameter [T].
///
/// Type parameter [T] represents the type of the object's identifier
/// (typically [String], but can be any non-nullable type).
///
/// Example with String ID:
/// ```dart
/// class User extends TSerializableCustomId<String> {
///   User({required this.name});
///
///   final String name;
///
///   @override
///   String get id => 'user-123';
///
///   @override
///   Map<String, dynamic> toJson() => {'name': name};
/// }
/// ```
///
/// Example with custom ID type:
/// ```dart
/// class CustomId {
///   const CustomId(this.value);
///   final int value;
/// }
///
/// class Document extends TSerializableCustomId<CustomId> {
///   Document() : _id = CustomId(42);
///
///   final CustomId _id;
///
///   @override
///   CustomId get id => _id;
///
///   @override
///   Map<String, dynamic> toJson() => {'id': _id.value};
/// }
/// ```
abstract class TSerializableCustomId<T> extends TWriteableCustomId<T> {
  /// Converts this object to a YAML string.
  ///
  /// Uses [yamlBuilder] to serialize the result of [toJson()].
  /// Throws an [UnimplementedError] if [yamlBuilder] is not provided.
  String toYaml() {
    if (yamlBuilder == null) throw UnimplementedError();
    return yamlBuilder!(toJson());
  }

  /// Returns a function that builds a YAML string from a JSON map.
  ///
  /// Subclasses should override this getter to supply their YAML builder, or
  /// set it externally, if applicable. If not provided, [toYaml()] will throw.
  String Function(Map<String, dynamic> json)? get yamlBuilder;

  /// Converts this object to a Markdown string.
  ///
  /// Uses [markdownBuilder] to serialize the result of [toJson()].
  /// Throws an [UnimplementedError] if [markdownBuilder] is not provided.
  String toMarkdown() {
    if (markdownBuilder == null) throw UnimplementedError();
    return markdownBuilder!(toJson());
  }

  /// Returns a function that builds a Markdown string from a JSON map.
  ///
  /// Subclasses should override this getter to supply their Markdown builder, or
  /// set it externally, if applicable. If not provided, [toMarkdown()] will throw.
  String Function(Map<String, dynamic> json)? get markdownBuilder;

  /// Converts this object to an XML string.
  ///
  /// Uses [xmlBuilder] to serialize the result of [toJson()].
  /// Throws an [UnimplementedError] if [xmlBuilder] is not provided.
  String toXml() {
    if (xmlBuilder == null) throw UnimplementedError();
    return xmlBuilder!(toJson());
  }

  /// Returns a function that builds an XML string from a JSON map.
  ///
  /// Subclasses should override this getter to supply their XML builder, or
  /// set it externally, if applicable. If not provided, [toXml()] will throw.
  String Function(Map<String, dynamic> json)? get xmlBuilder;
}
