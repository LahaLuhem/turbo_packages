// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgentEventDto _$AgentEventDtoFromJson(Map<String, dynamic> json) =>
    AgentEventDto(
      runId: json['run_id'] as String,
      stream: $enumDecode(_$AgentEventStreamEnumMap, json['stream']),
      data: json['data'] as Map<String, dynamic>,
      sessionId: json['session_id'] as String?,
      seq: (json['seq'] as num?)?.toInt(),
      ts: (json['ts'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AgentEventDtoToJson(AgentEventDto instance) =>
    <String, dynamic>{
      'run_id': instance.runId,
      'stream': _$AgentEventStreamEnumMap[instance.stream]!,
      'data': instance.data,
      'session_id': instance.sessionId,
      'seq': instance.seq,
      'ts': instance.ts,
    };

const _$AgentEventStreamEnumMap = {
  AgentEventStream.lifecycle: 'lifecycle',
  AgentEventStream.assistant: 'assistant',
  AgentEventStream.error: 'error',
};
