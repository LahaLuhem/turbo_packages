// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Output<SCHEMA> _$OutputFromJson<SCHEMA extends Object>(
  Map<String, dynamic> json,
) => Output<SCHEMA>(
  name: json['name'] as String,
  metaData: json['metaData'] == null
      ? null
      : TMetaData.fromJson(json['metaData'] as Map<String, dynamic>),
  successCriteria: json['successCriteria'] == null
      ? null
      : SuccessCriteria.fromJson(
          json['successCriteria'] as Map<String, dynamic>,
        ),
  constraints: json['constraints'] == null
      ? null
      : Constraints.fromJson(json['constraints'] as Map<String, dynamic>),
  nonGoals: json['nonGoals'] == null
      ? null
      : NonGoals.fromJson(json['nonGoals'] as Map<String, dynamic>),
  schema: json['schema'] as String,
);

Map<String, dynamic> _$OutputToJson<SCHEMA extends Object>(
  Output<SCHEMA> instance,
) => <String, dynamic>{
  'name': instance.name,
  'metaData': ?instance.metaData?.toJson(),
  'successCriteria': ?instance.successCriteria?.toJson(),
  'constraints': ?instance.constraints?.toJson(),
  'nonGoals': ?instance.nonGoals?.toJson(),
  'schema': instance.schema,
};
