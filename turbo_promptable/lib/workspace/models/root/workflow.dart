import 'package:turbo_promptable/workspace/abstracts/meta/t_promptable.dart';
import 'package:turbo_promptable/workspace/abstracts/workflows/step.dart';

 class Workflow extends TPromptable {
  Workflow({
    required super.name,
    super.metaData,
    super.config,
    required this.steps,
  });

  final List<Step> steps;
}
