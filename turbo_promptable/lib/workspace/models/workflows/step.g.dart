// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Step _$StepFromJson(Map<String, dynamic> json) => Step(
  name: json['name'] as String,
  metaData: json['metaData'] == null
      ? null
      : TMetaData.fromJson(json['metaData'] as Map<String, dynamic>),
  input: Input.fromJson(json['input'] as Map<String, dynamic>),
  instructions: json['instructions'] as String?,
  output: Output.fromJson(json['output'] as Map<String, dynamic>),
);

Map<String, dynamic> _$StepToJson(Step instance) => <String, dynamic>{
  'name': instance.name,
  'metaData': ?instance.metaData?.toJson(),
  'input': instance.input.toJson(),
  'instructions': ?instance.instructions,
  'output': instance.output.toJson(),
};
