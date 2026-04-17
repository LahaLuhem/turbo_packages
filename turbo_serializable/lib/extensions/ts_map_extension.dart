import 'package:turbo_serializable/constants/ts_defaults.dart';
import 'package:turbo_serializable/extensions/ts_string_extension.dart';
import 'package:turbo_serializable/typedefs/key_value_builder_def.dart';

extension TSMapExtenionExtension on Map {
  String toYaml({
    KeyValueBuilderDef? keyBuilder,
    KeyValueBuilderDef? listItemBuilder,
    int indent = 0,
    bool includeMetaData = true,
    String metaDataKey = TSDefaults.metaDataKey,
  }) {
    if (!includeMetaData) {
      remove(metaDataKey);
    }
    keyBuilder ??= (key, value) => key.toSnakeCase();
    final buffer = StringBuffer();
    final prefix = '  ' * indent;
    for (final entry in entries) {
      final rawKey = entry.key.toString();
      final key = keyBuilder(rawKey, entry.value);
      final value = entry.value;
      if (value is Map) {
        buffer.writeln('$prefix$key:');
        buffer.write(value.toYaml(keyBuilder: keyBuilder, indent: indent + 1));
      } else if (value is List) {
        buffer.writeln('$prefix$key:');
        for (final item in value) {
          if (item is Map) {
            buffer.writeln('$prefix- ');
            buffer.write(
              item.toYaml(keyBuilder: keyBuilder, indent: indent + 2),
            );
          } else {
            buffer.writeln(
              '$prefix${listItemBuilder?.call(rawKey, item) ?? '- $item'}',
            );
          }
        }
      } else if (value == null) {
        buffer.writeln('$prefix$key:');
      } else if (value is String && value.contains('\n')) {
        buffer.writeln('$prefix$key: |');
        for (final line in value.split('\n')) {
          buffer.writeln('$prefix  $line');
        }
      } else if (value is String) {
        buffer.writeln('$prefix$key: "$value"');
      } else {
        buffer.writeln('$prefix$key: $value');
      }
    }
    return buffer.toString();
  }

  String toMd({
    KeyValueBuilderDef? titleBuilder,
    KeyValueBuilderDef? listItemBuilder,
    int headingLevel = 1,
    bool metaDataToFrontMatter = true,
    String emojiKey = TSDefaults.emojiKey,
    String frontMatterKey = TSDefaults.metaDataKey,
    String nameKey = TSDefaults.nameKey,
    String descriptionKey = TSDefaults.descriptionKey,
    String valueKey = TSDefaults.valueKey,
    String valuesKey = TSDefaults.valuesKey,
    String itemsKey = TSDefaults.itemsKey,
  }) {
    final buffer = StringBuffer();
    if (metaDataToFrontMatter && headingLevel == 1) {
      final frontMatter = this[frontMatterKey];
      if (frontMatter is Map && frontMatter.isNotEmpty) {
        buffer.writeln('---');
        buffer.write(frontMatter.toYaml());
        buffer.writeln('---');
        buffer.writeln();
      }
      remove(frontMatterKey);
    }
    final headingPrefix = '#' * headingLevel;
    for (final entry in entries) {
      final key = entry.key.toString();
      final value = entry.value;
      if (value is Map) {
        final title = _mdTitle(
          emojiKey: emojiKey,
          nameKey: nameKey,
          map: value,
        );
        buffer.writeln('$headingPrefix $title');
        buffer.writeln();
        final remaining = Map.of(value)
          ..remove(nameKey)
          ..remove(emojiKey);
        _writeWellKnownBody(
          buffer: buffer,
          remaining: remaining,
          descriptionKey: descriptionKey,
          valueKey: valueKey,
          valuesKey: valuesKey,
          itemsKey: itemsKey,
          listItemBuilder: listItemBuilder,
        );
        if (remaining.isNotEmpty) {
          buffer.write(
            remaining.toMd(
              titleBuilder: titleBuilder,
              listItemBuilder: listItemBuilder,
              headingLevel: headingLevel + 1,
              metaDataToFrontMatter: metaDataToFrontMatter,
              emojiKey: emojiKey,
              frontMatterKey: frontMatterKey,
              nameKey: nameKey,
              descriptionKey: descriptionKey,
              valueKey: valueKey,
              valuesKey: valuesKey,
              itemsKey: itemsKey,
            ),
          );
        }
      } else if (value is List) {
        buffer.writeln('$headingPrefix ${key.toTitleCase()}');
        buffer.writeln();
        for (final item in value) {
          if (item is Map) {
            buffer.write(
              item.toMd(
                titleBuilder: titleBuilder,
                listItemBuilder: listItemBuilder,
                headingLevel: headingLevel + 1,
                metaDataToFrontMatter: metaDataToFrontMatter,
                emojiKey: emojiKey,
                frontMatterKey: frontMatterKey,
                nameKey: nameKey,
                descriptionKey: descriptionKey,
                valueKey: valueKey,
                valuesKey: valuesKey,
                itemsKey: itemsKey,
              ),
            );
          } else {
            buffer.writeln(listItemBuilder?.call(key, item) ?? '- $item');
          }
        }
        buffer.writeln();
      } else if (value == null) {
        buffer.writeln('$headingPrefix ${key.toTitleCase()}');
        buffer.writeln();
      } else {
        buffer.writeln('$headingPrefix ${key.toTitleCase()}');
        buffer.writeln();
        buffer.writeln(value);
        buffer.writeln();
      }
    }
    return buffer.toString();
  }

  void _writeWellKnownBody({
    required StringBuffer buffer,
    required Map remaining,
    required String descriptionKey,
    required String valueKey,
    required String valuesKey,
    required String itemsKey,
    required KeyValueBuilderDef? listItemBuilder,
  }) {
    final description = remaining.remove(descriptionKey);
    if (description != null) {
      for (final line in description.toString().split('\n')) {
        buffer.writeln('> $line');
      }
      buffer.writeln();
    }
    final value = remaining.remove(valueKey);
    if (value != null) {
      buffer.writeln(value);
      buffer.writeln();
    }
    final values = remaining.remove(valuesKey);
    if (values is Iterable) {
      for (final entry in values) {
        buffer.writeln(entry);
        buffer.writeln();
      }
    }
    final items = remaining.remove(itemsKey);
    if (items is Iterable) {
      for (final item in items) {
        buffer.writeln(listItemBuilder?.call(itemsKey, item) ?? '- $item');
      }
      buffer.writeln();
    }
  }

  String _mdTitle({
    required Map map,
    required String nameKey,
    required String emojiKey,
  }) {
    final name = map[nameKey];
    final emoji = map[emojiKey];
    final title = name?.toString().toTitleCase();
    if (emoji != null) return '$emoji $title';
    return title ?? '';
  }

  String toXml({
    KeyValueBuilderDef? keyBuilder,
    KeyValueBuilderDef? listItemBuilder,
    int indent = 0,
    bool includeMetaData = true,
    String metaDataKey = TSDefaults.metaDataKey,
  }) {
    if (!includeMetaData) {
      remove(metaDataKey);
    }
    keyBuilder ??= (key, value) => key.toPascalCase();
    final buffer = StringBuffer();
    final prefix = '  ' * indent;
    for (final entry in entries) {
      final rawKey = entry.key.toString();
      final key = keyBuilder(rawKey, entry.value);
      final value = entry.value;
      if (value is Map) {
        buffer.writeln('$prefix<$key>');
        buffer.write(
          value.toXml(
            keyBuilder: keyBuilder,
            listItemBuilder: listItemBuilder,
            indent: indent + 1,
            includeMetaData: includeMetaData,
            metaDataKey: metaDataKey,
          ),
        );
        buffer.writeln('$prefix</$key>');
      } else if (value is List) {
        buffer.writeln('$prefix<$key>');
        for (final item in value) {
          if (item is Map) {
            buffer.write(
              item.toXml(
                keyBuilder: keyBuilder,
                listItemBuilder: listItemBuilder,
                indent: indent + 2,
                includeMetaData: includeMetaData,
                metaDataKey: metaDataKey,
              ),
            );
          } else {
            buffer.writeln(
              '$prefix  ${listItemBuilder?.call(rawKey, item) ?? '- $item'}',
            );
          }
        }
        buffer.writeln('$prefix</$key>');
      } else if (value == null) {
        buffer.writeln('$prefix<$key/>');
      } else {
        buffer.writeln('$prefix<$key>$value</$key>');
      }
    }
    return buffer.toString();
  }
}
