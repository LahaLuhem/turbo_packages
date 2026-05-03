// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Agent<IDENTITY> _$AgentFromJson<IDENTITY extends Role>(
  Map<String, dynamic> json,
  IDENTITY Function(Object? json) fromJsonIDENTITY,
) => Agent<IDENTITY>(
  json['name'] as String,
  id: json['id'] as String,
  allowedTools: json['allowedTools'] as String?,
  yolo: json['yolo'] as bool? ?? true,
  model: json['model'] as String?,
  headless: json['headless'] as bool? ?? true,
  identity: fromJsonIDENTITY(json['identity']),
  workflow: json['workflow'] == null
      ? null
      : Workflow.fromJson(json['workflow'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AgentToJson<IDENTITY extends Role>(
  Agent<IDENTITY> instance,
  Object? Function(IDENTITY value) toJsonIDENTITY,
) => <String, dynamic>{
  'name': instance.name,
  'id': instance.id,
  'allowedTools': ?instance.allowedTools,
  'yolo': instance.yolo,
  'model': ?instance.model,
  'headless': instance.headless,
  'identity': toJsonIDENTITY(instance.identity),
  'workflow': ?instance.workflow?.toJson(),
};
