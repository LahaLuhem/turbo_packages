import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/turbo_promptable.dart';

part 'role.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Role extends TPromptable {
  const Role({
    required super.name,
    super.metaData,
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

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RoleToJson(this);

  Role copyWith({
    String? name,
    TMetaData? metaData,
    String? expertise,
    List<Activity>? activities,
    List<Checklist>? checklists,
    List<Instruction>? instructions,
    List<Template>? templates,
    List<Tool>? tools,
    List<Workflow>? workflows,
  }) => Role(
    name: name ?? this.name,
    metaData: metaData ?? this.metaData,
    expertise: expertise ?? this.expertise,
    activities: activities ?? this.activities,
    checklists: checklists ?? this.checklists,
    instructions: instructions ?? this.instructions,
    templates: templates ?? this.templates,
    tools: tools ?? this.tools,
    workflows: workflows ?? this.workflows,
  );
}
