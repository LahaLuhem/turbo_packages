// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persona.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Persona _$PersonaFromJson(Map<String, dynamic> json) => Persona(
  name: json['name'] as String,
  expertise: json['expertise'] as String,
  metaData: json['metaData'] == null
      ? null
      : TMetaData.fromJson(json['metaData'] as Map<String, dynamic>),
  activities: (json['activities'] as List<dynamic>?)
      ?.map((e) => Activity.fromJson(e as Map<String, dynamic>))
      .toList(),
  checklists: (json['checklists'] as List<dynamic>?)
      ?.map((e) => Checklist.fromJson(e as Map<String, dynamic>))
      .toList(),
  instructions: (json['instructions'] as List<dynamic>?)
      ?.map((e) => Instruction.fromJson(e as Map<String, dynamic>))
      .toList(),
  templates: (json['templates'] as List<dynamic>?)
      ?.map((e) => Template.fromJson(e as Map<String, dynamic>))
      .toList(),
  tools: (json['tools'] as List<dynamic>?)
      ?.map((e) => Tool.fromJson(e as Map<String, dynamic>))
      .toList(),
  workflows: (json['workflows'] as List<dynamic>?)
      ?.map((e) => Workflow.fromJson(e as Map<String, dynamic>))
      .toList(),
  identity: json['identity'] as String?,
);

Map<String, dynamic> _$PersonaToJson(Persona instance) => <String, dynamic>{
  'name': instance.name,
  'metaData': ?instance.metaData?.toJson(),
  'activities': ?instance.activities?.map((e) => e.toJson()).toList(),
  'checklists': ?instance.checklists?.map((e) => e.toJson()).toList(),
  'instructions': ?instance.instructions?.map((e) => e.toJson()).toList(),
  'templates': ?instance.templates?.map((e) => e.toJson()).toList(),
  'tools': ?instance.tools?.map((e) => e.toJson()).toList(),
  'workflows': ?instance.workflows?.map((e) => e.toJson()).toList(),
  'expertise': instance.expertise,
  'identity': ?instance.identity,
};
