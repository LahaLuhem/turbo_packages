import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/tool.dart';

part 'mcp.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Mcp extends Tool {
  const Mcp({
    required super.name,
    super.metaData,
    super.config,
    super.description,
    super.setup,
    super.rules,
    super.commands,
    super.examples,
    super.notes,
  });

  factory Mcp.fromJson(Map<String, dynamic> json) => _$McpFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$McpToJson(this);
}
