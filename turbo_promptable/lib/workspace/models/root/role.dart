import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:turbo_promptable/core/helpers/t_dart_render_helper.dart';
import 'package:turbo_promptable/spawn/abstracts/t_spawnable.dart';
import 'package:turbo_promptable/spawn/enums/t_cli_tool.dart';
import 'package:turbo_promptable/spawn/enums/t_prompt_delivery.dart';
import 'package:turbo_promptable/turbo_promptable.dart';

part 'role.g.dart';

/// A role that can be assigned to a [Persona] or [Agent], with specific expertise and capabilities.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class Role extends TSpawnable {
  const Role({
    required super.name,
    super.metaData,
    super.config,
    super.cliTool,
    super.command,
    super.promptDelivery,
    required this.expertise,
    this.activities,
    this.checklists,
    this.instructions,
    this.templates,
    this.tools,
    this.workflows,
  });

  final List<Activity>? activities;
  final List<Checklist>? checklists;
  final List<Instruction>? instructions;
  final List<Template>? templates;
  final List<Tool>? tools;
  final List<Workflow>? workflows;
  final String expertise;

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RoleToJson(this);

  Role copyWith({
    String? name,
    TMetaData? metaData,
    TConfig? config,
    String? expertise,
    List<Activity>? activities,
    List<Checklist>? checklists,
    List<Instruction>? instructions,
    List<Template>? templates,
    List<Tool>? tools,
    List<Workflow>? workflows,
  }) => Role(
    name: name ?? this.name,
    metaData: metaData ?? this.metaData,
    config: config ?? this.config,
    expertise: expertise ?? this.expertise,
    activities: activities ?? this.activities,
    checklists: checklists ?? this.checklists,
    instructions: instructions ?? this.instructions,
    templates: templates ?? this.templates,
    tools: tools ?? this.tools,
    workflows: workflows ?? this.workflows,
  );

  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  @override
  String toDart() => wrapStandaloneDartFile(
    variableName: jsonKey,
    expression: toDartInline(includeConst: false),
  );

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// The Dart type name used in rendered constructor calls.
  @protected
  String get dartTypeName => 'Role';

  /// Builds the list of named-argument lines shared across the spawnable
  /// hierarchy (Role → Persona → Agent).
  @protected
  List<String?> buildDartNamedArgs(int indentLevel) => [
    renderStringArg('name', name, indent: indentLevel + 1),
    renderEnumArg(
      'cliTool',
      cliTool,
      enumTypeName: 'TCliTool',
      indent: indentLevel + 1,
    ),
    renderStringArg('command', command, indent: indentLevel + 1),
    renderEnumArg(
      'promptDelivery',
      promptDelivery,
      enumTypeName: 'TPromptDelivery',
      indent: indentLevel + 1,
    ),
    renderStringArg('expertise', expertise, indent: indentLevel + 1),
    renderExpressionListArg(
      'activities',
      activities
          ?.map(
            (a) => a.toDartInline(
              indentLevel: indentLevel + 2,
              includeConst: false,
            ),
          )
          .toList(),
      indent: indentLevel + 1,
    ),
    renderExpressionListArg(
      'checklists',
      checklists
          ?.map(
            (c) => c.toDartInline(
              indentLevel: indentLevel + 2,
              includeConst: false,
            ),
          )
          .toList(),
      indent: indentLevel + 1,
    ),
    renderExpressionListArg(
      'instructions',
      instructions
          ?.map(
            (i) => i.toDartInline(
              indentLevel: indentLevel + 2,
              includeConst: false,
            ),
          )
          .toList(),
      indent: indentLevel + 1,
    ),
    renderExpressionListArg(
      'templates',
      templates
          ?.map(
            (t) => t.toDartInline(
              indentLevel: indentLevel + 2,
              includeConst: false,
            ),
          )
          .toList(),
      indent: indentLevel + 1,
    ),
    renderExpressionListArg(
      'tools',
      tools
          ?.map(
            (t) => t.toDartInline(
              indentLevel: indentLevel + 2,
              includeConst: false,
            ),
          )
          .toList(),
      indent: indentLevel + 1,
    ),
    renderExpressionListArg(
      'workflows',
      workflows
          ?.map(
            (w) => w.toDartInline(
              indentLevel: indentLevel + 2,
              includeConst: false,
            ),
          )
          .toList(),
      indent: indentLevel + 1,
    ),
  ];

  String toDartInline({int indentLevel = 0, bool includeConst = true}) =>
      renderConstructorCall(
        dartTypeName,
        buildDartNamedArgs(indentLevel),
        indentLevel: indentLevel,
        includeConst: includeConst,
      );
}
