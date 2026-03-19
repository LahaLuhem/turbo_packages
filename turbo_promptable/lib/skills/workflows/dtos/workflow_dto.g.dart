// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workflow_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkflowDto _$WorkflowDtoFromJson(Map<String, dynamic> json) => WorkflowDto(
  guardRails: (json['guardRails'] as List<dynamic>?)
      ?.map((e) => GuardRailDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  steps: (json['steps'] as List<dynamic>)
      .map(
        (e) => WorkflowStep<dynamic, dynamic>.fromJson(
          e as Map<String, dynamic>,
          (value) => value,
          (value) => value,
        ),
      )
      .toList(),
);

Map<String, dynamic> _$WorkflowDtoToJson(WorkflowDto instance) =>
    <String, dynamic>{
      'guardRails': instance.guardRails?.map((e) => e.toJson()).toList(),
      'steps': instance.steps.map((e) => e.toJson()).toList(),
    };
