import 'dart:convert';

import 'package:turbo_promptable/core/typedefs/body_builder.dart';
import 'package:turbo_promptable/workspace/abstracts/meta/t_meta_data.dart';
import 'package:turbo_promptable/workspace/enums/t_body_type.dart';
import 'package:turbo_promptable/workspace/enums/t_ref_type.dart';
import 'package:turbo_serializable/extensions/ts_map_extenion.dart';
import 'package:turbo_serializable/extensions/ts_string_extenion.dart';
import 'package:turbo_serializable/markdown/factories/t_md_factory.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

abstract class TPromptable extends TSerializable {
  const TPromptable({
    required this.name,
    this.bodyType = TBodyType.md,
    this.emoji,
    this.leadingBody,
    this.mdSectionsBuilder,
    this.metaData,
    this.trailingBody,
  });

  final String name;
  final String? emoji;
  final TMetaData? metaData;

  final String? leadingBody;
  final TMdSectionsBuilder? mdSectionsBuilder;
  final TBodyType bodyType;
  final String? trailingBody;

  String title({bool withEmoji = true}) => withEmoji && emoji != null
      ? '$emoji '
      : ''
            '${name.toTitleCase()}';

  String get xmlKey => '${name.toPascalCase()}';
  String get yamlKey => '${name.toSnakeCase()}';
  String get jsonKey => '${name.toCamelCase()}';

  String ref({
    String? openRef,
    String? closeRef,
    TBodyType? bodyType,
  }) =>
      '${openRef ?? TRefType.curlyBraces.openDouble}'
      ' ${switch (bodyType ?? this.bodyType) {
        TBodyType.md => title,
        TBodyType.xml => xmlKey,
        TBodyType.yaml => yamlKey,
        TBodyType.json => jsonKey,
      }} '
      '${closeRef ?? TRefType.curlyBraces.closeDouble}';

  Map<String, String> mdFrontMatter() => metaData?.toMap() ?? {};

  String mdSections() {
    if (mdSectionsBuilder == null) {
      return toJson().toMd();
    } else {
      final StringBuffer buffer = StringBuffer();
      final sections = mdSectionsBuilder!(this);
      for (final section in sections) {
        buffer.writeln(section.title);
        buffer.writeln();
        buffer.writeln(section.body);
        buffer.writeln();
      }
      return buffer.toString();
    }
  }

  String toFileContent({TBodyType? bodyType}) {
    switch (bodyType ?? this.bodyType) {
      case TBodyType.md:
        return toMarkdown();
      case TBodyType.xml:
        return toXml();
      case TBodyType.yaml:
        return toYaml();
      case TBodyType.json:
        return jsonEncode(toJson());
    }
  }

  @override
  TMdFactory<TWriteable> get mdFactory => TMdFactory<TPromptable>(
    writeable: this,
    mdFrontmatterBuilder: (writeable) => writeable.mdFrontMatter(),
    mdSectionsBuilder: (writeable, frontmatter) => [
      if (writeable.leadingBody != null) writeable.leadingBody!,
      mdSections(),
      if (writeable.trailingBody != null) writeable.trailingBody!,
    ],
    mdBodyBuilder: (writeable, frontmatter, sections) => sections.join('\n\n'),
    mdFileBuilder: (writeable, frontmatter, sections, body) =>
        '$frontmatter\n\n'
        '$body',
  );
}
