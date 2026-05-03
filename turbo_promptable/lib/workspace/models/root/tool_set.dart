import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/tool.dart';

export 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';
export 'package:turbo_promptable/workspace/models/tools/tool_ability.dart';

part 'tool_set.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class ToolSet extends Tool {
  const ToolSet({
    required super.name,
    required super.description,
    super.abilities,
  });

  factory ToolSet.fromJson(Map<String, dynamic> json) =>
      _$ToolSetFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ToolSetToJson(this);
}
