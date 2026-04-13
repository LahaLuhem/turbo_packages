import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/core/helpers/t_dart_render_helper.dart';
import 'package:turbo_promptable/workspace/models/root/input.dart';
import 'package:turbo_promptable/workspace/models/root/instruction.dart';
import 'package:turbo_promptable/workspace/models/root/output.dart';

part 'step.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Step extends TPromptable {
  const Step({
    required super.name,
    super.metaData,
    super.config,
    required this.input,
    required this.instructions,
    required this.output,
  });

  final Input input;
  final List<Instruction>? instructions;
  final Output output;

  factory Step.fromJson(Map<String, dynamic> json) => _$StepFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$StepToJson(this);

  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  @override
  String toDart() => toDartInline();

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  String toDartInline({int indentLevel = 0, bool includeConst = true}) =>
      renderConstructorCall(
        'Step',
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
          renderExpressionListArg(
            'instructions',
            instructions
                ?.map(
                  (i) => i.toDartInline(
                    indentLevel: indentLevel + 2,
                    includeConst: false,
                  ),
                )
                .toList(),
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
        ],
        indentLevel: indentLevel,
        includeConst: includeConst,
      );
}
