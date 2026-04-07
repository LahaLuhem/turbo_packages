import 'package:turbo_promptable/workspace/abstracts/meta/t_promptable.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_step.dart';

abstract class TWorkflow<STEP extends TStep> extends TPromptable {
  TWorkflow({
    required super.name,
    super.renderType = TRenderType.embed,
    super.bodyType = TBodyType.md,
    super.emoji,
    super.leadingBody,
    super.bodyBuilder,
    super.metaData,
    super.trailingBody,
    required this.steps,
  });

  final List<STEP> steps;
}
