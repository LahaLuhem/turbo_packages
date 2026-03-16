import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/shared/abstracts/turbo_promptable.dart';

part 'template_dto.g.dart';

@JsonSerializable(includeIfNull: true, explicitToJson: true)
class TemplateDto extends TurboPromptable {
  TemplateDto({
    this.variables,
  });

  final Map<String, String>? variables;

  static const fromJsonFactory = _$TemplateDtoFromJson;
  factory TemplateDto.fromJson(Map<String, dynamic> json) =>
      _$TemplateDtoFromJson(json);
  static const toJsonFactory = _$TemplateDtoToJson;
  @override
  Map<String, dynamic> toJson() => _$TemplateDtoToJson(this);

  TemplateDto copyWith({
    Map<String, String>? variables,
  }) {
    return TemplateDto(
      variables: variables ?? this.variables,
    );
  }

  @override
  String toString() => 'TemplateDto{variables: $variables}';
}
