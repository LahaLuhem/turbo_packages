// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoleDto _$RoleDtoFromJson(Map<String, dynamic> json) => RoleDto(
  expertise: ExpertiseDto.fromJson(json['expertise'] as Map<String, dynamic>),
  persona: json['persona'] == null
      ? null
      : PersonaDto.fromJson(json['persona'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RoleDtoToJson(RoleDto instance) => <String, dynamic>{
  'persona': instance.persona?.toJson(),
  'expertise': instance.expertise.toJson(),
};
