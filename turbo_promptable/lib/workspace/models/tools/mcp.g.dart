// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mcp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Mcp _$McpFromJson(Map<String, dynamic> json) => Mcp(
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

Map<String, dynamic> _$McpToJson(Mcp instance) => <String, dynamic>{
  'name': instance.name,
  'metaData': ?instance.metaData?.toJson(),
  'description': ?instance.description,
  'setup': ?instance.setup,
  'rules': ?instance.rules,
  'commands': ?instance.commands?.map((e) => e.toJson()).toList(),
  'examples': ?instance.examples,
  'notes': ?instance.notes,
};
