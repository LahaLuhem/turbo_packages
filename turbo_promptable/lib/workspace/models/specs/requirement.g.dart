// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requirement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Requirement _$RequirementFromJson(Map<String, dynamic> json) => Requirement(
  name: json['name'] as String,
  abilityIds: (json['abilityIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  journeyIds: (json['journeyIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  scenarioIds: (json['scenarioIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$RequirementToJson(Requirement instance) =>
    <String, dynamic>{
      'name': instance.name,
      'abilityIds': ?instance.abilityIds,
      'journeyIds': ?instance.journeyIds,
      'scenarioIds': ?instance.scenarioIds,
    };
