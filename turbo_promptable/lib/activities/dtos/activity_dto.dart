import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/actors/dtos/agent_dto.dart';
import 'package:turbo_promptable/actors/dtos/persona_dto.dart';
import 'package:turbo_promptable/actors/dtos/role_dto.dart';
import 'package:turbo_promptable/shared/abstracts/has_to_json.dart';
import 'package:turbo_promptable/skills/dtos/instruction_dto.dart';
import 'package:turbo_promptable/skills/workflows/dtos/workflow_dto.dart';

import '../../shared/abstracts/turbo_promptable.dart';

part 'activity_dto.g.dart';

@JsonSerializable(
  includeIfNull: true,
  explicitToJson: true,
  genericArgumentFactories: true,
)
class ActivityDto<INPUT extends HasToJson, OUTPUT extends HasToJson>
    extends TurboPromptable {
  ActivityDto({
    required this.output,
    required this.workflow,
    this.input,
    this.instructions,
    this.agents,
    super.metaData,
  });

  final RoleDto? role;
  final PersonaDto? persona;
  final INPUT? input;
  final WorkflowDto workflow;
  final List<AgentDto>? agents;
  final OUTPUT? output;
  final List<InstructionDto>? instructions;

  static const fromJsonFactory = _$ActivityDtoFromJson;
  factory ActivityDto.fromJson(
    Map<String, dynamic> json,
    INPUT Function(Object? json) fromJsonINPUT,
    OUTPUT Function(Object? json) fromJsonOUTPUT,
  ) => _$ActivityDtoFromJson(
    json,
    fromJsonINPUT,
    fromJsonOUTPUT,
  );
  static const toJsonFactory = _$ActivityDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$ActivityDtoToJson(
    this,
    (value) => value.toJson(),
    (value) => value.toJson(),
  );

  @override
  String toString() =>
      'ActivityDto{input: $input, instructions: $instructions, agents: $agents, output: $output, workflow: $workflow}';
}
