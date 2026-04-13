import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/core/helpers/t_dart_render_helper.dart';
import 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

export 'package:turbo_promptable/workspace/models/meta/t_promptable.dart';

part 'checklist.g.dart';

/// A named list of string [items] used for acceptance criteria, constraints, etc.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Checklist extends TPromptable {
  const Checklist({
    required super.name,
    super.config,
    super.metaData,
    required this.items,
  });

  final List<String> items;

  factory Checklist.fromJson(Map<String, dynamic> json) =>
      _$ChecklistFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ChecklistToJson(this);

  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  @override
  String toDart() => wrapStandaloneDartFile(
    variableName: jsonKey,
    expression: toDartInline(includeConst: false),
  );

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  String toDartInline({int indentLevel = 0, bool includeConst = true}) =>
      renderConstructorCall(
        'Checklist',
        [
          renderStringArg('name', name, indent: indentLevel + 1),
          renderStringListArg('items', items, indent: indentLevel + 1),
        ],
        indentLevel: indentLevel,
        includeConst: includeConst,
      );
}
