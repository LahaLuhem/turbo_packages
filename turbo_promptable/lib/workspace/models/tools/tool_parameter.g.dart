// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool_parameter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ToolParameter _$ToolParameterFromJson(Map<String, dynamic> json) =>
    ToolParameter(
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] as String?,
      required: json['required'] as bool?,
      defaultValue: json['defaultValue'] as String?,
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => ToolParameterOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ToolParameterToJson(ToolParameter instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': ?instance.description,
      'type': ?instance.type,
      'required': ?instance.required,
      'defaultValue': ?instance.defaultValue,
      'options': ?instance.options?.map((e) => e.toJson()).toList(),
    };
