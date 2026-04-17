import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/spawn/enums/t_cli_tool.dart';
import 'package:turbo_promptable/spawn/enums/t_prompt_delivery.dart';
import 'package:turbo_promptable/workspace/models/root/activity.dart';
import 'package:turbo_promptable/workspace/models/root/checklist.dart';
import 'package:turbo_promptable/workspace/models/root/instruction.dart';
import 'package:turbo_promptable/workspace/models/root/role.dart';
import 'package:turbo_promptable/workspace/models/root/template.dart';
import 'package:turbo_promptable/workspace/models/root/tool.dart';
import 'package:turbo_promptable/workspace/models/root/workflow.dart';

part 'persona.g.dart';

/// A [Role] augmented with an [identity] that describes the persona's character.
@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
)
class Persona extends Role {
  const Persona({
    required super.name,
    super.metaData,
    required super.expertise,
    super.activities,
    super.checklists,
    super.instructions,
    super.templates,
    super.tools,
    super.workflows,
    super.cliTool,
    super.command,
    super.promptDelivery,
    required this.identity,
  });

  final String identity;

  Persona.fromRole({
    required Role role,
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

  factory Persona.fromJson(Map<String, dynamic> json) =>
      _$PersonaFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PersonaToJson(this);
}
