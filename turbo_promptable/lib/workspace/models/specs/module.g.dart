// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Module _$ModuleFromJson(Map<String, dynamic> json) => Module(
  name: json['name'] as String,
  projectIds: (json['projectIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ModuleToJson(Module instance) => <String, dynamic>{
  'name': instance.name,
  'projectIds': instance.projectIds,
};
