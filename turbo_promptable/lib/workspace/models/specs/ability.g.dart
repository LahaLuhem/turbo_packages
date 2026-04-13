// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ability.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ability _$AbilityFromJson(Map<String, dynamic> json) => Ability(
  name: json['name'] as String,
  featureIds: (json['featureIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  moduleIds: (json['moduleIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$AbilityToJson(Ability instance) => <String, dynamic>{
  'name': instance.name,
  'featureIds': instance.featureIds,
  'moduleIds': instance.moduleIds,
};
