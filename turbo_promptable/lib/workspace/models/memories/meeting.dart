import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/memory.dart';

part 'meeting.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Meeting extends Memory {
  const Meeting({
    required super.name,
    super.metaData,
    super.config,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) =>
      _$MeetingFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$MeetingToJson(this);
}
