import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/activities/dtos/guard_rail_dto.dart';
import 'package:turbo_promptable/shared/abstracts/turbo_promptable.dart';
import 'package:turbo_promptable/skills/workflows/dtos/workflow_step.dart';

part 'workflow_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class WorkflowDto extends TurboPromptable {
  WorkflowDto({
    this.guardRails,
    required this.steps,
  });

  final List<GuardRailDto>? guardRails;
  final List<WorkflowStep> steps;

  static const fromJsonFactory = _$WorkflowDtoFromJson;
  factory WorkflowDto.fromJson(Map<String, dynamic> json) =>
      _$WorkflowDtoFromJson(json);
  static const toJsonFactory = _$WorkflowDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$WorkflowDtoToJson(this);

  WorkflowDto copyWith({
    List<GuardRailDto>? guardRails,
    List<WorkflowStep>? steps,
  }) {
    return WorkflowDto(
      guardRails: guardRails ?? this.guardRails,
      steps: steps ?? this.steps,
    );
  }

  @override
  String toString() => 'WorkflowDto{guardRails: $guardRails, steps: $steps}';
}
