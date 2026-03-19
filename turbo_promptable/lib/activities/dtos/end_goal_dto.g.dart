// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'end_goal_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EndGoalDto _$EndGoalDtoFromJson(Map<String, dynamic> json) => EndGoalDto(
  acceptanceCriteria: (json['acceptanceCriteria'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  constraints: (json['constraints'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$EndGoalDtoToJson(EndGoalDto instance) =>
    <String, dynamic>{
      'acceptanceCriteria': instance.acceptanceCriteria,
      'constraints': instance.constraints,
    };
