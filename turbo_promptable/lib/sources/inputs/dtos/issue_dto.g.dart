// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IssueDto _$IssueDtoFromJson(Map<String, dynamic> json) => IssueDto(
  title: json['title'] as String?,
  content: json['content'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$IssueDtoToJson(IssueDto instance) => <String, dynamic>{
  'title': instance.title,
  'content': instance.content,
  'metadata': instance.metadata,
};
