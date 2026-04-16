import 'package:turbo_serializable/abstracts/t_writeable.dart';
import 'package:turbo_serializable/markdown/typedefs/t_markdown_typedefs.dart';

class TMdFactory<T extends TWriteable> {
  final T writeable;

  final TMdFrontmatterBuilder<T>? mdFrontmatterBuilder;
  final TMdBodyBuilder<T>? mdBodyBuilder;
  final TMdFileBuilder<T>? mdBuilder;

  TMdFactory({
    required this.writeable,
    this.mdFrontmatterBuilder,
    this.mdBodyBuilder,
    this.mdBuilder,
  });

  TMdFrontmatter buildFrontmatter({
    TMdFrontmatterBuilder? mdFrontmatterBuilder,
  }) =>
      (mdFrontmatterBuilder ?? this.mdFrontmatterBuilder)?.call(writeable) ??
      {};

  TMdBody buildBody({
    TMdBodyBuilder? mdBodyBuilder,
  }) =>
      (mdBodyBuilder ?? this.mdBodyBuilder)?.call(
        writeable,
        buildFrontmatter(),
      ) ??
      '';

  TMdFile build({
    TMdFileBuilder? mdBuilder,
  }) =>
      (mdBuilder ?? this.mdBuilder)?.call(
        writeable,
        buildFrontmatter(),
        buildBody(),
      ) ??
      '';
}
