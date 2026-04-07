import 'package:turbo_promptable/workspace/abstracts/root/context.dart';
import 'package:turbo_promptable/workspace/abstracts/root/goal.dart';
import 'package:turbo_promptable/workspace/abstracts/root/issue.dart';
import 'package:turbo_promptable/workspace/abstracts/root/spec.dart';

 class Input extends TPromptable {
  Input({
    required super.name,
    super.metaData,
    super.config,
    required this.request,
    this.context,
    this.goals,
    this.issues,
    this.specs,
  });

  final List<Context>? context;
  final List<Goal>? goals;
  final List<Issue>? issues;
  final List<Spec>? specs;
  final String request;
}
