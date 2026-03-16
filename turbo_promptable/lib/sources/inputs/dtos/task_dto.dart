import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/shared/abstracts/turbo_promptable.dart';

part 'task_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class TaskDto extends TurboPromptable {
  TaskDto({this.title, this.content, this.metadata});

  final String? title;
  final String? content;
  final Map<String, dynamic>? metadata;

  static const fromJsonFactory = _$TaskDtoFromJson;
  factory TaskDto.fromJson(Map<String, dynamic> json) =>
      _$TaskDtoFromJson(json);
  static const toJsonFactory = _$TaskDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$TaskDtoToJson(this);

  TaskDto copyWith({
    String? title,
    String? content,
    Map<String, dynamic>? metadata,
  }) => TaskDto(
    title: title ?? this.title,
    content: content ?? this.content,
    metadata: metadata ?? this.metadata,
  );

  @override
  String toString() =>
      'TaskDto{title: $title, content: $content, metadata: $metadata}';
}
