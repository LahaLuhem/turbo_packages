import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/activities/dtos/guard_rail_dto.dart';
import 'package:turbo_promptable/activities/enums/workflow_step_type.dart';
import 'package:turbo_promptable/shared/abstracts/turbo_promptable.dart';

part 'workflow_step.g.dart';

@JsonSerializable(
  includeIfNull: true,
  explicitToJson: true,
  genericArgumentFactories: true,
)
class WorkflowStep<INPUT, OUTPUT> extends TurboPromptable {
  WorkflowStep({
    required this.workflowStepType,
    this.guardRails,
    this.input,
    this.output,
  });

  final INPUT? input;
  final List<GuardRailDto>? guardRails;
  final OUTPUT? output;
  final WorkflowStepType workflowStepType;

  factory WorkflowStep.fromJson(
    Map<String, dynamic> json,
    INPUT Function(Object? json) fromJsonINPUT,
    OUTPUT Function(Object? json) fromJsonOUTPUT,
  ) => _$WorkflowStepFromJson(json, fromJsonINPUT, fromJsonOUTPUT);

  Map<String, dynamic> toJsonWithConverters(
    Object? Function(INPUT value) toJsonINPUT,
    Object? Function(OUTPUT value) toJsonOUTPUT,
  ) => _$WorkflowStepToJson(this, toJsonINPUT, toJsonOUTPUT);

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError(
      'WorkflowStep.toJson() requires type converters. Use toJsonWithConverters() instead.',
    );
  }

  @override
  String toString() =>
      'WorkflowStep{workflowStepType: $workflowStepType, guardRails: $guardRails, input: $input, output: $output}';
}
