import 'package:json_annotation/json_annotation.dart';

part 'agent_run_request_dto.g.dart';

/// Request to run an agent via a backend.
@JsonSerializable(
  includeIfNull: true,
  explicitToJson: true,
  fieldRename: FieldRename.snake,
)
class AgentRunRequestDto {
  const AgentRunRequestDto({
    required this.prompt,
    required this.args,
    required this.cwd,
    this.runId,
    this.sessionId,
    this.env,
  });

  /// User prompt for the agent.
  final String prompt;

  /// CLI args passed verbatim (e.g. --output-format stream-json).
  final List<String> args;

  /// Working directory for the spawned process.
  final String cwd;

  /// Optional run ID; handler generates if omitted.
  final String? runId;

  /// Optional session ID for resume/continue.
  final String? sessionId;

  /// Optional environment overrides.
  final Map<String, String>? env;

  static const fromJsonFactory = _$AgentRunRequestDtoFromJson;
  factory AgentRunRequestDto.fromJson(Map<String, dynamic> json) =>
      _$AgentRunRequestDtoFromJson(json);
  static const toJsonFactory = _$AgentRunRequestDtoToJson;
  Map<String, dynamic> toJson() => _$AgentRunRequestDtoToJson(this);
}
