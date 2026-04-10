import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/core/models/t_config.dart';
import 'package:turbo_promptable/workspace/models/meta/t_meta_data.dart';
import 'package:turbo_promptable/workspace/models/root/activity.dart';
import 'package:turbo_promptable/workspace/models/root/checklist.dart';
import 'package:turbo_promptable/workspace/models/root/instruction.dart';
import 'package:turbo_promptable/workspace/models/root/persona.dart';
import 'package:turbo_promptable/workspace/models/root/role.dart';
import 'package:turbo_promptable/workspace/models/root/template.dart';
import 'package:turbo_promptable/workspace/models/root/tool.dart';
import 'package:turbo_promptable/workspace/models/root/workflow.dart';

part 'agent.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Agent extends Persona {
  const Agent({
    required super.expertise,
    required super.identity,
    required super.name,
    super.activities,
    super.checklists,
    super.config,
    super.instructions,
    super.metaData,
    super.templates,
    super.tools,
    super.workflows,
  });

  Agent.fromPersona(
    Persona persona, {
    String? name,
    TMetaData? metaData,
    TConfig? config,
    String? expertise,
    List<Activity>? activities,
    List<Checklist>? checklists,
    List<Instruction>? instructions,
    List<Template>? templates,
    List<Tool>? tools,
    List<Workflow>? workflows,
    String? identity,
  }) : this(
         name: name ?? persona.name,
         metaData: metaData ?? persona.metaData,
         config: config ?? persona.config,
         expertise: expertise ?? persona.expertise,
         activities: activities ?? persona.activities,
         checklists: checklists ?? persona.checklists,
         instructions: instructions ?? persona.instructions,
         templates: templates ?? persona.templates,
         tools: tools ?? persona.tools,
         workflows: workflows ?? persona.workflows,
         identity: identity ?? persona.identity,
       );

  Agent.fromRole(
    Role role, {
    required String identity,
    String? name,
    TMetaData? metaData,
    TConfig? config,
    String? expertise,
    List<Activity>? activities,
    List<Checklist>? checklists,
    List<Instruction>? instructions,
    List<Template>? templates,
    List<Tool>? tools,
    List<Workflow>? workflows,
  }) : this(
         name: name ?? role.name,
         metaData: metaData ?? role.metaData,
         config: config ?? role.config,
         expertise: expertise ?? role.expertise,
         activities: activities ?? role.activities,
         checklists: checklists ?? role.checklists,
         instructions: instructions ?? role.instructions,
         templates: templates ?? role.templates,
         tools: tools ?? role.tools,
         workflows: workflows ?? role.workflows,
         identity: identity,
       );

  @override
  Agent copyWith({
    String? name,
    TMetaData? metaData,
    TConfig? config,
    String? expertise,
    List<Activity>? activities,
    List<Checklist>? checklists,
    List<Instruction>? instructions,
    List<Template>? templates,
    List<Tool>? tools,
    List<Workflow>? workflows,
    String? identity,
  }) => Agent(
    name: name ?? this.name,
    metaData: metaData ?? this.metaData,
    config: config ?? this.config,
    expertise: expertise ?? this.expertise,
    activities: activities ?? this.activities,
    checklists: checklists ?? this.checklists,
    instructions: instructions ?? this.instructions,
    templates: templates ?? this.templates,
    tools: tools ?? this.tools,
    workflows: workflows ?? this.workflows,
    identity: identity ?? this.identity,
  );

  factory Agent.fromJson(Map<String, dynamic> json) => _$AgentFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AgentToJson(this);
}
