// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prompt_field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PromptField _$PromptFieldFromJson(Map<String, dynamic> json) => PromptField(
  name: json['name'] as String,
  type: json['type'] as String,
  required: json['required'] as bool,
  description: json['description'] as String,
);

Map<String, dynamic> _$PromptFieldToJson(PromptField instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'required': instance.required,
      'description': instance.description,
    };
