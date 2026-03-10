// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionSummaryDto _$SessionSummaryDtoFromJson(Map<String, dynamic> json) =>
    SessionSummaryDto(
      sessionId: json['session_id'] as String,
      projectDir: json['project_dir'] as String?,
      timestamp: (json['timestamp'] as num?)?.toInt(),
      cwd: json['cwd'] as String?,
    );

Map<String, dynamic> _$SessionSummaryDtoToJson(SessionSummaryDto instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'project_dir': instance.projectDir,
      'timestamp': instance.timestamp,
      'cwd': instance.cwd,
    };
