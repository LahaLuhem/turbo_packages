// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scenario.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TScenario _$TScenarioFromJson(Map<String, dynamic> json) => TScenario(
  name: json['name'] as String,
  abilityIds: (json['abilityIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  journeyIds: (json['journeyIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$TScenarioToJson(TScenario instance) => <String, dynamic>{
  'name': instance.name,
  'abilityIds': ?instance.abilityIds,
  'journeyIds': ?instance.journeyIds,
};
