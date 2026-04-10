import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_serializable/abstracts/t_serializable.dart';

part 'prompt_field.g.dart';

/// A typed parameter in an [Input] or [Output] with a [name], [type], and [description].
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class PromptField extends TSerializable {
  const PromptField({
    required this.name,
    required this.type,
    required this.required,
    required this.description,
  });

  final String name;
  final String type;
  final bool required;
  final String description;

  factory PromptField.fromJson(Map<String, dynamic> json) =>
      _$PromptFieldFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PromptFieldToJson(this);
}
