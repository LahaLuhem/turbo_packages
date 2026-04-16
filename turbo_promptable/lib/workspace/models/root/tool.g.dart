// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tool _$ToolFromJson(Map<String, dynamic> json) => Tool(
  name: json['name'] as String,
  metaData: json['metaData'] == null
      ? null
      : TMetaData.fromJson(json['metaData'] as Map<String, dynamic>),
  description: json['description'] as String?,
  setup: (json['setup'] as List<dynamic>?)?.map((e) => e as String).toList(),
  rules: (json['rules'] as List<dynamic>?)?.map((e) => e as String).toList(),
  commands: (json['commands'] as List<dynamic>?)
      ?.map((e) => ToolCommand.fromJson(e as Map<String, dynamic>))
      .toList(),
  examples: (json['examples'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  notes: (json['notes'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$ToolToJson(Tool instance) => <String, dynamic>{
  'name': instance.name,
  'metaData': ?instance.metaData?.toJson(),
  'description': ?instance.description,
  'setup': ?instance.setup,
  'rules': ?instance.rules,
  'commands': ?instance.commands?.map((e) => e.toJson()).toList(),
  'examples': ?instance.examples,
  'notes': ?instance.notes,
};
