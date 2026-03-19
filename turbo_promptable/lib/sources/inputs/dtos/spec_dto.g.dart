// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spec_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpecDto _$SpecDtoFromJson(Map<String, dynamic> json) => SpecDto(
  title: json['title'] as String?,
  content: json['content'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$SpecDtoToJson(SpecDto instance) => <String, dynamic>{
  'title': instance.title,
  'content': instance.content,
  'metadata': instance.metadata,
};
