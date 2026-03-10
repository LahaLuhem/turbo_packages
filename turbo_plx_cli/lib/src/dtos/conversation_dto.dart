import 'package:json_annotation/json_annotation.dart';

part 'conversation_dto.g.dart';

/// Unified conversation (role + content) from a session transcript.
@JsonSerializable(
  includeIfNull: true,
  explicitToJson: true,
  fieldRename: FieldRename.snake,
)
class ConversationDto {
  const ConversationDto({
    required this.sessionId,
    required this.messages,
  });

  /// Session UUID.
  final String sessionId;

  /// Ordered messages (role + content).
  final List<ConversationMessageDto> messages;

  static const fromJsonFactory = _$ConversationDtoFromJson;
  factory ConversationDto.fromJson(Map<String, dynamic> json) =>
      _$ConversationDtoFromJson(json);
  static const toJsonFactory = _$ConversationDtoToJson;
  Map<String, dynamic> toJson() => _$ConversationDtoToJson(this);
}

/// Single message in a conversation.
@JsonSerializable(
  includeIfNull: true,
  explicitToJson: true,
  fieldRename: FieldRename.snake,
)
class ConversationMessageDto {
  const ConversationMessageDto({
    required this.role,
    required this.content,
  });

  /// Message role: user, assistant, etc.
  final String role;

  /// Plain text content.
  final String content;

  static const fromJsonFactory = _$ConversationMessageDtoFromJson;
  factory ConversationMessageDto.fromJson(Map<String, dynamic> json) =>
      _$ConversationMessageDtoFromJson(json);
  static const toJsonFactory = _$ConversationMessageDtoToJson;
  Map<String, dynamic> toJson() => _$ConversationMessageDtoToJson(this);
}
