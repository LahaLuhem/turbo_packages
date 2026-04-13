// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prototype.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Prototype _$PrototypeFromJson(Map<String, dynamic> json) => Prototype(
  name: json['name'] as String,
  featureIds: (json['featureIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  moduleIds: (json['moduleIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  abilityIds: (json['abilityIds'] as List<dynamic>?)
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
  mockupIds: (json['mockupIds'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$PrototypeToJson(Prototype instance) => <String, dynamic>{
  'name': instance.name,
  'featureIds': ?instance.featureIds,
  'moduleIds': ?instance.moduleIds,
  'abilityIds': ?instance.abilityIds,
  'journeyIds': ?instance.journeyIds,
  'scenarioIds': ?instance.scenarioIds,
  'issueIds': ?instance.issueIds,
  'prdIds': ?instance.prdIds,
  'mockupIds': ?instance.mockupIds,
};
