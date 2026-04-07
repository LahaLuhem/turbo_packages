import 'dart:convert';

import 'package:turbo_promptable/core/constants/tp_keys.dart';
import 'package:turbo_promptable/core/typedefs/t_body_builder_def.dart';
import 'package:turbo_promptable/workspace/abstracts/meta/t_meta_data.dart';
import 'package:turbo_promptable/workspace/enums/t_body_type.dart';
import 'package:turbo_promptable/workspace/enums/t_ref_type.dart';
import 'package:turbo_promptable/workspace/models/t_embed_type.dart';
import 'package:turbo_promptable/workspace/models/t_render_type.dart';
import 'package:turbo_serializable/extensions/ts_string_extension.dart';
import 'package:turbo_serializable/markdown/factories/t_md_factory.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

export 'package:turbo_promptable/workspace/enums/t_body_type.dart';
export 'package:turbo_promptable/workspace/models/t_render_type.dart';

abstract class TPromptable extends TSerializable {
  const TPromptable({
    required this.name,
    this.description,
    this.inheritNameToMetaData = true,
    this.metaData,
    this.renderType = TRenderType.file,
    this.bodyType = TBodyType.md,
    this.embedType = TEmbedType.body,
    this.emoji,
    this.leadingBody,
    this.bodyBuilder,
    this.trailingBody,
  });

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  final String name;
  final String? description;
  final TRenderType renderType;
  final TEmbedType embedType;
  final String? emoji;
  final TMetaData? metaData;

  final String? leadingBody;
  final TBodyBuilderDef? bodyBuilder;
  final TBodyType bodyType;
  final String? trailingBody;

  final bool inheritNameToMetaData;

  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  @override
  TMdFactory<TWriteable> get mdFactory => TMdFactory<TPromptable>(
    writeable: this,
    mdFrontmatterBuilder: (writeable) => writeable.mdFrontMatter(),
    mdSectionsBuilder: (writeable, frontmatter) => [
      if (writeable.leadingBody != null) writeable.leadingBody!,
      sections(),
      if (writeable.trailingBody != null) writeable.trailingBody!,
    ],
    mdBodyBuilder: (writeable, frontmatter, sections) => sections.join('\n\n'),
    mdFileBuilder: (writeable, frontmatter, sections, body) =>
        '$frontmatter\n\n'
        '$body',
  );

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  String get fileName => '${name.toKebabCase()}.${bodyType.fileExtension}';

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

  Map<String, String> mdFrontMatter() {
    final map = metaData?.toMap() ?? {};
    if (inheritNameToMetaData) {
      map.putIfAbsent(
        TpKeys.name,
        () => name,
      );
      map.putIfAbsent(
        TpKeys.description,
        () => description ?? '',
      );
    }
    return map;
  }

  String sections() {
    final StringBuffer buffer = StringBuffer();
    final sections = bodyBuilder!(this);
    for (int i = 0; i < sections.length; i++) {
      final section = sections[i];
      buffer.writeln(section.title);
      buffer.writeln();
      buffer.writeln(section.body);
      if (i < sections.length - 1) buffer.writeln();
    }
    return buffer.toString();
  }

  String body({
    TBodyType? bodyType,
    bool includeMetaData = false,
  }) {
    switch (bodyType ?? this.bodyType) {
      case TBodyType.md:
        return toMd(
          includeMetaData: includeMetaData,
        );
      case TBodyType.xml:
        return toXml(
          includeMetaData: includeMetaData,
        );
      case TBodyType.yaml:
        return toYaml(
          includeMetaData: includeMetaData,
        );
      case TBodyType.json:
        final json = toJson();
        if (!includeMetaData) json.remove('metaData');
        return const JsonEncoder.withIndent('  ').convert(json);
    }
  }

  @override
  String toString() {
    switch (renderType) {
      case TRenderType.file:
        return body(includeMetaData: true);
      case TRenderType.embed:
        return body(includeMetaData: false);
    }
  }
}
