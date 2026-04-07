// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checklist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Checklist _$ChecklistFromJson(Map<String, dynamic> json) => Checklist(
  name: json['name'] as String,
  items: (json['items'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$ChecklistToJson(Checklist instance) => <String, dynamic>{
  'name': instance.name,
  'items': instance.items,
};
