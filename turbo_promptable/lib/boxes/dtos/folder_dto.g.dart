// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FolderDto _$FolderDtoFromJson(Map<String, dynamic> json) => FolderDto(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  emoji: json['emoji'] as String? ?? '📁',
  path: json['path'] as String,
  isActive: json['isActive'] as bool,
  createdAt: const TimestampOrDateTimeConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampOrDateTimeConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$FolderDtoToJson(FolderDto instance) => <String, dynamic>{
  'userId': instance.userId,
  'name': instance.name,
  'emoji': instance.emoji,
  'path': instance.path,
  'isActive': instance.isActive,
  'createdAt': const TimestampOrDateTimeConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampOrDateTimeConverter().toJson(instance.updatedAt),
};

UpdateFolderDtoRequest _$UpdateFolderDtoRequestFromJson(
  Map<String, dynamic> json,
) => UpdateFolderDtoRequest(
  name: json['name'] as String?,
  emoji: json['emoji'] as String?,
  path: json['path'] as String?,
  isActive: json['isActive'] as bool?,
);

Map<String, dynamic> _$UpdateFolderDtoRequestToJson(
  UpdateFolderDtoRequest instance,
) => <String, dynamic>{
  'name': ?instance.name,
  'emoji': ?instance.emoji,
  'path': ?instance.path,
  'isActive': ?instance.isActive,
  'updatedAt': ?const TimestampOrDateTimeConverter().toJson(instance.updatedAt),
};
