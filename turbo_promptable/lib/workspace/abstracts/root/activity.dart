import 'package:turbo_promptable/workspace/abstracts/meta/t_promptable.dart';
import 'package:turbo_promptable/workspace/abstracts/root/output.dart';
import 'package:turbo_promptable/workspace/abstracts/root/input.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_workflow.dart';

 class Activity extends TPromptable {
  Activity({
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
}
