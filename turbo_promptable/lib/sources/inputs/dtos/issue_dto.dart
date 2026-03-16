import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/shared/abstracts/turbo_promptable.dart';

part 'issue_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class IssueDto extends TurboPromptable {
  IssueDto({this.title, this.content, this.metadata});

  final String? title;
  final String? content;
  final Map<String, dynamic>? metadata;

  static const fromJsonFactory = _$IssueDtoFromJson;
  factory IssueDto.fromJson(Map<String, dynamic> json) =>
      _$IssueDtoFromJson(json);
  static const toJsonFactory = _$IssueDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$IssueDtoToJson(this);

  IssueDto copyWith({
    String? title,
    String? content,
    Map<String, dynamic>? metadata,
  }) => IssueDto(
    title: title ?? this.title,
    content: content ?? this.content,
    metadata: metadata ?? this.metadata,
  );

  @override
  String toString() =>
      'IssueDto{title: $title, content: $content, metadata: $metadata}';
}
