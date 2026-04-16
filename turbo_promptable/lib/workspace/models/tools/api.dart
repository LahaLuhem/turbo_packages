import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/tool.dart';

part 'api.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Api extends Tool {
  const Api({
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

  factory Api.fromJson(Map<String, dynamic> json) => _$ApiFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ApiToJson(this);
}
