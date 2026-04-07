// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'constraints.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Constraints _$ConstraintsFromJson(Map<String, dynamic> json) => Constraints(
  name: json['name'] as String,
  items: (json['items'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$ConstraintsToJson(Constraints instance) =>
    <String, dynamic>{'name': instance.name, 'items': instance.items};
