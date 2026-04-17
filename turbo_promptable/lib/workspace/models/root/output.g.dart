// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Output _$OutputFromJson(Map<String, dynamic> json) => Output(
  name: json['name'] as String,
  metaData: json['metaData'] == null
      ? null
      : TMetaData.fromJson(json['metaData'] as Map<String, dynamic>),
  criteria: json['criteria'] == null
      ? null
      : Checklist.fromJson(json['criteria'] as Map<String, dynamic>),
  constraints: json['constraints'] == null
      ? null
      : Checklist.fromJson(json['constraints'] as Map<String, dynamic>),
  schema: json['schema'] as String,
);

Map<String, dynamic> _$OutputToJson(Output instance) => <String, dynamic>{
  'name': instance.name,
  'metaData': ?instance.metaData?.toJson(),
  'criteria': ?instance.criteria?.toJson(),
  'constraints': ?instance.constraints?.toJson(),
  'schema': instance.schema,
};
