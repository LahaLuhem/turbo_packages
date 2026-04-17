import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/tools/tool_ability.dart';

export 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

part 'tool.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Tool extends TPromptable {
  const Tool({
    required super.name,
    required super.description,
    this.abilities,
  });

  final List<ToolAbility>? abilities;

  factory Tool.fromJson(Map<String, dynamic> json) => _$ToolFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ToolToJson(this);
}
