import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/spawn/enums/t_config_source.dart';
import 'package:turbo_promptable/turbo_promptable.dart';
import 'package:turbo_promptable/workspace/models/meta/t_spawnable.dart';
import 'package:turbo_promptable/workspace/models/root/role.dart';

part 'agent.g.dart';

@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
  genericArgumentFactories: true,
)
class Agent<IDENTITY extends Role> extends TSpawnable {
  const Agent(
    super.name, {
    required super.id,
    super.allowedTools,
    super.yolo = true,
    super.model,
    super.headless = true,
    required this.identity,
    this.workflow,
  });

  final IDENTITY identity;
  final Workflow? workflow;

  factory Agent.fromJson(
    Map<String, dynamic> json,
    IDENTITY Function(Object? json) fromJsonIdentity,
  ) => _$AgentFromJson(json, fromJsonIdentity);

  @override
  Map<String, dynamic> toJson() => _$AgentToJson(
    this,
    (IDENTITY identity) => identity.toJson(),
  );

  @override
  String get systemPrompt => identity.toMd();
}
