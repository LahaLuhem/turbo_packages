import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/memory.dart';

part 'event.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
abstract class Event extends Memory {
  Event({
    required super.name,
    super.metaData,
    super.config,
  });

  static const Event Function(Map<String, dynamic> json) fromJsonFactory = _$EventFromJson;
  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  static const Map<String, dynamic> Function(Event value) toJsonFactory = _$EventToJson;
  @override
  Map<String, dynamic> toJson() => _$EventToJson(this);
}
