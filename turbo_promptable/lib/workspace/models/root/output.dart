import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/turbo_promptable.dart';
import 'package:turbo_promptable/workspace/models/checklists/success_criteria.dart';

part 'output.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Output extends TPromptable {
  const Output({
    required super.name,
    super.metaData,
    this.successCriteria,
    this.constraints,
    this.nonGoals,
    required this.schema,
  });

  final SuccessCriteria? successCriteria;
  final Constraints? constraints;
  final NonGoals? nonGoals;
  final String schema;

  factory Output.fromJson(Map<String, dynamic> json) => _$OutputFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$OutputToJson(this);
}
