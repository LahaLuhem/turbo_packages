import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/spawn/enums/t_config_source.dart';
import 'package:turbo_promptable/workspace/models/meta/t_spawnable.dart';
import 'package:turbo_promptable/workspace/models/root/role.dart';

part 'agent.g.dart';

@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
  genericArgumentFactories: true,
)
class Agent<IDENTITY extends Role> extends TSpawnable {
  const Agent({
    required super.cliTool,
    super.tools,
    super.yolo = true,
    super.model,
    super.headless = true,
    super.mcpsConfigSource = ConfigSource.none,
    required this.identity,
  });

  final IDENTITY identity;

  @override
  String spawn({required String prompt, String? conversationId}) => cliTool.spawn(
    request: prompt,
    conversationId: conversationId,
    systemPrompt: identity.toMd(),
    tools: tools,
    yolo: yolo,
    model: model,
    headless: headless,
    mcpsConfigSource: mcpsConfigSource,
  );

  factory Agent.fromJson(
    Map<String, dynamic> json,
    IDENTITY Function(Object? json) fromJsonIdentity,
  ) => _$AgentFromJson(json, fromJsonIdentity);

  @override
  Map<String, dynamic> toJson() => _$AgentToJson(
    this,
    (IDENTITY identity) => identity.toJson(),
  );
}
