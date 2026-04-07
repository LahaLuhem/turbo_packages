// GENERATED CODE - DO NOT MODIFY BY HAND

part of 't_meta_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TMetaData _$TMetaDataFromJson(Map<String, dynamic> json) => TMetaData(
  description: json['description'] as String?,
  name: json['name'] as String?,
  aliases: (json['aliases'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  emoji: json['emoji'] as String?,
  tags: (json['tags'] as List<dynamic>?)
      ?.map((e) => TTag.fromJson(e as Map<String, dynamic>))
      .toList(),
  values: TMetaData._valuesFromJson(json['values'] as Map<String, dynamic>?),
);

Map<String, dynamic> _$TMetaDataToJson(TMetaData instance) => <String, dynamic>{
  'aliases': ?instance.aliases,
  'tags': ?instance.tags?.map((e) => e.toJson()).toList(),
  'values': ?TMetaData._valuesToJson(instance.values),
  'description': ?instance.description,
  'emoji': ?instance.emoji,
  'name': ?instance.name,
};
