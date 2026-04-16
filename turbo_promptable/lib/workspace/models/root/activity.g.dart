// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
  name: json['name'] as String,
  input: Input.fromJson(json['input'] as Map<String, dynamic>),
  output: Output<Object>.fromJson(json['output'] as Map<String, dynamic>),
  workflow: Workflow.fromJson(json['workflow'] as Map<String, dynamic>),
  metaData: json['metaData'] == null
      ? null
      : TMetaData.fromJson(json['metaData'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
  'name': instance.name,
  'metaData': ?instance.metaData?.toJson(),
  'input': instance.input.toJson(),
  'workflow': instance.workflow.toJson(),
  'output': instance.output.toJson(),
};
