// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insight_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InsightDto _$InsightDtoFromJson(Map<String, dynamic> json) => InsightDto(
  title: json['title'] as String?,
  content: json['content'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$InsightDtoToJson(InsightDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'metadata': instance.metadata,
    };
