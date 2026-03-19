// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_format_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResponseFormatDto _$ResponseFormatDtoFromJson(Map<String, dynamic> json) =>
    ResponseFormatDto(
      format: json['format'] as String?,
      schema: json['schema'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ResponseFormatDtoToJson(ResponseFormatDto instance) =>
    <String, dynamic>{'format': instance.format, 'schema': instance.schema};
