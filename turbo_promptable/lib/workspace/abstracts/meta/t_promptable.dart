import 'dart:convert';

import 'package:turbo_promptable/core/typedefs/body_builder.dart';
import 'package:turbo_promptable/workspace/abstracts/meta/t_meta_data.dart';
import 'package:turbo_promptable/workspace/enums/t_body_type.dart';
import 'package:turbo_serializable/extensions/ts_string_extenion.dart';
import 'package:turbo_serializable/markdown/factories/t_md_factory.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

abstract class TPromptable extends TSerializable {
  const TPromptable({
    required this.id,
    this.emoji,
    this.leadingBody,
    this.trailingBody,
    this.metaData,
    required this.bodyBuilder,
    required this.bodyType,
  });

  final String id;
  final String? emoji;
  final TMetaData? metaData;

  final String? leadingBody;
  final TBodyBuilder bodyBuilder;
  final TBodyType bodyType;
  final String? trailingBody;

  String get mdTitle => '${emoji ?? ''} ${id.toTitleCase()}';
  String get xmlKey => '${id.toPascalCase()}';
  String get yamlKey => '${id.toSnakeCase()}';
  String get jsonKey => '${id.toCamelCase()}';
  String ref({TBodyType? bodyType}) =>
      '{{ ${switch (bodyType ?? this.bodyType) {
        TBodyType.md => mdTitle,
        TBodyType.xml => xmlKey,
        TBodyType.yaml => yamlKey,
        TBodyType.json => jsonKey,
      }} }}';

  String toPrompt() {
    switch (bodyType) {
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
    mdFrontmatterBuilder: (writeable) => writeable.metaData?.toMap() ?? {},
    mdSectionsBuilder: (writeable, frontmatter) => [
      if (writeable.leadingBody != null) writeable.leadingBody!,
      for (final body in bodyBuilder(this)) body,
      if (writeable.trailingBody != null) writeable.trailingBody!,
    ],
    mdBodyBuilder: (writeable, frontmatter, sections) => sections.join('\n\n'),
    mdFileBuilder: (writeable, frontmatter, sections, body) =>
        '$frontmatter\n\n'
        '$body',
  );
}
