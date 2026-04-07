import 'package:turbo_promptable/workspace/abstracts/meta/t_promptable.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_input.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_output.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_workflow.dart';

abstract class TActivity<INPUT extends TInput, WORKFLOW extends TWorkflow, OUTPUT extends TOutput>
    extends TPromptable {
  TActivity({
    required this.input,
    required this.output,
    required this.workflow,
    required super.name,
    super.renderType = TRenderType.embed,
    super.bodyType = TBodyType.md,
    super.emoji,
    super.leadingBody,
    super.bodyBuilder,
    super.metaData,
    super.trailingBody,
  });

  final INPUT input;
  final WORKFLOW workflow;
  final OUTPUT output;
}
