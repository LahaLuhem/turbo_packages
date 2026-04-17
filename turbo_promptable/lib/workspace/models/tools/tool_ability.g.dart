// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool_ability.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ToolAbility _$ToolAbilityFromJson(Map<String, dynamic> json) => ToolAbility(
  name: json['name'] as String,
  description: json['description'] as String?,
  input: Input.fromJson(json['input'] as Map<String, dynamic>),
  output: Output.fromJson(json['output'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ToolAbilityToJson(ToolAbility instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': ?instance.description,
      'input': instance.input.toJson(),
      'output': instance.output.toJson(),
    };
