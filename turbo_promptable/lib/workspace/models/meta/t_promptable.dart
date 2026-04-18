import 'package:turbo_promptable/workspace/enums/t_body_type.dart';
import 'package:turbo_promptable/workspace/enums/t_ref_type.dart';
import 'package:turbo_promptable/workspace/models/meta/t_meta_data.dart';
import 'package:turbo_serializable/constants/ts_defaults.dart';
import 'package:turbo_serializable/turbo_serializable.dart';

export 'package:turbo_promptable/workspace/enums/t_body_type.dart';
export 'package:turbo_promptable/workspace/models/meta/t_meta_data.dart';

abstract class TPromptable extends TSerializable {
  const TPromptable({
    required this.name,
    this.description,
    this.metaData,
    this.cascadeNameToMetaData = true,
    this.cascadeDescriptionToMetaData = true,
    this.values,
    this.value,
  });

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  final String name;
  final String? description;
  final String? value;
  final List<String>? values;
  final bool cascadeNameToMetaData;
  final bool cascadeDescriptionToMetaData;
  final TMetaData? metaData;

  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  @override
  TMdFactory<TWriteable> get mdFactory => TMdFactory<TPromptable>(
    writeable: this,
    mdFrontmatterBuilder: (writeable) => writeable.mdFrontMatter(),
    mdBodyBuilder: (writeable, _) {
      final json = Map<String, dynamic>.from(writeable.toJson())..remove(TSDefaults.metaDataKey);
      return json.toMd(
        metaDataToFrontMatter: false,
        headingLevel: 2,
        listItemBuilder: (key, item) => key == TSDefaults.itemsKey ? '- [ ] $item' : null,
      );
    },
    mdBuilder: (writeable, frontmatter, body) =>
        '$frontmatter\n\n'
        '$body',
  );

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  String get fileName => '${name.toKebabCase()}';
  String get xmlKey => '${name.toPascalCase()}';
  String get yamlKey => '${name.toSnakeCase()}';
  String get jsonKey => '${name.toCamelCase()}';

  Map<String, dynamic> mdFrontMatter() {
    final frontMatter = <String, dynamic>{};
    if (cascadeNameToMetaData && name.isNotEmpty) {
      frontMatter['name'] = name;
    }
    if (cascadeDescriptionToMetaData && description != null && description!.isNotEmpty) {
      frontMatter['description'] = description;
    }
    if (metaData != null) {
      frontMatter.addAll(metaData!.toJson());
    }
    return frontMatter;
  }

  String ref({
    String? openRef,
    String? closeRef,
    required TBodyType bodyType,
  }) =>
      '${openRef ?? TRefType.curlyBraces.openDouble}'
          ' ${switch (bodyType) {
        TBodyType.md => name,
        TBodyType.xml => xmlKey,
        TBodyType.yaml => yamlKey,
        TBodyType.json => jsonKey,
      }} '
          '${closeRef ?? TRefType.curlyBraces.closeDouble}';

  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\

  String refMd({
    String? openRef,
    String? closeRef,
  }) => ref(
    bodyType: TBodyType.md,
    openRef: openRef,
    closeRef: closeRef,
  );

  String refXml({
    String? openRef,
    String? closeRef,
  }) => ref(
    bodyType: TBodyType.xml,
    openRef: openRef,
    closeRef: closeRef,
  );

  String refYaml({
    String? openRef,
    String? closeRef,
  }) => ref(
    bodyType: TBodyType.yaml,
    openRef: openRef,
    closeRef: closeRef,
  );

  String refJson({
    String? openRef,
    String? closeRef,
  }) => ref(
    bodyType: TBodyType.json,
    openRef: openRef,
    closeRef: closeRef,
  );

}
