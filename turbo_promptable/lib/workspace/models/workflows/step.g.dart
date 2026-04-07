// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Step _$StepFromJson(Map<String, dynamic> json) => Step(
  name: json['name'] as String,
  input: Input.fromJson(json['input'] as Map<String, dynamic>),
  instructions: (json['instructions'] as List<dynamic>?)
      ?.map((e) => Instruction.fromJson(e as Map<String, dynamic>))
      .toList(),
  output: Output.fromJson(json['output'] as Map<String, dynamic>),
);

Map<String, dynamic> _$StepToJson(Step instance) => <String, dynamic>{
  'name': instance.name,
  'input': instance.input.toJson(),
  'instructions': ?instance.instructions?.map((e) => e.toJson()).toList(),
  'output': instance.output.toJson(),
};
