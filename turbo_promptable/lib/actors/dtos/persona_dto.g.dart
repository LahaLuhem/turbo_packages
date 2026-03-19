// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persona_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonaDto _$PersonaDtoFromJson(Map<String, dynamic> json) => PersonaDto(
  achievements: (json['achievements'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  background: json['background'] as String?,
  communicationStyle: json['communicationStyle'] as String?,
  nickname: json['nickname'] as String?,
  preferences: (json['preferences'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  resume: (json['resume'] as List<dynamic>?)?.map((e) => e as String).toList(),
  values: (json['values'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$PersonaDtoToJson(PersonaDto instance) =>
    <String, dynamic>{
      'achievements': instance.achievements,
      'preferences': instance.preferences,
      'resume': instance.resume,
      'values': instance.values,
      'background': instance.background,
      'communicationStyle': instance.communicationStyle,
      'nickname': instance.nickname,
    };
