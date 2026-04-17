// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Template _$TemplateFromJson(Map<String, dynamic> json) => Template(
  json['name'] as String,
  value: json['value'] as String?,
  metaData: json['metaData'] == null
      ? null
      : TMetaData.fromJson(json['metaData'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TemplateToJson(Template instance) => <String, dynamic>{
  'name': instance.name,
  'value': ?instance.value,
  'metaData': ?instance.metaData?.toJson(),
};
