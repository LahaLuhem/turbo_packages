import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/core/helpers/t_dart_render_helper.dart';
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

  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  @override
  String toDart() => toDartInline();

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  String toDartInline({int indentLevel = 0, bool includeConst = true}) =>
      renderConstructorCall(
        'PromptField',
        [
          renderStringArg('name', name, indent: indentLevel + 1),
          renderStringArg('type', type, indent: indentLevel + 1),
          renderBoolArg('required', required, indent: indentLevel + 1),
          renderStringArg('description', description, indent: indentLevel + 1),
        ],
        indentLevel: indentLevel,
        includeConst: includeConst,
      );
}
