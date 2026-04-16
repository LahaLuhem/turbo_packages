import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/tools/tool_parameter_option.dart';

export 'package:turbo_promptable/workspace/models/tools/tool_parameter_option.dart';

part 'tool_parameter.g.dart';

/// A single input accepted by a [ToolCommand]: a CLI flag, an API argument,
/// an MCP tool parameter, or an SDK method argument.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class ToolParameter {
  const ToolParameter({
    required this.name,
    this.description,
    this.type,
    this.required,
    this.options,
  });

  final String name;
  final String? description;
  final String? type;
  final bool? required;
  final List<ToolParameterOption>? options;

  factory ToolParameter.fromJson(Map<String, dynamic> json) =>
      _$ToolParameterFromJson(json);
  Map<String, dynamic> toJson() => _$ToolParameterToJson(this);
}
