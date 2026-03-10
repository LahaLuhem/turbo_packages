// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_run_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgentRunRequestDto _$AgentRunRequestDtoFromJson(Map<String, dynamic> json) =>
    AgentRunRequestDto(
      prompt: json['prompt'] as String,
      args: (json['args'] as List<dynamic>).map((e) => e as String).toList(),
      cwd: json['cwd'] as String,
      runId: json['run_id'] as String?,
      sessionId: json['session_id'] as String?,
      env: (json['env'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$AgentRunRequestDtoToJson(AgentRunRequestDto instance) =>
    <String, dynamic>{
      'prompt': instance.prompt,
      'args': instance.args,
      'cwd': instance.cwd,
      'run_id': instance.runId,
      'session_id': instance.sessionId,
      'env': instance.env,
    };
