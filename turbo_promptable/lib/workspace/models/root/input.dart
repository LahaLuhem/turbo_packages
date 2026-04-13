import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/core/helpers/t_dart_render_helper.dart';
import 'package:turbo_promptable/workspace/models/root/checklist.dart';
import 'package:turbo_promptable/workspace/models/root/context.dart';
import 'package:turbo_promptable/workspace/models/root/goal.dart';
import 'package:turbo_promptable/workspace/models/root/issue.dart';
import 'package:turbo_promptable/workspace/models/root/prompt_field.dart';
import 'package:turbo_promptable/workspace/models/root/spec.dart';

part 'input.g.dart';

/// The input side of an [Activity]: a [request], [fields], and optional context.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Input extends TPromptable {
  const Input({
    required super.name,
    super.metaData,
    super.config,
    required this.request,
    required this.fields,
    this.context,
    this.goals,
    this.issues,
    this.checklists,
    this.specs,
  });

  final List<PromptField> fields;
  final List<Checklist>? checklists;
  final List<Context>? context;
  final List<Goal>? goals;
  final List<Issue>? issues;
  final List<Spec>? specs;
  final String request;

  factory Input.fromJson(Map<String, dynamic> json) => _$InputFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$InputToJson(this);

  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  @override
  String toDart() => toDartInline();

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  String toDartInline({
    int indentLevel = 0,
    bool includeConst = true,
  }) => renderConstructorCall(
    'Input',
    [
      renderStringArg('name', name, indent: indentLevel + 1),
      renderStringArg('request', request, indent: indentLevel + 1),
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
      renderExpressionListArg(
        'context',
        context
            ?.map(
              (c) => c.toDartInline(
                indentLevel: indentLevel + 2,
                includeConst: false,
              ),
            )
            .toList(),
        indent: indentLevel + 1,
      ),
      renderExpressionListArg(
        'goals',
        goals
            ?.map(
              (g) => g.toDartInline(
                indentLevel: indentLevel + 2,
                includeConst: false,
              ),
            )
            .toList(),
        indent: indentLevel + 1,
      ),
      renderExpressionListArg(
        'issues',
        issues
            ?.map(
              (i) => i.toDartInline(
                indentLevel: indentLevel + 2,
                includeConst: false,
              ),
            )
            .toList(),
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
      renderExpressionListArg(
        'specs',
        specs
            ?.map(
              (s) => s.toDartInline(
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
