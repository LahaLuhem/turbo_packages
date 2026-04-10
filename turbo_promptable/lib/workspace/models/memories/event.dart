import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/memory.dart';

part 'event.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Event extends Memory {
  const Event({
    required super.name,
    super.metaData,
    super.config,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$EventToJson(this);
}
