// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acceptance_criteria.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcceptanceCriteria _$AcceptanceCriteriaFromJson(Map<String, dynamic> json) =>
    AcceptanceCriteria(
      name: json['name'] as String,
      items: (json['items'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$AcceptanceCriteriaToJson(AcceptanceCriteria instance) =>
    <String, dynamic>{'name': instance.name, 'items': instance.items};
