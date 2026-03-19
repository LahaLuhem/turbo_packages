// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DraftDto _$DraftDtoFromJson(Map<String, dynamic> json) => DraftDto(
  title: json['title'] as String?,
  content: json['content'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$DraftDtoToJson(DraftDto instance) => <String, dynamic>{
  'title': instance.title,
  'content': instance.content,
  'metadata': instance.metadata,
};
