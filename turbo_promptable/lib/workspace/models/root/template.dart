import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/core/helpers/t_dart_render_helper.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

part 'template.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Template extends TPromptable {
  const Template({
    required super.name,
    super.metaData,
    super.config,
  });

  factory Template.fromJson(Map<String, dynamic> json) =>
      _$TemplateFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TemplateToJson(this);

  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  @override
  String toDart() => wrapStandaloneDartFile(
    variableName: jsonKey,
    expression: toDartInline(includeConst: false),
  );

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  String toDartInline({int indentLevel = 0, bool includeConst = true}) =>
      renderConstructorCall(
        'Template',
        [renderStringArg('name', name, indent: indentLevel + 1)],
        indentLevel: indentLevel,
        includeConst: includeConst,
      );
}
