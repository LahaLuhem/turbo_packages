import 'package:turbo_promptable/workspace/abstracts/root/t_activity.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_checklist.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_instruction.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_role.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_template.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_tool.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_workflow.dart';

abstract class TAgent<
ACTIVITY extends TActivity,
INSTRUCTION extends TInstruction,
CHECKLIST extends TChecklist,
ROLE extends TRole,
TEMPLATE extends TTemplate,
TOOL extends TTool,
WORKFLOW extends TWorkflow
>
    extends TPromptable {
  TAgent({
    required super.name,
    super.renderType = TRenderType.embed,
    super.bodyType = TBodyType.md,
    super.emoji,
    super.leadingBody,
    super.bodyBuilder,
    super.metaData,
    super.trailingBody,
    this.activities,
    this.checklists,
    this.instructions,
    required this.hats,
    this.templates,
    this.tools,
    this.workflows,
    this.role,
    required this.identity,
  });

  final List<ACTIVITY>? activities;
  final List<CHECKLIST>? checklists;
  final List<INSTRUCTION>? instructions;
  final List<ROLE> hats;
  final List<TEMPLATE>? templates;
  final List<TOOL>? tools;
  final List<WORKFLOW>? workflows;
  final ROLE? role;
  final String identity;
}
