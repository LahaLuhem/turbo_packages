import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/checklist.dart';
import 'package:turbo_promptable/workspace/models/root/prompt_field.dart';
import 'package:turbo_promptable/workspace/models/root/template.dart';

part 'output.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Output extends TPromptable {
  const Output({
    required super.name,
    super.metaData,
    required this.fields,
    this.checklists,
    this.template,
  });

  final List<PromptField> fields;
  final Template? template;
  final List<Checklist>? checklists;

  factory Output.fromJson(Map<String, dynamic> json) => _$OutputFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$OutputToJson(this);
}
