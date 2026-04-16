// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool_parameter_option.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ToolParameterOption _$ToolParameterOptionFromJson(Map<String, dynamic> json) =>
    ToolParameterOption(
      name: json['name'] as String,
      description: json['description'] as String?,
      isRequired: json['isRequired'] as bool?,
      isDefault: json['isDefault'] as bool?,
    );

Map<String, dynamic> _$ToolParameterOptionToJson(
  ToolParameterOption instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': ?instance.description,
  'isRequired': ?instance.isRequired,
  'isDefault': ?instance.isDefault,
};
