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

  static final Cli Function(Map<String, dynamic> json) fromJsonFactory =
      _$CliFromJson;
  factory Cli.fromJson(Map<String, dynamic> json) => _$CliFromJson(json);
  static final Map<String, dynamic> Function(Cli value) toJsonFactory =
      _$CliToJson;
  @override
  Map<String, dynamic> toJson() => _$CliToJson(this);
}
