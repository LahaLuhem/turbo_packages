// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cli.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cli _$CliFromJson(Map<String, dynamic> json) => Cli(
  name: json['name'] as String,
  description: json['description'] as String?,
  abilities: (json['abilities'] as List<dynamic>?)
      ?.map((e) => ToolAbility.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CliToJson(Cli instance) => <String, dynamic>{
  'name': instance.name,
  'description': ?instance.description,
  'abilities': ?instance.abilities?.map((e) => e.toJson()).toList(),
};
