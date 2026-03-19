// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RelationshipDto<SOURCE_TYPE, TARGET_TYPE>
_$RelationshipDtoFromJson<SOURCE_TYPE, TARGET_TYPE>(
  Map<String, dynamic> json,
  SOURCE_TYPE Function(Object? json) fromJsonSOURCE_TYPE,
  TARGET_TYPE Function(Object? json) fromJsonTARGET_TYPE,
) => RelationshipDto<SOURCE_TYPE, TARGET_TYPE>(
  id: json['id'] as String,
  userId: json['userId'] as String,
  sourceId: json['sourceId'] as String,
  sourceType: fromJsonSOURCE_TYPE(json['sourceType']),
  targetId: json['targetId'] as String,
  targetType: fromJsonTARGET_TYPE(json['targetType']),
  type: _relationshipTypeFromJson(json['type'] as String),
  bidirectional: json['bidirectional'] as bool,
  createdAt: const TimestampOrDateTimeConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampOrDateTimeConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$RelationshipDtoToJson<SOURCE_TYPE, TARGET_TYPE>(
  RelationshipDto<SOURCE_TYPE, TARGET_TYPE> instance,
  Object? Function(SOURCE_TYPE value) toJsonSOURCE_TYPE,
  Object? Function(TARGET_TYPE value) toJsonTARGET_TYPE,
) => <String, dynamic>{
  'userId': instance.userId,
  'sourceId': instance.sourceId,
  'sourceType': toJsonSOURCE_TYPE(instance.sourceType),
  'targetId': instance.targetId,
  'targetType': toJsonTARGET_TYPE(instance.targetType),
  'type': _relationshipTypeToJson(instance.type),
  'bidirectional': instance.bidirectional,
  'createdAt': const TimestampOrDateTimeConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampOrDateTimeConverter().toJson(instance.updatedAt),
};

UpdateRelationshipDtoRequest _$UpdateRelationshipDtoRequestFromJson(
  Map<String, dynamic> json,
) => UpdateRelationshipDtoRequest(
  type: _nullableRelationshipTypeFromJson(json['type'] as String?),
  bidirectional: json['bidirectional'] as bool?,
);

Map<String, dynamic> _$UpdateRelationshipDtoRequestToJson(
  UpdateRelationshipDtoRequest instance,
) => <String, dynamic>{
  'type': ?_nullableRelationshipTypeToJson(instance.type),
  'bidirectional': ?instance.bidirectional,
  'updatedAt': ?const TimestampOrDateTimeConverter().toJson(instance.updatedAt),
};
