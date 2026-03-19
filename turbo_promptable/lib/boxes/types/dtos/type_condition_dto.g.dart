// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'type_condition_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TypeConditionDto _$TypeConditionDtoFromJson(Map<String, dynamic> json) =>
    TypeConditionDto(
      field: TypeConditionField.fromJson(json['field'] as String),
      operator: TypeConditionOperator.fromJson(json['operator'] as String),
      value: json['value'] as String,
    );

Map<String, dynamic> _$TypeConditionDtoToJson(TypeConditionDto instance) =>
    <String, dynamic>{
      'field': _fieldToJson(instance.field),
      'operator': _operatorToJson(instance.operator),
      'value': instance.value,
    };
