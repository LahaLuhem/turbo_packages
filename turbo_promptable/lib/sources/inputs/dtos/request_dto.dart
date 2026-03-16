import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/shared/abstracts/turbo_promptable.dart';

part 'request_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class RequestDto extends TurboPromptable {
  RequestDto({this.title, this.content, this.metadata});

  final String? title;
  final String? content;
  final Map<String, dynamic>? metadata;

  static const fromJsonFactory = _$RequestDtoFromJson;
  factory RequestDto.fromJson(Map<String, dynamic> json) =>
      _$RequestDtoFromJson(json);
  static const toJsonFactory = _$RequestDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$RequestDtoToJson(this);

  RequestDto copyWith({
    String? title,
    String? content,
    Map<String, dynamic>? metadata,
  }) => RequestDto(
    title: title ?? this.title,
    content: content ?? this.content,
    metadata: metadata ?? this.metadata,
  );

  @override
  String toString() =>
      'RequestDto{title: $title, content: $content, metadata: $metadata}';
}
