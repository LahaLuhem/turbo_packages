import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/root/persona.dart';

part 'agent.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Agent extends Persona {
  Agent({
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

  static final Agent Function(Map<String, dynamic> json) fromJsonFactory =
      _$AgentFromJson;
  factory Agent.fromJson(Map<String, dynamic> json) => _$AgentFromJson(json);
  static final Map<String, dynamic> Function(Agent value) toJsonFactory =
      _$AgentToJson;
  @override
  Map<String, dynamic> toJson() => _$AgentToJson(this);
}
