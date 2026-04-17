import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/turbo_promptable.dart';

export 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

part 'tool_ability.g.dart';

/// A reusable description of any tool-shaped thing: CLI tools, REST/GraphQL
/// APIs, MCP servers, SDK libraries, browser automation, and so on.
///
/// [description] captures the tool's purpose. [setup] lists prerequisites or
/// session-bootstrap steps. [rules] are cross-cutting usage rules. [abilities]
/// enumerates the operations the tool exposes. [examples] and [notes] carry
/// tool-level usage examples and caveats.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class ToolAbility extends TPromptable {
  const ToolAbility({
    required super.name,
    required super.description,
    required this.input,
    required this.output,
  });

  final Input input;
  final Output output;

  factory ToolAbility.fromJson(Map<String, dynamic> json) =>
      _$ToolAbilityFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ToolAbilityToJson(this);
}
