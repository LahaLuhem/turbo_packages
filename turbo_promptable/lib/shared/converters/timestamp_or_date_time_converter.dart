import 'package:json_annotation/json_annotation.dart';

class TimestampOrDateTimeConverter implements JsonConverter<DateTime, Object?> {
  const TimestampOrDateTimeConverter();

  @override
  DateTime fromJson(Object? json) {
    if (json == null) {
      throw ArgumentError('TimestampOrDateTimeConverter: null not allowed');
    }
    if (json is DateTime) return json;
    if (json is String) return DateTime.parse(json);
    final toDate = _tryToDate(json);
    if (toDate != null) return toDate;
    throw ArgumentError(
      'TimestampOrDateTimeConverter: expected Timestamp, String, or DateTime, got ${json.runtimeType}',
    );
  }

  @override
  Object toJson(DateTime object) => object;

  static DateTime? _tryToDate(Object json) {
    try {
      return (json as dynamic).toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }
}
