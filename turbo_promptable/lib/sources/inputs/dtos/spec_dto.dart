import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/shared/abstracts/turbo_promptable.dart';

part 'spec_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class SpecDto extends TurboPromptable {
  SpecDto({this.title, this.content, this.metadata});

  final String? title;
  final String? content;
  final Map<String, dynamic>? metadata;

  static const fromJsonFactory = _$SpecDtoFromJson;
  factory SpecDto.fromJson(Map<String, dynamic> json) =>
      _$SpecDtoFromJson(json);
  static const toJsonFactory = _$SpecDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$SpecDtoToJson(this);

  SpecDto copyWith({
    String? title,
    String? content,
    Map<String, dynamic>? metadata,
  }) => SpecDto(
    title: title ?? this.title,
    content: content ?? this.content,
    metadata: metadata ?? this.metadata,
  );

  @override
  String toString() =>
      'SpecDto{title: $title, content: $content, metadata: $metadata}';
}
