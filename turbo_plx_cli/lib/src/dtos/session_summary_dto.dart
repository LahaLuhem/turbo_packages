import 'package:json_annotation/json_annotation.dart';

part 'session_summary_dto.g.dart';

/// Summary metadata for a Claude Code session (from first line of JSONL).
@JsonSerializable(
  includeIfNull: true,
  explicitToJson: true,
  fieldRename: FieldRename.snake,
)
class SessionSummaryDto {
  const SessionSummaryDto({
    required this.sessionId,
    this.projectDir,
    this.timestamp,
    this.cwd,
  });

  /// Session UUID.
  final String sessionId;

  /// Project directory name (e.g. -Users-codaveto-Repos-pew-pew-plx).
  final String? projectDir;

  /// Timestamp from session file.
  final int? timestamp;

  /// Working directory when session was created.
  final String? cwd;

  static const fromJsonFactory = _$SessionSummaryDtoFromJson;
  factory SessionSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$SessionSummaryDtoFromJson(json);
  static const toJsonFactory = _$SessionSummaryDtoToJson;
  Map<String, dynamic> toJson() => _$SessionSummaryDtoToJson(this);
}
