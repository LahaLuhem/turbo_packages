// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mockup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Mockup _$MockupFromJson(Map<String, dynamic> json) => Mockup(
  name: json['name'] as String,
  metaData: json['metaData'] == null
      ? null
      : TMetaData.fromJson(json['metaData'] as Map<String, dynamic>),
  abilityIds: (json['abilityIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  featureIds: (json['featureIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  moduleIds: (json['moduleIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  journeyIds: (json['journeyIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  scenarioIds: (json['scenarioIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  issueIds: (json['issueIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  prdIds: (json['prdIds'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$MockupToJson(Mockup instance) => <String, dynamic>{
  'name': instance.name,
  'metaData': ?instance.metaData?.toJson(),
  'abilityIds': ?instance.abilityIds,
  'featureIds': ?instance.featureIds,
  'moduleIds': ?instance.moduleIds,
  'journeyIds': ?instance.journeyIds,
  'scenarioIds': ?instance.scenarioIds,
  'issueIds': ?instance.issueIds,
  'prdIds': ?instance.prdIds,
};
