// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Output _$OutputFromJson(Map<String, dynamic> json) => Output(
  name: json['name'] as String,
  checklists: (json['checklists'] as List<dynamic>?)
      ?.map((e) => Checklist.fromJson(e as Map<String, dynamic>))
      .toList(),
  template: json['template'] == null
      ? null
      : Template.fromJson(json['template'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OutputToJson(Output instance) => <String, dynamic>{
  'name': instance.name,
  'template': ?instance.template?.toJson(),
  'checklists': ?instance.checklists?.map((e) => e.toJson()).toList(),
};
