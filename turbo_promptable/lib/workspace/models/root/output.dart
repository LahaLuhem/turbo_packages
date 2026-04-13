import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/core/helpers/t_dart_render_helper.dart';
import 'package:turbo_promptable/workspace/models/root/checklist.dart';
import 'package:turbo_promptable/workspace/models/root/prompt_field.dart';
import 'package:turbo_promptable/workspace/models/root/template.dart';

part 'output.g.dart';

/// The output side of an [Activity]: [fields], optional [template], and [checklists].
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Output extends TPromptable {
  const Output({
    required super.name,
    super.metaData,
    required this.fields,
    this.checklists,
    this.template,
  });

  final List<PromptField> fields;
  final Template? template;
  final List<Checklist>? checklists;

  factory Output.fromJson(Map<String, dynamic> json) => _$OutputFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$OutputToJson(this);

  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  @override
  String toDart() => toDartInline();

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  String toDartInline({
    int indentLevel = 0,
    bool includeConst = true,
  }) => renderConstructorCall(
    'Output',
    [
      renderStringArg('name', name, indent: indentLevel + 1),
      renderExpressionListArg(
        'fields',
        fields
            .map(
              (f) => f.toDartInline(
                indentLevel: indentLevel + 2,
                includeConst: false,
              ),
            )
            .toList(),
        indent: indentLevel + 1,
      ),
      renderExpressionArg(
        'template',
        template?.toDartInline(
          indentLevel: indentLevel + 1,
          includeConst: false,
        ),
        indent: indentLevel + 1,
      ),
      renderExpressionListArg(
        'checklists',
        checklists
            ?.map(
              (c) => c.toDartInline(
                indentLevel: indentLevel + 2,
                includeConst: false,
              ),
            )
            .toList(),
        indent: indentLevel + 1,
      ),
    ],
    indentLevel: indentLevel,
    includeConst: includeConst,
  );
}
