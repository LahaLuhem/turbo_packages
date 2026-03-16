import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/shared/abstracts/turbo_promptable.dart';

part 'idea_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class IdeaDto extends TurboPromptable {
  IdeaDto({this.title, this.content, this.metadata});

  final String? title;
  final String? content;
  final Map<String, dynamic>? metadata;

  static const fromJsonFactory = _$IdeaDtoFromJson;
  factory IdeaDto.fromJson(Map<String, dynamic> json) =>
      _$IdeaDtoFromJson(json);
  static const toJsonFactory = _$IdeaDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$IdeaDtoToJson(this);

  IdeaDto copyWith({
    String? title,
    String? content,
    Map<String, dynamic>? metadata,
  }) => IdeaDto(
    title: title ?? this.title,
    content: content ?? this.content,
    metadata: metadata ?? this.metadata,
  );

  @override
  String toString() =>
      'IdeaDto{title: $title, content: $content, metadata: $metadata}';
}
