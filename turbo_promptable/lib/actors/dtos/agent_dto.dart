import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/actors/dtos/persona_dto.dart';
import 'package:turbo_promptable/actors/dtos/role_dto.dart';
import 'package:turbo_promptable/shared/abstracts/turbo_promptable.dart';

part 'agent_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class AgentDto extends TurboPromptable {
  AgentDto({
    required this.role,
    this.persona,
  });

  final RoleDto role;
  final PersonaDto? persona;

  static const fromJsonFactory = _$AgentDtoFromJson;
  factory AgentDto.fromJson(Map<String, dynamic> json) =>
      _$AgentDtoFromJson(json);
  static const toJsonFactory = _$AgentDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$AgentDtoToJson(this);

  @override
  String toString() => 'AgentDto{role: $role, persona: $persona}';

  AgentDto copyWith({
    RoleDto? role,
    PersonaDto? persona,
  }) => AgentDto(
    role: role ?? this.role,
    persona: persona ?? this.persona,
  );
}
