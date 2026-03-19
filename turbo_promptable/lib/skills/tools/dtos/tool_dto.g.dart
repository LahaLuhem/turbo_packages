// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ToolDto<INPUT, OUTPUT> _$ToolDtoFromJson<INPUT, OUTPUT>(
  Map<String, dynamic> json,
  INPUT Function(Object? json) fromJsonINPUT,
  OUTPUT Function(Object? json) fromJsonOUTPUT,
) => ToolDto<INPUT, OUTPUT>(
  input: _$nullableGenericFromJson(json['input'], fromJsonINPUT),
  output: _$nullableGenericFromJson(json['output'], fromJsonOUTPUT),
  instructions: json['instructions'] as String?,
);

Map<String, dynamic> _$ToolDtoToJson<INPUT, OUTPUT>(
  ToolDto<INPUT, OUTPUT> instance,
  Object? Function(INPUT value) toJsonINPUT,
  Object? Function(OUTPUT value) toJsonOUTPUT,
) => <String, dynamic>{
  'input': _$nullableGenericToJson(instance.input, toJsonINPUT),
  'output': _$nullableGenericToJson(instance.output, toJsonOUTPUT),
  'instructions': instance.instructions,
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);
