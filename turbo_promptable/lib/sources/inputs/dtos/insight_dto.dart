import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/shared/abstracts/turbo_promptable.dart';

part 'insight_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class InsightDto extends TurboPromptable {
  InsightDto({this.title, this.content, this.metadata});

  final String? title;
  final String? content;
  final Map<String, dynamic>? metadata;

  static const fromJsonFactory = _$InsightDtoFromJson;
  factory InsightDto.fromJson(Map<String, dynamic> json) =>
      _$InsightDtoFromJson(json);
  static const toJsonFactory = _$InsightDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$InsightDtoToJson(this);

  InsightDto copyWith({
    String? title,
    String? content,
    Map<String, dynamic>? metadata,
  }) => InsightDto(
    title: title ?? this.title,
    content: content ?? this.content,
    metadata: metadata ?? this.metadata,
  );

  @override
  String toString() =>
      'InsightDto{title: $title, content: $content, metadata: $metadata}';
}
