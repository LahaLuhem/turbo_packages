import 'package:turbo_promptable/workspace/abstracts/root/input.dart';
import 'package:turbo_promptable/workspace/abstracts/root/instruction.dart';
import 'package:turbo_promptable/workspace/abstracts/root/output.dart';

class Step extends TPromptable {
  Step({
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
}
