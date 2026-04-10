import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/core/constants/tp_keys.dart';
import 'package:turbo_promptable/core/models/t_config.dart';
import 'package:turbo_promptable/workspace/models/meta/t_meta_data.dart';
import 'package:turbo_serializable/extensions/ts_map_extenion.dart';
import 'package:turbo_serializable/extensions/ts_string_extension.dart';
import 'package:turbo_serializable/markdown/factories/t_md_factory.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

export 'package:turbo_promptable/core/models/t_render_type.dart';
export 'package:turbo_promptable/workspace/enums/t_body_type.dart';

/// Base class for all promptable models in the workspace.
///
/// Provides a [name], optional [metaData] (frontmatter), and optional
/// [config] for controlling serialization and body rendering. Subclasses
/// represent domain concepts (roles, agents, workflows, etc.) that can be
/// serialized to Markdown, YAML, XML, or JSON via the turbo_serializable
/// infrastructure.
abstract class TPromptable extends TSerializable {
  const TPromptable({
    required this.name,
    this.config,
    this.metaData,
  });

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  final String name;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final TMetaData? metaData;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final TConfig? config;

  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  @override
  TMdFactory<TWriteable> get mdFactory => TMdFactory<TPromptable>(
    writeable: this,
    mdFrontmatterBuilder: (writeable) => writeable.mdFrontMatter(),
    mdSectionsBuilder: (writeable, frontmatter) => [
      if (writeable.config?.leadingBody != null) writeable.config!.leadingBody!,
      mdBody() ?? toJson().toMd(includeMetaData: false),
      if (writeable.config?.trailingBody != null)
        writeable.config!.trailingBody!,
    ],
    mdBodyBuilder: (writeable, frontmatter, sections) => sections.join('\n\n'),
    mdFileBuilder: (writeable, frontmatter, sections, body) =>
        '$frontmatter\n\n'
        '$body',
  );

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// The kebab-case file name derived from [name].
  String get fileName => '${name.toKebabCase()}';

  /// The PascalCase key used for XML serialization.
  String get xmlKey => '${name.toPascalCase()}';

  /// The snake_case key used for YAML serialization.
  String get yamlKey => '${name.toSnakeCase()}';

  /// The camelCase key used for JSON serialization.
  String get jsonKey => '${name.toCamelCase()}';

  /// Builds the Markdown frontmatter map from [metaData].
  Map<String, dynamic> mdFrontMatter() {
    final map = metaData?.toJson() ?? {};
    if (config?.inheritMetaData ?? false) {
      map.putIfAbsent(
        TpKeys.name,
        () => name,
      );
      final description = metaData?.description;
      if (description != null && description.isNotEmpty) {
        map.putIfAbsent(
          TpKeys.description,
          () {
            return description;
          },
        );
      }
    }
    return map;
  }

  String? mdBody() {
    final sections = config?.bodyBuilder!(this);
    if (sections == null || sections.isEmpty) return null;
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < sections.length; i++) {
      final section = sections[i];
      buffer.writeln(section.title);
      buffer.writeln();
      buffer.writeln(section.body);
      if (i < sections.length - 1) buffer.writeln();
    }
    return buffer.toString();
  }
}
