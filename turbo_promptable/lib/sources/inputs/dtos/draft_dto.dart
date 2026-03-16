import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/shared/abstracts/turbo_promptable.dart';

part 'draft_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class DraftDto extends TurboPromptable {
  DraftDto({this.title, this.content, this.metadata});

  final String? title;
  final String? content;
  final Map<String, dynamic>? metadata;

  static const fromJsonFactory = _$DraftDtoFromJson;
  factory DraftDto.fromJson(Map<String, dynamic> json) =>
      _$DraftDtoFromJson(json);
  static const toJsonFactory = _$DraftDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$DraftDtoToJson(this);

  DraftDto copyWith({
    String? title,
    String? content,
    Map<String, dynamic>? metadata,
  }) => DraftDto(
    title: title ?? this.title,
    content: content ?? this.content,
    metadata: metadata ?? this.metadata,
  );

  @override
  String toString() =>
      'DraftDto{title: $title, content: $content, metadata: $metadata}';
}
