// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgentDto _$AgentDtoFromJson(Map<String, dynamic> json) => AgentDto(
  role: RoleDto.fromJson(json['role'] as Map<String, dynamic>),
  persona: json['persona'] == null
      ? null
      : PersonaDto.fromJson(json['persona'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AgentDtoToJson(AgentDto instance) => <String, dynamic>{
  'role': instance.role.toJson(),
  'persona': instance.persona?.toJson(),
};
