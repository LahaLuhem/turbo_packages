import 'package:turbo_promptable/workspace/abstracts/meta/t_promptable.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_input.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_output.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_persona.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_role.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_workflow.dart';

abstract class TActivity<
  ROLE extends TRole,
  PERSONA extends TPersona,
  INPUT extends TInput,
  WORKFLOW extends TWorkflow,
  OUTPUT extends TOutput
>
    extends TPromptable {
  TActivity({
    required super.name,
    required this.input,
    required this.output,
    required this.workflow,
    super.metaData,
    this.persona,
    this.role,
  });

  final ROLE? role;
  final PERSONA? persona;
  final INPUT input;
  final WORKFLOW workflow;
  final OUTPUT output;
}
