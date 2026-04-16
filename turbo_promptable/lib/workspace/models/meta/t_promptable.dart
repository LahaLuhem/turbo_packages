import 'package:json_annotation/json_annotation.dart';
import 'package:turbo_promptable/workspace/models/meta/t_meta_data.dart';
import 'package:turbo_serializable/extensions/ts_map_extenion.dart';
import 'package:turbo_serializable/extensions/ts_string_extension.dart';
import 'package:turbo_serializable/markdown/factories/t_md_factory.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

export 'package:turbo_promptable/core/models/t_render_type.dart';
export 'package:turbo_promptable/workspace/enums/t_body_type.dart';

@JsonSerializable(
  createFactory: false,
  createToJson: false,
)
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
    this.metaData,
  });

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  final String name;

  final TMetaData? metaData;

  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  @override
  TMdFactory<TWriteable> get mdFactory => TMdFactory<TPromptable>(
    writeable: this,
    mdFrontmatterBuilder: (writeable) => writeable.mdFrontMatter(),
    mdSectionsBuilder: (writeable, frontmatter) => [
      mdBody() ?? ,
    ],
    mdBodyBuilder: (writeable, frontmatter, sections) => sections.join('\n\n'),
    mdFileBuilder: (writeable, frontmatter, sections, body) =>
        '$frontmatter\n\n'
        '$body',
  );

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  String get fileName => '${name.toKebabCase()}';
  String get xmlKey => '${name.toPascalCase()}';
  String get yamlKey => '${name.toSnakeCase()}';
  String get jsonKey => '${name.toCamelCase()}';

  Map<String, dynamic> mdFrontMatter() => metaData?.toJson() ?? {};
}
