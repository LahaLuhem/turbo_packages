import 'package:turbo_promptable/workspace/abstracts/root/t_context.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_goal.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_issue.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_spec.dart';

abstract class TInput<
  CONTEXT extends TContext,
  GOAL extends TGoal,
  ISSUE extends TIssue,
  SPEC extends TSpec
>
    extends TPromptable {
  TInput({
    required super.name,
    super.renderType = TRenderType.embed,
    super.bodyType = TBodyType.md,
    super.emoji,
    super.leadingBody,
    super.bodyBuilder,
    super.metaData,
    super.trailingBody,
    required this.request,
    this.context,
    this.goals,
    this.issues,
    this.specs,
  });

  final List<CONTEXT>? context;
  final List<GOAL>? goals;
  final List<ISSUE>? issues;
  final List<SPEC>? specs;
  final String request;
}
