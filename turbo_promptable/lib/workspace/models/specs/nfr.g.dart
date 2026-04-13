// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nfr.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TNFR _$TNFRFromJson(Map<String, dynamic> json) => TNFR(
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

Map<String, dynamic> _$TNFRToJson(TNFR instance) => <String, dynamic>{
  'name': instance.name,
  'abilityIds': ?instance.abilityIds,
  'journeyIds': ?instance.journeyIds,
  'scenarioIds': ?instance.scenarioIds,
};
