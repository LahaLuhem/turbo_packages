/// API operation variables (id, now).
/// Pure Dart; no Flutter/Firestore dependencies.
class ApiVars {
  const ApiVars({
    required this.id,
    required this.now,
  });

  final String id;
  final DateTime now;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiVars &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          now == other.now;

  @override
  int get hashCode => id.hashCode ^ now.hashCode;

  @override
  String toString() => 'ApiVars{id: $id, now: $now}';
}

/// Auth-scoped API variables (id, userId, now).
/// Pure Dart; no Flutter/Firestore dependencies.
/// Use in DTO create factories for plx and plaza.
class AuthVars extends ApiVars {
  const AuthVars({
    required super.id,
    required super.now,
    required this.userId,
  });

  final String userId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthVars &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() => 'AuthVars{userId: $userId}';
}
