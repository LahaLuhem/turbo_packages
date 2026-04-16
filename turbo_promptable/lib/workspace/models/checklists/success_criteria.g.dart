// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'success_criteria.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SuccessCriteria _$SuccessCriteriaFromJson(Map<String, dynamic> json) =>
    SuccessCriteria(
      name: json['name'] as String,
      items: (json['items'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$SuccessCriteriaToJson(SuccessCriteria instance) =>
    <String, dynamic>{'name': instance.name, 'items': instance.items};
