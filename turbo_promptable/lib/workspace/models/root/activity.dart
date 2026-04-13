import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/core/helpers/t_dart_render_helper.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';
import 'package:turbo_promptable/workspace/models/root/input.dart';
import 'package:turbo_promptable/workspace/models/root/output.dart';
import 'package:turbo_promptable/workspace/models/root/workflow.dart';

part 'activity.g.dart';

/// A discrete unit of work with an [input], a [workflow], and an [output].
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Activity extends TPromptable {
  const Activity({
    required super.name,
    required this.input,
    required this.output,
    required this.workflow,
    super.config,
    super.metaData,
  });

  final Input input;
  final Workflow workflow;
  final Output output;

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ActivityToJson(this);

  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  @override
  String toDart() => wrapStandaloneDartFile(
    variableName: jsonKey,
    expression: toDartInline(includeConst: false),
  );

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  String toDartInline({int indentLevel = 0, bool includeConst = true}) =>
      renderConstructorCall(
        'Activity',
        [
          renderStringArg('name', name, indent: indentLevel + 1),
          renderExpressionArg(
            'input',
            input.toDartInline(
              indentLevel: indentLevel + 1,
              includeConst: false,
            ),
            indent: indentLevel + 1,
          ),
          renderExpressionArg(
            'output',
            output.toDartInline(
              indentLevel: indentLevel + 1,
              includeConst: false,
            ),
            indent: indentLevel + 1,
          ),
          renderExpressionArg(
            'workflow',
            workflow.toDartInline(
              indentLevel: indentLevel + 1,
              includeConst: false,
            ),
            indent: indentLevel + 1,
          ),
        ],
        indentLevel: indentLevel,
        includeConst: includeConst,
      );
}
