import 'package:turbo_promptable/core/typedefs/body_builder.dart';
import 'package:turbo_promptable/workspace/abstracts/meta/t_meta_data.dart';
import 'package:turbo_serializable/markdown/factories/t_md_factory.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

abstract class TPromptable extends TSerializable {
  const TPromptable({
    required this.id,
    this.leadingBody,
    this.trailingBody,
    this.metaData,
    required this.bodyBuilder,
  });

  final String id;
  final TMetaData? metaData;

  final String? leadingBody;
  final TBodyBuilder bodyBuilder;
  final String? trailingBody;

  String get xmlTag => '<$id>';
  String get yamlKey => '$id';
  String get jsonKey => '$id';
  String get ref => '{{ $id }}';

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
