// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workflow_step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkflowStep<INPUT, OUTPUT> _$WorkflowStepFromJson<INPUT, OUTPUT>(
  Map<String, dynamic> json,
  INPUT Function(Object? json) fromJsonINPUT,
  OUTPUT Function(Object? json) fromJsonOUTPUT,
) => WorkflowStep<INPUT, OUTPUT>(
  workflowStepType: $enumDecode(
    _$WorkflowStepTypeEnumMap,
    json['workflowStepType'],
  ),
  guardRails: (json['guardRails'] as List<dynamic>?)
      ?.map((e) => GuardRailDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  input: _$nullableGenericFromJson(json['input'], fromJsonINPUT),
  output: _$nullableGenericFromJson(json['output'], fromJsonOUTPUT),
);

Map<String, dynamic> _$WorkflowStepToJson<INPUT, OUTPUT>(
  WorkflowStep<INPUT, OUTPUT> instance,
  Object? Function(INPUT value) toJsonINPUT,
  Object? Function(OUTPUT value) toJsonOUTPUT,
) => <String, dynamic>{
  'input': _$nullableGenericToJson(instance.input, toJsonINPUT),
  'guardRails': instance.guardRails?.map((e) => e.toJson()).toList(),
  'output': _$nullableGenericToJson(instance.output, toJsonOUTPUT),
  'workflowStepType': _$WorkflowStepTypeEnumMap[instance.workflowStepType]!,
};

const _$WorkflowStepTypeEnumMap = {
  WorkflowStepType.assess: 'assess',
  WorkflowStepType.research: 'research',
  WorkflowStepType.enrich: 'enrich',
  WorkflowStepType.align: 'align',
  WorkflowStepType.refine: 'refine',
  WorkflowStepType.plan: 'plan',
  WorkflowStepType.act: 'act',
  WorkflowStepType.review: 'review',
  WorkflowStepType.test: 'test',
  WorkflowStepType.deliver: 'deliver',
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);
