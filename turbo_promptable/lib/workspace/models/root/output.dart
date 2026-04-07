import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';
import 'package:turbo_promptable/workspace/models/root/checklist.dart';
import 'package:turbo_promptable/workspace/models/root/template.dart';

part 'output.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Output extends TPromptable {
  Output({
    required super.name,
    super.metaData,
    this.acceptanceCriteria,
    this.template,
  });

  final Template? template;
  final Checklist? acceptanceCriteria;

  factory Output.fromJson(Map<String, dynamic> json) => _$OutputFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$OutputToJson(this);
}
