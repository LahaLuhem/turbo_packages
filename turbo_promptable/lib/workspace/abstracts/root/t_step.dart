import 'package:turbo_promptable/workspace/abstracts/root/t_input.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_instruction.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_output.dart';

abstract class TStep<INPUT extends TInput, INSTRUCTION extends TInstruction, OUTPUT extends TOutput>
    extends TPromptable {
  TStep({
    required super.name,
    super.renderType = TRenderType.embed,
    super.bodyType = TBodyType.md,
    super.emoji,
    super.leadingBody,
    super.bodyBuilder,
    super.metaData,
    super.trailingBody,
    required this.input,
    required this.instructions,
    required this.output,
  });

  final INPUT input;
  final List<INSTRUCTION>? instructions;
  final OUTPUT output;
}
