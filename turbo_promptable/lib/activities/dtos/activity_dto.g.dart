// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityDto<INPUT, OUTPUT>
_$ActivityDtoFromJson<INPUT extends HasToJson, OUTPUT extends HasToJson>(
  Map<String, dynamic> json,
  INPUT Function(Object? json) fromJsonINPUT,
  OUTPUT Function(Object? json) fromJsonOUTPUT,
) => ActivityDto<INPUT, OUTPUT>(
  output: _$nullableGenericFromJson(json['output'], fromJsonOUTPUT),
  workflow: WorkflowDto.fromJson(json['workflow'] as Map<String, dynamic>),
  input: _$nullableGenericFromJson(json['input'], fromJsonINPUT),
  instructions: (json['instructions'] as List<dynamic>?)
      ?.map((e) => InstructionDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  agents: (json['agents'] as List<dynamic>?)
      ?.map((e) => AgentDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic>
_$ActivityDtoToJson<INPUT extends HasToJson, OUTPUT extends HasToJson>(
  ActivityDto<INPUT, OUTPUT> instance,
  Object? Function(INPUT value) toJsonINPUT,
  Object? Function(OUTPUT value) toJsonOUTPUT,
) => <String, dynamic>{
  'input': _$nullableGenericToJson(instance.input, toJsonINPUT),
  'instructions': instance.instructions?.map((e) => e.toJson()).toList(),
  'agents': instance.agents?.map((e) => e.toJson()).toList(),
  'output': _$nullableGenericToJson(instance.output, toJsonOUTPUT),
  'workflow': instance.workflow.toJson(),
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);
