// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stakeholder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Stakeholder _$StakeholderFromJson(Map<String, dynamic> json) => Stakeholder(
  name: json['name'] as String,
  metaData: json['metaData'] == null
      ? null
      : TMetaData.fromJson(json['metaData'] as Map<String, dynamic>),
);

Map<String, dynamic> _$StakeholderToJson(Stakeholder instance) =>
    <String, dynamic>{
      'name': instance.name,
      'metaData': ?instance.metaData?.toJson(),
    };
