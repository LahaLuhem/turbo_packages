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

  factory Script.fromJson(Map<String, dynamic> json) => _$TScriptFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TScriptToJson(this);
}
