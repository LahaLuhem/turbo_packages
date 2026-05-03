/// An abstract class that defines the core variables required for Turbo Firestore documents.
///
/// [id] - The unique identifier for the document
/// [now] - The timestamp when the document was created/updated
/// [userId] - The ID of the user who owns/created the document
class TVars {
  const TVars({
    required this.id,
    required this.now,
    required this.userId,
    required this.defaultIdValue,
    required this.unknownIdValue,
    required this.unknownValue,
  });

  final String? userId;
  final String id;
  final DateTime now;
  final String defaultIdValue;
  final String unknownIdValue;
  final String unknownValue;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TVars &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'TurboAuthVars{userId: $userId}';
  }
}
