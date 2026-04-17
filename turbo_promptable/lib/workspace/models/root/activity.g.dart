// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
  name: json['name'] as String,
  workflow: Workflow.fromJson(json['workflow'] as Map<String, dynamic>),
  metaData: json['metaData'] == null
      ? null
      : TMetaData.fromJson(json['metaData'] as Map<String, dynamic>),
  role: json['role'] == null
      ? null
      : Role.fromJson(json['role'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
  'name': instance.name,
  'metaData': ?instance.metaData?.toJson(),
  'role': ?instance.role?.toJson(),
  'workflow': instance.workflow.toJson(),
};
