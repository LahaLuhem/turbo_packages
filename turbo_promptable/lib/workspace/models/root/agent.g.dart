// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Agent _$AgentFromJson(Map<String, dynamic> json) => Agent(
  expertise: json['expertise'] as String,
  identity: json['identity'] as String,
  name: json['name'] as String,
  activities: (json['activities'] as List<dynamic>?)
      ?.map((e) => Activity.fromJson(e as Map<String, dynamic>))
      .toList(),
  checklists: (json['checklists'] as List<dynamic>?)
      ?.map((e) => Checklist.fromJson(e as Map<String, dynamic>))
      .toList(),
  instructions: (json['instructions'] as List<dynamic>?)
      ?.map((e) => Instruction.fromJson(e as Map<String, dynamic>))
      .toList(),
  metaData: json['metaData'] == null
      ? null
      : TMetaData.fromJson(json['metaData'] as Map<String, dynamic>),
  templates: (json['templates'] as List<dynamic>?)
      ?.map((e) => Template.fromJson(e as Map<String, dynamic>))
      .toList(),
  tools: (json['tools'] as List<dynamic>?)
      ?.map((e) => Tool.fromJson(e as Map<String, dynamic>))
      .toList(),
  workflows: (json['workflows'] as List<dynamic>?)
      ?.map((e) => Workflow.fromJson(e as Map<String, dynamic>))
      .toList(),
  cliTool: $enumDecodeNullable(_$TCliToolEnumMap, json['cliTool']),
  command: json['command'] as String?,
  promptDelivery:
      $enumDecodeNullable(_$TPromptDeliveryEnumMap, json['promptDelivery']) ??
      TPromptDelivery.system,
);

Map<String, dynamic> _$AgentToJson(Agent instance) => <String, dynamic>{
  'name': instance.name,
  'metaData': ?instance.metaData?.toJson(),
  'command': ?instance.command,
  'cliTool': ?_$TCliToolEnumMap[instance.cliTool],
  'promptDelivery': _$TPromptDeliveryEnumMap[instance.promptDelivery]!,
  'activities': ?instance.activities?.map((e) => e.toJson()).toList(),
  'checklists': ?instance.checklists?.map((e) => e.toJson()).toList(),
  'instructions': ?instance.instructions?.map((e) => e.toJson()).toList(),
  'templates': ?instance.templates?.map((e) => e.toJson()).toList(),
  'tools': ?instance.tools?.map((e) => e.toJson()).toList(),
  'workflows': ?instance.workflows?.map((e) => e.toJson()).toList(),
  'expertise': instance.expertise,
  'identity': instance.identity,
};

const _$TCliToolEnumMap = {
  TCliTool.claude: 'claude',
  TCliTool.codex: 'codex',
  TCliTool.cursor: 'cursor',
};

const _$TPromptDeliveryEnumMap = {
  TPromptDelivery.system: 'system',
  TPromptDelivery.file: 'file',
  TPromptDelivery.chat: 'chat',
};
