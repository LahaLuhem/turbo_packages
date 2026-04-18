import 'package:meta/meta.dart';
import 'package:turbo_promptable/spawn/enums/t_cli_tool.dart';
import 'package:turbo_promptable/spawn/enums/t_config_source.dart';
import 'package:turbo_serializable/abstracts/t_writeable.dart';

export 'package:turbo_promptable/workspace/enums/t_body_type.dart';
export 'package:turbo_promptable/workspace/models/meta/t_meta_data.dart';

abstract class TSpawnable extends TWriteable {
  const TSpawnable({
    required this.cliTool,
    this.tools,
    this.yolo = true,
    this.model,
    this.headless = true,
    this.mcpsConfigSource = ConfigSource.none,
  });

  final String? tools;
  final bool yolo;
  final String? model;
  final bool headless;
  final ConfigSource mcpsConfigSource;
  final TCliTool cliTool;

  @mustCallSuper
  String spawn({
    required String prompt,
    String? conversationId,
  });
}
