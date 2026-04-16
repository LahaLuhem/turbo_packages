// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'documentation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Documentation _$DocumentationFromJson(Map<String, dynamic> json) =>
    Documentation(
      name: json['name'] as String,
      metaData: json['metaData'] == null
          ? null
          : TMetaData.fromJson(json['metaData'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DocumentationToJson(Documentation instance) =>
    <String, dynamic>{
      'name': instance.name,
      'metaData': ?instance.metaData?.toJson(),
    };
