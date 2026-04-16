import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/spawn/enums/t_cli_tool.dart';
import 'package:turbo_promptable/spawn/enums/t_prompt_delivery.dart';
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

/// An autonomous agent built from a [Persona] with full role capabilities.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Agent extends Persona {
  const Agent({
    required super.expertise,
    required super.identity,
    required super.name,
    super.activities,
    super.checklists,
    super.instructions,
    super.metaData,
    super.templates,
    super.tools,
    super.workflows,
    super.cliTool,
    super.command,
    super.promptDelivery,
  });

  Agent.fromPersona(
    Persona persona, {
    String? name,
    TMetaData? metaData,
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
         expertise: expertise ?? role.expertise,
         activities: activities ?? role.activities,
         checklists: checklists ?? role.checklists,
         instructions: instructions ?? role.instructions,
         templates: templates ?? role.templates,
         tools: tools ?? role.tools,
         workflows: workflows ?? role.workflows,
         identity: identity,
       );

  factory Agent.fromJson(Map<String, dynamic> json) => _$AgentFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AgentToJson(this);
}
