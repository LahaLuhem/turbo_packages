import 'package:meta/meta.dart';
import 'package:turbo_promptable/spawn/enums/t_cli_tool.dart';
import 'package:turbo_promptable/turbo_promptable.dart';

export 'package:turbo_promptable/workspace/enums/t_body_type.dart';
export 'package:turbo_promptable/workspace/models/meta/t_meta_data.dart';

abstract class TSpawnable extends TPromptable {
  const TSpawnable(
    String name, {
    required this.id,
    this.allowedTools,
    this.yolo = true,
    this.model,
    this.headless = true,
  }) : super(
         name: name,
       );

  final String id;
  final String? allowedTools;
  final bool yolo;
  final String? model;
  final bool headless;

  String get systemPrompt;

  @mustCallSuper
  String spawn({
    required String prompt,
    required TCliTool cliTool,
    String? conversationId,
  }) => cliTool.spawn(
    request: prompt,
    conversationId: conversationId,
    systemPrompt: systemPrompt,
    allowedTools: allowedTools,
    yolo: yolo,
    model: model,
    headless: headless,
  );
}
