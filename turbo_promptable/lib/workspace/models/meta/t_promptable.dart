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

part 't_promptable.g.dart';

@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
  createFactory: false,
)
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

  String get fileName => '${name.toKebabCase()}';
  String get xmlKey => '${name.toPascalCase()}';
  String get yamlKey => '${name.toSnakeCase()}';
  String get jsonKey => '${name.toCamelCase()}';

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
