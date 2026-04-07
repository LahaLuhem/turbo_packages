import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';
import 'package:turbo_promptable/workspace/models/root/activity.dart';
import 'package:turbo_promptable/workspace/models/root/checklist.dart';
import 'package:turbo_promptable/workspace/models/root/instruction.dart';
import 'package:turbo_promptable/workspace/models/root/template.dart';
import 'package:turbo_promptable/workspace/models/root/tool.dart';
import 'package:turbo_promptable/workspace/models/root/workflow.dart';

part 'role.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Role extends TPromptable {
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

  static final Role Function(Map<String, dynamic> json) fromJsonFactory =
      _$RoleFromJson;
  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
  static final Map<String, dynamic> Function(Role value) toJsonFactory =
      _$RoleToJson;
  @override
  Map<String, dynamic> toJson() => _$RoleToJson(this);
}
