import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/tool.dart';

part 'mcp.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Mcp extends Tool {
  const Mcp({
    required super.name,
    super.description,
    super.abilities,
  });

  factory Mcp.fromJson(Map<String, dynamic> json) => _$McpFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$McpToJson(this);
}
