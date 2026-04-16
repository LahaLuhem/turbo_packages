import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/turbo_promptable.dart';
import 'package:turbo_promptable/workspace/models/checklists/success_criteria.dart';
import 'package:turbo_promptable/workspace/models/root/checklist.dart';
import 'package:turbo_promptable/workspace/models/root/template.dart';

part 'output.g.dart';

/// The response side of a [Step] or [Activity]: a prose [response] describing
/// exactly what the step produces, with optional [template] and [checklists].
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Output<SCHEMA extends Object> extends TPromptable {
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
  final SCHEMA schema;

  factory Output.fromJson(Map<String, dynamic> json) => _$OutputFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$OutputToJson(this);
}
