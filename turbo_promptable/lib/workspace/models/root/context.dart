import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/core/helpers/t_dart_render_helper.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

export 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

part 'context.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Context extends TPromptable {
  const Context({
    required super.name,
    super.metaData,
    super.config,
  });

  factory Context.fromJson(Map<String, dynamic> json) =>
      _$ContextFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ContextToJson(this);

  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  @override
  String toDart() => toDartInline();

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  String toDartInline({int indentLevel = 0, bool includeConst = true}) =>
      renderConstructorCall(
        'Context',
        [renderStringArg('name', name, indent: indentLevel + 1)],
        indentLevel: indentLevel,
        includeConst: includeConst,
      );
}
