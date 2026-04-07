import 'package:turbo_promptable/workspace/abstracts/checklists/t_acceptance_criteria.dart';
import 'package:turbo_promptable/workspace/abstracts/meta/t_promptable.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_result.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_template.dart';

abstract class TOutput<
  TEMPLATE extends TTemplate,
  ACCEPTANCE_CRITERIA extends TAcceptanceCriteria,
  RESULT extends TResult
>
    extends TPromptable {
  TOutput({
    required super.name,
    super.renderType = TRenderType.embed,
    super.bodyType = TBodyType.md,
    super.emoji,
    super.leadingBody,
    super.bodyBuilder,
    super.metaData,
    super.trailingBody,
    this.template,
    this.acceptanceCriteria,
    required this.result,
  });

  final TEMPLATE? template;
  final ACCEPTANCE_CRITERIA? acceptanceCriteria;
  final RESULT result;
}
