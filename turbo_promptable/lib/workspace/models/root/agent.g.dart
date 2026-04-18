// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Agent<IDENTITY> _$AgentFromJson<IDENTITY extends Role>(
  Map<String, dynamic> json,
  IDENTITY Function(Object? json) fromJsonIDENTITY,
) => Agent<IDENTITY>(
  cliTool: $enumDecode(_$TCliToolEnumMap, json['cliTool']),
  tools: json['tools'] as String?,
  yolo: json['yolo'] as bool? ?? true,
  model: json['model'] as String?,
  headless: json['headless'] as bool? ?? true,
  mcpsConfigSource:
      $enumDecodeNullable(_$ConfigSourceEnumMap, json['mcpsConfigSource']) ??
      ConfigSource.none,
  identity: fromJsonIDENTITY(json['identity']),
);

Map<String, dynamic> _$AgentToJson<IDENTITY extends Role>(
  Agent<IDENTITY> instance,
  Object? Function(IDENTITY value) toJsonIDENTITY,
) => <String, dynamic>{
  'tools': ?instance.tools,
  'yolo': instance.yolo,
  'model': ?instance.model,
  'headless': instance.headless,
  'mcpsConfigSource': _$ConfigSourceEnumMap[instance.mcpsConfigSource]!,
  'cliTool': _$TCliToolEnumMap[instance.cliTool]!,
  'identity': toJsonIDENTITY(instance.identity),
};

const _$TCliToolEnumMap = {
  TCliTool.claude: 'claude',
  TCliTool.codex: 'codex',
  TCliTool.cursor: 'cursor',
};

const _$ConfigSourceEnumMap = {
  ConfigSource.local: 'local',
  ConfigSource.global: 'global',
  ConfigSource.none: 'none',
};
