import 'package:json_annotation/json_annotation.dart';

class DurationDaysConverter implements JsonConverter<Duration, int> {
  const DurationDaysConverter();

  @override
  Duration fromJson(int duration) => Duration(days: duration);

  @override
  int toJson(Duration duration) => duration.inDays;
}
