// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Output _$OutputFromJson(Map<String, dynamic> json) => Output(
  name: json['name'] as String,
  fields: (json['fields'] as List<dynamic>)
      .map((e) => PromptField.fromJson(e as Map<String, dynamic>))
      .toList(),
  checklists: (json['checklists'] as List<dynamic>?)
      ?.map((e) => Checklist.fromJson(e as Map<String, dynamic>))
      .toList(),
  template: json['template'] == null
      ? null
      : Template.fromJson(json['template'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OutputToJson(Output instance) => <String, dynamic>{
  'name': instance.name,
  'fields': instance.fields.map((e) => e.toJson()).toList(),
  'template': ?instance.template?.toJson(),
  'checklists': ?instance.checklists?.map((e) => e.toJson()).toList(),
};
