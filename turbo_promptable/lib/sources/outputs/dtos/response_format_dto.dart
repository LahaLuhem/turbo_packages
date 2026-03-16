import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/shared/abstracts/turbo_promptable.dart';

part 'response_format_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class ResponseFormatDto extends TurboPromptable {
  ResponseFormatDto({this.format, this.schema});

  final String? format;
  final Map<String, dynamic>? schema;

  static const fromJsonFactory = _$ResponseFormatDtoFromJson;
  factory ResponseFormatDto.fromJson(Map<String, dynamic> json) =>
      _$ResponseFormatDtoFromJson(json);
  static const toJsonFactory = _$ResponseFormatDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$ResponseFormatDtoToJson(this);

  ResponseFormatDto copyWith({
    String? format,
    Map<String, dynamic>? schema,
  }) => ResponseFormatDto(
    format: format ?? this.format,
    schema: schema ?? this.schema,
  );

  @override
  String toString() =>
      'ResponseFormatDto{format: $format, schema: $schema}';
}
