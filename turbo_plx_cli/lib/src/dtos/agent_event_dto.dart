import 'package:json_annotation/json_annotation.dart';

import 'package:turbo_plx_cli/src/enums/agent_event_stream.dart';

part 'agent_event_dto.g.dart';

/// Event emitted by the agent event bus for stdout JSON serialization.
@JsonSerializable(
  includeIfNull: true,
  explicitToJson: true,
  fieldRename: FieldRename.snake,
)
class AgentEventDto {
  const AgentEventDto({
    required this.runId,
    required this.stream,
    required this.data,
    this.sessionId,
    this.seq,
    this.ts,
  });

  /// Unique identifier for the agent run.
  final String runId;

  /// Event stream type: lifecycle, assistant, or error.
  final AgentEventStream stream;

  /// Payload data (e.g. text, phase, error message).
  final Map<String, dynamic> data;

  /// Optional session ID when resuming or continuing a session.
  final String? sessionId;

  /// Optional sequence number for ordering.
  final int? seq;

  /// Optional timestamp (milliseconds since epoch).
  final int? ts;

  static const fromJsonFactory = _$AgentEventDtoFromJson;
  factory AgentEventDto.fromJson(Map<String, dynamic> json) =>
      _$AgentEventDtoFromJson(json);
  static const toJsonFactory = _$AgentEventDtoToJson;
  Map<String, dynamic> toJson() => _$AgentEventDtoToJson(this);
}
