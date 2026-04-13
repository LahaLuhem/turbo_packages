import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/core/helpers/t_dart_render_helper.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

export 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

part 'tool.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Tool extends TPromptable {
  const Tool({
    required super.name,
    super.metaData,
    super.config,
  });

  factory Tool.fromJson(Map<String, dynamic> json) => _$ToolFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ToolToJson(this);

  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  @override
  String toDart() => wrapStandaloneDartFile(
    variableName: jsonKey,
    expression: toDartInline(includeConst: false),
  );

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  String toDartInline({int indentLevel = 0, bool includeConst = true}) =>
      renderConstructorCall(
        'Tool',
        [renderStringArg('name', name, indent: indentLevel + 1)],
        indentLevel: indentLevel,
        includeConst: includeConst,
      );
}
