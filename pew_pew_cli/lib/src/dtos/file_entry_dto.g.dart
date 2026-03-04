// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_entry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileEntryDto _$FileEntryDtoFromJson(Map<String, dynamic> json) => FileEntryDto(
  path: json['path'] as String,
  content: json['content'] as String?,
  lastModified: (json['lastModified'] as num?)?.toInt(),
);

Map<String, dynamic> _$FileEntryDtoToJson(FileEntryDto instance) =>
    <String, dynamic>{
      'path': instance.path,
      'content': instance.content,
      'lastModified': instance.lastModified,
    };
