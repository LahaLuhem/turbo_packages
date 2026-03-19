// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'idea_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IdeaDto _$IdeaDtoFromJson(Map<String, dynamic> json) => IdeaDto(
  title: json['title'] as String?,
  content: json['content'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$IdeaDtoToJson(IdeaDto instance) => <String, dynamic>{
  'title': instance.title,
  'content': instance.content,
  'metadata': instance.metadata,
};
