import 'package:turbo_serializable/abstracts/t_writeable.dart';
import 'package:turbo_serializable/markdown/typedefs/t_markdown_typedefs.dart';

class TMdFactory<T extends TWriteable> {
  final T writeable;

  final TMdFrontmatterBuilder<T>? mdFrontmatterBuilder;
  final TMdSectionsBuilder<T>? mdSectionsBuilder;
  final TMdBodyBuilder<T>? mdBodyBuilder;
  final TMdFileBuilder<T>? mdFileBuilder;

  TMdFactory({
    required this.writeable,
    this.mdFrontmatterBuilder,
    this.mdSectionsBuilder,
    this.mdBodyBuilder,
    this.mdFileBuilder,
  });

  TMdFrontmatter buildFrontmatter({
    TMdFrontmatterBuilder? mdFrontmatterBuilder,
  }) =>
      (mdFrontmatterBuilder ?? this.mdFrontmatterBuilder)?.call(writeable) ??
      {};

  List<TMdSection> buildSections({
    TMdSectionsBuilder? mdSectionsBuilder,
  }) =>
      (mdSectionsBuilder ?? this.mdSectionsBuilder)?.call(
        writeable,
        buildFrontmatter(),
      ) ??
      [];

  TMdBody buildBody({
    TMdBodyBuilder? mdBodyBuilder,
  }) =>
      (mdBodyBuilder ?? this.mdBodyBuilder)?.call(
        writeable,
        buildFrontmatter(),
        buildSections(),
      ) ??
      '';

  TMdFile build({
    TMdFileBuilder? mdBuilder,
  }) =>
      (mdBuilder ?? this.mdFileBuilder)?.call(
        writeable,
        buildFrontmatter(),
        buildSections(),
        buildBody(),
      ) ??
      '';
}
