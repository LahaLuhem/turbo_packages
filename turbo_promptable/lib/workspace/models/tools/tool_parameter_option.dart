import 'package:json_annotation/json_annotation.dart';

part 'tool_parameter_option.g.dart';

/// A single allowed value for an enum-like [ToolParameter] (e.g. a CLI flag
/// value, an API enum option, or an MCP parameter variant).
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class ToolParameterOption {
  const ToolParameterOption({
    required this.name,
    this.description,
    this.isRequired,
    this.isDefault,
  });

  final String name;
  final String? description;
  final bool? isRequired;
  final bool? isDefault;

  factory ToolParameterOption.fromJson(Map<String, dynamic> json) =>
      _$ToolParameterOptionFromJson(json);
  Map<String, dynamic> toJson() => _$ToolParameterOptionToJson(this);
}
