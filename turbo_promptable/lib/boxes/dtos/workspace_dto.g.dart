// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkspaceDto _$WorkspaceDtoFromJson(Map<String, dynamic> json) => WorkspaceDto(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  emoji: json['emoji'] as String,
  createdAt: const TimestampOrDateTimeConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampOrDateTimeConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$WorkspaceDtoToJson(
  WorkspaceDto instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'name': instance.name,
  'description': instance.description,
  'emoji': instance.emoji,
  'createdAt': const TimestampOrDateTimeConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampOrDateTimeConverter().toJson(instance.updatedAt),
};

UpdateWorkspaceDtoRequest _$UpdateWorkspaceDtoRequestFromJson(
  Map<String, dynamic> json,
) => UpdateWorkspaceDtoRequest(
  name: json['name'] as String?,
  description: json['description'] as String?,
  emoji: json['emoji'] as String?,
);

Map<String, dynamic> _$UpdateWorkspaceDtoRequestToJson(
  UpdateWorkspaceDtoRequest instance,
) => <String, dynamic>{
  'name': ?instance.name,
  'description': ?instance.description,
  'emoji': ?instance.emoji,
  'updatedAt': ?const TimestampOrDateTimeConverter().toJson(instance.updatedAt),
};
