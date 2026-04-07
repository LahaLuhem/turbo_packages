import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/memory.dart';

part 'meeting.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
abstract class Meeting extends Memory {
  Meeting({
    required super.name,
    super.metaData,
    super.config,
  });

  static final Meeting Function(Map<String, dynamic> json) fromJsonFactory =
      _$MeetingFromJson;
  factory Meeting.fromJson(Map<String, dynamic> json) =>
      _$MeetingFromJson(json);
  static final Map<String, dynamic> Function(Meeting value) toJsonFactory =
      _$MeetingToJson;
  @override
  Map<String, dynamic> toJson() => _$MeetingToJson(this);
}
