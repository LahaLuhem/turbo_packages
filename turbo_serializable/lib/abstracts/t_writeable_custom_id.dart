import 'package:turbo_serializable/abstracts/t_writeable.dart';

/// A base class for Firestore documents that require a unique identifier.
///
/// This abstract class extends [TWriteable] and adds functionality for handling
/// document identifiers in Firestore. It provides a type-safe way to work with
/// document IDs and includes functionality to track whether a document is a local default.
///
/// Type parameter [T] represents the type of the document's ID (typically [String]).
/// The ID type must be non-nullable (extends [Object]).
///
/// Example of a basic implementation:
/// ```dart
/// class User extends TurboWriteableId<String> {
///   User({
///     required this.name,
///     this.isDefault = false,
///   }) : super(isLocalDefault: isDefault);
///
///   final String name;
///
///   @override
///   String get id => 'user-123';
///
///   @override
///   Map<String, dynamic> toJson() => {
///     'name': name,
///   };
///
///   @override
///   TurboResponse<void>? validate<void>() {
///     if (name.isEmpty) {
///       return TurboResponse.fail(message: 'Name cannot be empty');
///     }
///     return null;
///   }
/// }
/// ```
///
/// Example usage with custom ID type:
/// ```dart
/// class CustomId {
///   const CustomId(this.value);
///   final String value;
///
///   @override
///   String toString() => value;
/// }
///
/// class Document extends TurboWriteableId<CustomId> {
///   Document() : super();
///
///   @override
///   CustomId get id => CustomId('doc-123');
/// }
/// ```
abstract class TWriteableCustomId<T> extends TWriteable {
  const TWriteableCustomId();

  /// The unique identifier for this document.
  ///
  /// This getter must be implemented by subclasses to provide the document's
  /// unique identifier of type [T]. The ID should be:
  /// - Unique within its collection
  /// - Consistent across app restarts for the same document
  /// - Valid as a Firestore document ID if using String type
  ///
  /// Example:
  /// ```dart
  /// @override
  /// String get id => 'user-${DateTime.now().millisecondsSinceEpoch}';
  /// ```
  T get id;
}
