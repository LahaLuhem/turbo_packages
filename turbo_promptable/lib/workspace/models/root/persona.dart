import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/activity.dart';
import 'package:turbo_promptable/workspace/models/root/checklist.dart';
import 'package:turbo_promptable/workspace/models/root/instruction.dart';
import 'package:turbo_promptable/workspace/models/root/role.dart';
import 'package:turbo_promptable/workspace/models/root/template.dart';
import 'package:turbo_promptable/workspace/models/root/tool.dart';
import 'package:turbo_promptable/workspace/models/root/workflow.dart';

part 'persona.g.dart';

@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
)
class Persona extends Role {
  const Persona({
    required super.name,
    required super.expertise,
    super.metaData,
    super.instructions,
    super.tools,
    this.identity,
  });

  final String? identity;

  Persona.fromRole({
    required Role role,
    required String identity,
    String? name,
    TMetaData? metaData,
    String? expertise,
    List<Instruction>? instructions,
    List<Tool>? tools,
  }) : this(
         name: name ?? role.name,
         metaData: metaData ?? role.metaData,
         expertise: expertise ?? role.expertise,
         instructions: instructions ?? role.instructions,
         tools: tools ?? role.tools,
         identity: identity,
       );

  factory Persona.fromJson(Map<String, dynamic> json) => _$PersonaFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PersonaToJson(this);
}
