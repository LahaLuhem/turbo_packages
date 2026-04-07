// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'non_goals.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NonGoals _$NonGoalsFromJson(Map<String, dynamic> json) => NonGoals(
  name: json['name'] as String,
  items: (json['items'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$NonGoalsToJson(NonGoals instance) => <String, dynamic>{
  'name': instance.name,
  'items': instance.items,
};
