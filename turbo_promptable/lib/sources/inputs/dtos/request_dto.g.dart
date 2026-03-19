// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestDto _$RequestDtoFromJson(Map<String, dynamic> json) => RequestDto(
  title: json['title'] as String?,
  content: json['content'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$RequestDtoToJson(RequestDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'metadata': instance.metadata,
    };
