import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/tool.dart';

part 'script.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Script extends Tool {
  Script({
    required super.name,
    super.metaData,
    super.config,
  });

  static final Script Function(Map<String, dynamic> json) fromJsonFactory =
      _$ScriptFromJson;
  factory Script.fromJson(Map<String, dynamic> json) => _$ScriptFromJson(json);
  static final Map<String, dynamic> Function(Script value) toJsonFactory =
      _$ScriptToJson;
  @override
  Map<String, dynamic> toJson() => _$ScriptToJson(this);
}
