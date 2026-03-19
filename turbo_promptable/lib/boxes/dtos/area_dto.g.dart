// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'area_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AreaDto _$AreaDtoFromJson(Map<String, dynamic> json) => AreaDto(
  roles: (json['roles'] as List<dynamic>?)
      ?.map((e) => RoleDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$AreaDtoToJson(AreaDto instance) => <String, dynamic>{
  'roles': instance.roles?.map((e) => e.toJson()).toList(),
};
