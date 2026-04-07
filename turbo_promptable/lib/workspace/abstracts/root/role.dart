import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/abstracts/root/activity.dart';
import 'package:turbo_promptable/workspace/abstracts/root/checklist.dart';
import 'package:turbo_promptable/workspace/abstracts/root/instruction.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_template.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_tool.dart';
import 'package:turbo_promptable/workspace/abstracts/root/t_workflow.dart';

part 't_role.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Role
    extends TPromptable {
  Role({
    required super.name,
    super.metaData,
    super.config,
    required this.expertise,
    this.activities,
    this.checklists,
    this.instructions,
    this.templates,
    this.tools,
    this.workflows,
  });

  final List<Activity>? activities;
  final List<Checklist>? checklists;
  final List<Instruction>? instructions;
  final List<Template>? templates;
  final List<Tool>? tools;
  final List<Workflow>? workflows;
  final String expertise;

  static const fromJsonFactory = _$RoleFromJson;
  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
  static const toJsonFactory = _$RoleToJson;
  @override
  Map<String, dynamic> toJson() => _$RoleToJson(this);
}
