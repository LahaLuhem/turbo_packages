// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamDto _$TeamDtoFromJson(Map<String, dynamic> json) => TeamDto(
  areas: (json['areas'] as List<dynamic>?)
      ?.map((e) => AreaDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  roles: (json['roles'] as List<dynamic>?)
      ?.map((e) => RoleDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TeamDtoToJson(TeamDto instance) => <String, dynamic>{
  'areas': instance.areas?.map((e) => e.toJson()).toList(),
  'roles': instance.roles?.map((e) => e.toJson()).toList(),
};
