import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/tool.dart';

part 'cli.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Cli extends Tool {
  Cli({
    required super.name,
    super.metaData,
    super.config,
  });

  factory Cli.fromJson(Map<String, dynamic> json) => _$TCliFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TCliToJson(this);
}
