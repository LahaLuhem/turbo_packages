// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TemplateDto _$TemplateDtoFromJson(Map<String, dynamic> json) => TemplateDto(
  variables: (json['variables'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
);

Map<String, dynamic> _$TemplateDtoToJson(TemplateDto instance) =>
    <String, dynamic>{'variables': instance.variables};
