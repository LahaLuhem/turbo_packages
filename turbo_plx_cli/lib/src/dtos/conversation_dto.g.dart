// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationDto _$ConversationDtoFromJson(Map<String, dynamic> json) =>
    ConversationDto(
      sessionId: json['session_id'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map(
            (e) => ConversationMessageDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$ConversationDtoToJson(ConversationDto instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'messages': instance.messages.map((e) => e.toJson()).toList(),
    };

ConversationMessageDto _$ConversationMessageDtoFromJson(
  Map<String, dynamic> json,
) =>
    ConversationMessageDto(
      role: json['role'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$ConversationMessageDtoToJson(
  ConversationMessageDto instance,
) =>
    <String, dynamic>{
      'role': instance.role,
      'content': instance.content,
    };
