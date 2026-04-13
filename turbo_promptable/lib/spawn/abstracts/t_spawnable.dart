import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/spawn/enums/t_cli_tool.dart';
import 'package:turbo_promptable/spawn/enums/t_prompt_delivery.dart';
import 'package:turbo_promptable/turbo_promptable.dart';

@JsonSerializable(
  createFactory: false,
  createToJson: false,
)
/// Base class for promptable models that can be spawned as CLI processes.
abstract class TSpawnable extends TPromptable {
  const TSpawnable({
    required super.name,
    super.config,
    super.metaData,
    this.cliTool,
    this.command,
    this.promptDelivery = TPromptDelivery.system,
  });

  final String? command;
  final TCliTool? cliTool;
  final TPromptDelivery promptDelivery;
}
