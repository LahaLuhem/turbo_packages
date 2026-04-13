import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/core/helpers/t_dart_render_helper.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';
import 'package:turbo_promptable/workspace/models/workflows/step.dart';

part 'workflow.g.dart';

/// An ordered sequence of [Step]s that define a process.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Workflow extends TPromptable {
  const Workflow({
    required super.name,
    super.metaData,
    super.config,
    required this.steps,
  });

  final List<Step> steps;

  factory Workflow.fromJson(Map<String, dynamic> json) =>
      _$WorkflowFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$WorkflowToJson(this);

  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  @override
  String toDart() => wrapStandaloneDartFile(
    variableName: jsonKey,
    expression: toDartInline(includeConst: false),
  );

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  String toDartInline({int indentLevel = 0, bool includeConst = true}) =>
      renderConstructorCall(
        'Workflow',
        [
          renderStringArg('name', name, indent: indentLevel + 1),
          renderExpressionListArg(
            'steps',
            steps
                .map(
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
