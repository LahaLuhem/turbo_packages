// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'end_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EndGoal _$EndGoalFromJson(Map<String, dynamic> json) => EndGoal(
  json['value'] as String,
  acceptanceCriteria: json['acceptanceCriteria'] == null
      ? null
      : AcceptanceCriteria.fromJson(
          json['acceptanceCriteria'] as Map<String, dynamic>,
        ),
  constraints: json['constraints'] == null
      ? null
      : Constraints.fromJson(json['constraints'] as Map<String, dynamic>),
  metaData: json['metaData'] == null
      ? null
      : TMetaData.fromJson(json['metaData'] as Map<String, dynamic>),
);

Map<String, dynamic> _$EndGoalToJson(EndGoal instance) => <String, dynamic>{
  'value': ?instance.value,
  'metaData': ?instance.metaData?.toJson(),
  'acceptanceCriteria': ?instance.acceptanceCriteria?.toJson(),
  'constraints': ?instance.constraints?.toJson(),
};
