// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'output.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Output _$OutputFromJson(Map<String, dynamic> json) => Output(
  name: json['name'] as String,
  acceptanceCriteria: json['acceptanceCriteria'] == null
      ? null
      : Checklist.fromJson(json['acceptanceCriteria'] as Map<String, dynamic>),
  template: json['template'] == null
      ? null
      : Template.fromJson(json['template'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OutputToJson(Output instance) => <String, dynamic>{
  'name': instance.name,
  'template': ?instance.template?.toJson(),
  'acceptanceCriteria': ?instance.acceptanceCriteria?.toJson(),
};
