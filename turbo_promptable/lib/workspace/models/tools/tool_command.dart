import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/tools/tool_parameter.dart';

export 'package:turbo_promptable/workspace/models/tools/tool_parameter.dart';

part 'tool_command.g.dart';

/// A single operation exposed by a [Tool]: a CLI subcommand, a REST/GraphQL
/// endpoint, an MCP tool, or an SDK method.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class ToolCommand {
  const ToolCommand({
    required this.name,
    this.description,
    this.parameters,
    this.rules,
    this.examples,
    this.notes,
  });

  final String name;
  final String? description;
  final List<ToolParameter>? parameters;
  final List<String>? rules;
  final List<String>? examples;
  final List<String>? notes;

  factory ToolCommand.fromJson(Map<String, dynamic> json) =>
      _$ToolCommandFromJson(json);
  Map<String, dynamic> toJson() => _$ToolCommandToJson(this);
}
