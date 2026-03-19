// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'type_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TypeDto _$TypeDtoFromJson(Map<String, dynamic> json) => TypeDto(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  emoji: json['emoji'] as String? ?? '📋',
  conditions: (json['conditions'] as List<dynamic>)
      .map((e) => TypeConditionDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: const TimestampOrDateTimeConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampOrDateTimeConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$TypeDtoToJson(TypeDto instance) => <String, dynamic>{
  'userId': instance.userId,
  'name': instance.name,
  'description': instance.description,
  'emoji': instance.emoji,
  'conditions': instance.conditions.map((e) => e.toJson()).toList(),
  'createdAt': const TimestampOrDateTimeConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampOrDateTimeConverter().toJson(instance.updatedAt),
};

UpdateTypeDtoRequest _$UpdateTypeDtoRequestFromJson(
  Map<String, dynamic> json,
) => UpdateTypeDtoRequest(
  name: json['name'] as String?,
  description: json['description'] as String?,
  emoji: json['emoji'] as String?,
  conditions: (json['conditions'] as List<dynamic>?)
      ?.map((e) => TypeConditionDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$UpdateTypeDtoRequestToJson(
  UpdateTypeDtoRequest instance,
) => <String, dynamic>{
  'name': ?instance.name,
  'description': ?instance.description,
  'emoji': ?instance.emoji,
  'conditions': ?instance.conditions?.map((e) => e.toJson()).toList(),
  'updatedAt': ?const TimestampOrDateTimeConverter().toJson(instance.updatedAt),
};
