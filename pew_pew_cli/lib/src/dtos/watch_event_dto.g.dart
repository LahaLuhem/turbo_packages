// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WatchEventDto _$WatchEventDtoFromJson(Map<String, dynamic> json) =>
    WatchEventDto(
      event: $enumDecode(_$WatchEventTypeEnumMap, json['event']),
      path: json['path'] as String,
      content: json['content'] as String?,
      id: json['id'] as String?,
      lastModified: (json['lastModified'] as num?)?.toInt(),
      files: (json['files'] as List<dynamic>?)
          ?.map((e) => FileEntryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WatchEventDtoToJson(WatchEventDto instance) =>
    <String, dynamic>{
      'event': _$WatchEventTypeEnumMap[instance.event]!,
      'path': instance.path,
      'content': instance.content,
      'id': instance.id,
      'lastModified': instance.lastModified,
      'files': instance.files?.map((e) => e.toJson()).toList(),
    };

const _$WatchEventTypeEnumMap = {
  WatchEventType.create: 'create',
  WatchEventType.modify: 'modify',
  WatchEventType.delete: 'delete',
  WatchEventType.error: 'error',
  WatchEventType.get: 'get',
  WatchEventType.list: 'list',
};
