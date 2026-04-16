import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';
import 'package:turbo_promptable/workspace/models/tools/tool_command.dart';

export 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';
export 'package:turbo_promptable/workspace/models/tools/tool_command.dart';

part 'tool.g.dart';

/// A reusable description of any tool-shaped thing: CLI tools, REST/GraphQL
/// APIs, MCP servers, SDK libraries, browser automation, and so on.
///
/// [description] captures the tool's purpose. [setup] lists prerequisites or
/// session-bootstrap steps. [rules] are cross-cutting usage rules. [commands]
/// enumerates the operations the tool exposes. [examples] and [notes] carry
/// tool-level usage examples and caveats.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Tool extends TPromptable {
  const Tool({
    required super.name,
    super.metaData,
    this.description,
    this.setup,
    this.rules,
    this.commands,
    this.examples,
    this.notes,
  });

  final String? description;
  final List<String>? setup;
  final List<String>? rules;
  final List<ToolCommand>? commands;
  final List<String>? examples;
  final List<String>? notes;

  factory Tool.fromJson(Map<String, dynamic> json) => _$ToolFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ToolToJson(this);
}
