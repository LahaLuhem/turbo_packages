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
);

Map<String, dynamic> _$WorkflowToJson(Workflow instance) => <String, dynamic>{
  'name': instance.name,
  'metaData': ?instance.metaData?.toJson(),
  'steps': instance.steps.map((e) => e.toJson()).toList(),
  'endGoal': instance.endGoal.toJson(),
};
