// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workflow.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Workflow _$WorkflowFromJson(Map<String, dynamic> json) => Workflow(
  name: json['name'] as String,
  metaData: json['metaData'] == null
      ? null
      : TMetaData.fromJson(json['metaData'] as Map<String, dynamic>),
  steps: (json['steps'] as List<dynamic>)
      .map((e) => Step.fromJson(e as Map<String, dynamic>))
      .toList(),
  endGoal: EndGoal.fromJson(json['endGoal'] as Map<String, dynamic>),
  instructions: (json['instructions'] as List<dynamic>?)
      ?.map((e) => Instruction.fromJson(e as Map<String, dynamic>))
      .toList(),
  tools: (json['tools'] as List<dynamic>?)
      ?.map((e) => Tool.fromJson(e as Map<String, dynamic>))
      .toList(),
  toolSets: (json['toolSets'] as List<dynamic>?)
      ?.map((e) => ToolSet.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$WorkflowToJson(Workflow instance) => <String, dynamic>{
  'name': instance.name,
  'metaData': ?instance.metaData?.toJson(),
  'steps': instance.steps.map((e) => e.toJson()).toList(),
  'endGoal': instance.endGoal.toJson(),
  'instructions': ?instance.instructions?.map((e) => e.toJson()).toList(),
  'tools': ?instance.tools?.map((e) => e.toJson()).toList(),
  'toolSets': ?instance.toolSets?.map((e) => e.toJson()).toList(),
};
