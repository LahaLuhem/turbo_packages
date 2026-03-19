// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectDto _$ProjectDtoFromJson(Map<String, dynamic> json) => ProjectDto(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  emoji: json['emoji'] as String,
  createdAt: const TimestampOrDateTimeConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampOrDateTimeConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$ProjectDtoToJson(
  ProjectDto instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'name': instance.name,
  'description': instance.description,
  'emoji': instance.emoji,
  'createdAt': const TimestampOrDateTimeConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampOrDateTimeConverter().toJson(instance.updatedAt),
};

UpdateProjectDtoRequest _$UpdateProjectDtoRequestFromJson(
  Map<String, dynamic> json,
) => UpdateProjectDtoRequest(
  name: json['name'] as String?,
  description: json['description'] as String?,
  emoji: json['emoji'] as String?,
);

Map<String, dynamic> _$UpdateProjectDtoRequestToJson(
  UpdateProjectDtoRequest instance,
) => <String, dynamic>{
  'name': ?instance.name,
  'description': ?instance.description,
  'emoji': ?instance.emoji,
  'updatedAt': ?const TimestampOrDateTimeConverter().toJson(instance.updatedAt),
};
