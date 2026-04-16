// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool_command.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ToolCommand _$ToolCommandFromJson(Map<String, dynamic> json) => ToolCommand(
  name: json['name'] as String,
  description: json['description'] as String?,
  parameters: (json['parameters'] as List<dynamic>?)
      ?.map((e) => ToolParameter.fromJson(e as Map<String, dynamic>))
      .toList(),
  rules: (json['rules'] as List<dynamic>?)?.map((e) => e as String).toList(),
  examples: (json['examples'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  notes: (json['notes'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$ToolCommandToJson(ToolCommand instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': ?instance.description,
      'parameters': ?instance.parameters?.map((e) => e.toJson()).toList(),
      'rules': ?instance.rules,
      'examples': ?instance.examples,
      'notes': ?instance.notes,
    };
