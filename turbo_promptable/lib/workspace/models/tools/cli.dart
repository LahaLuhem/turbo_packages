import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/tool.dart';

part 'cli.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Cli extends Tool {
  const Cli({
    required super.name,
    super.description,
    super.abilities,
  });

  factory Cli.fromJson(Map<String, dynamic> json) => _$CliFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$CliToJson(this);
}
