// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Input _$InputFromJson(Map<String, dynamic> json) => Input(
  name: json['name'] as String,
  metaData: json['metaData'] == null
      ? null
      : TMetaData.fromJson(json['metaData'] as Map<String, dynamic>),
  context: (json['context'] as List<dynamic>?)
      ?.map((e) => Context.fromJson(e as Map<String, dynamic>))
      .toList(),
  goals: (json['goals'] as List<dynamic>?)
      ?.map((e) => Goal.fromJson(e as Map<String, dynamic>))
      .toList(),
  issues: (json['issues'] as List<dynamic>?)
      ?.map((e) => Issue.fromJson(e as Map<String, dynamic>))
      .toList(),
  specs: (json['specs'] as List<dynamic>?)
      ?.map((e) => Spec.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$InputToJson(Input instance) => <String, dynamic>{
  'name': instance.name,
  'metaData': ?instance.metaData?.toJson(),
  'context': ?instance.context?.map((e) => e.toJson()).toList(),
  'goals': ?instance.goals?.map((e) => e.toJson()).toList(),
  'issues': ?instance.issues?.map((e) => e.toJson()).toList(),
  'specs': ?instance.specs?.map((e) => e.toJson()).toList(),
};
