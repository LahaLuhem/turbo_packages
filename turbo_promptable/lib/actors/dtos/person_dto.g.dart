// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonDto _$PersonDtoFromJson(Map<String, dynamic> json) => PersonDto(
  role: json['role'] == null
      ? null
      : RoleDto.fromJson(json['role'] as Map<String, dynamic>),
  persona: json['persona'] == null
      ? null
      : PersonaDto.fromJson(json['persona'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PersonDtoToJson(PersonDto instance) => <String, dynamic>{
  'role': instance.role?.toJson(),
  'persona': instance.persona?.toJson(),
};
