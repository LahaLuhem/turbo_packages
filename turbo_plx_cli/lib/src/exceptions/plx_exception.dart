class PlxException implements Exception {
  final String message;

  const PlxException(this.message);

  @override
  String toString() => 'PlxException: $message';
}
