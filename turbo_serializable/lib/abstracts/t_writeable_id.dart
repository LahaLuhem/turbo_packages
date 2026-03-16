import 'package:turbo_serializable/abstracts/t_writeable.dart';

/// A base class for objects that require a string identifier.
///
/// This abstract class extends [TWriteable] and adds a requirement for a
/// string-based unique identifier. It provides a simpler alternative to
/// [TWriteableCustomId] when you only need string IDs.
///
/// Example:
/// ```dart
/// class User extends TWriteableId {
///   User({required this.name});
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
/// }
/// ```
abstract class TWriteableId extends TWriteable {
  const TWriteableId();

  /// The unique string identifier for this object.
  ///
  /// This getter must be implemented by subclasses to provide the object's
  /// unique identifier. The ID should be:
  /// - Unique within its collection
  /// - Consistent across app restarts for the same object
  /// - Valid as a Firestore document ID
  ///
  /// Example:
  /// ```dart
  /// @override
  /// String get id => 'user-${DateTime.now().millisecondsSinceEpoch}';
  /// ```
  String get id;
}
