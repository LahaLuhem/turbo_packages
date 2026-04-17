// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'script.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Script _$ScriptFromJson(Map<String, dynamic> json) => Script(
  name: json['name'] as String,
  description: json['description'] as String?,
  abilities: (json['abilities'] as List<dynamic>?)
      ?.map((e) => ToolAbility.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ScriptToJson(Script instance) => <String, dynamic>{
  'name': instance.name,
  'description': ?instance.description,
  'abilities': ?instance.abilities?.map((e) => e.toJson()).toList(),
};
