import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

part 'template.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Template extends TPromptable {
  const Template(
    String name, {
    super.value,
    super.metaData,
  }) : super(name: name);

  factory Template.fromJson(Map<String, dynamic> json) =>
      _$TemplateFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TemplateToJson(this);
}
