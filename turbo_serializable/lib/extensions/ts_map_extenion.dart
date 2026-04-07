import 'package:turbo_serializable/extensions/ts_string_extension.dart';
import 'package:turbo_serializable/typedefs/key_builder_def.dart';

extension TSMapExtenionExtension on Map {
  String toYaml({
    KeyBuilderDef? keyBuilder,
    int indent = 0,
    bool includeMetaData = true,
  }) {
    if (!includeMetaData) {
      remove('metaData');
    }
    keyBuilder ??= (key) => key.toSnakeCase();
    final buffer = StringBuffer();
    final prefix = '  ' * indent;
    for (final entry in entries) {
      final key = keyBuilder(entry.key.toString());
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
            buffer.writeln('$prefix- $item');
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
    KeyBuilderDef? keyBuilder,
    int headingLevel = 1,
    bool includeMetaData = true,
  }) {
    keyBuilder ??= (key) => key;
    final buffer = StringBuffer();
    if (includeMetaData && headingLevel == 1) {
      final metaData = this['metaData'];
      if (metaData is Map && metaData.isNotEmpty) {
        buffer.writeln('---');
        buffer.write(metaData.toYaml());
        buffer.writeln('---');
        buffer.writeln();
      }
    } else {
      remove('metaData');
    }
    final headingPrefix = '#' * headingLevel;
    for (final entry in entries) {
      final key = keyBuilder(entry.key.toString());
      final value = entry.value;
      if (entry.key == 'metaData' && headingLevel == 1) {
        continue;
      } else if (value is Map) {
        final title = _mdTitle(key, value);
        buffer.writeln('$headingPrefix $title');
        buffer.writeln();
        final remaining = Map.of(value)
          ..remove('name')
          ..remove('emoji');
        if (remaining.isNotEmpty) {
          buffer.write(
            remaining.toMd(
              keyBuilder: keyBuilder,
              headingLevel: headingLevel + 1,
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
                keyBuilder: keyBuilder,
                headingLevel: headingLevel + 1,
              ),
            );
          } else {
            buffer.writeln('- $item');
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

  String _mdTitle(String fallback, Map map) {
    final name = map['name'];
    final emoji = map['emoji'];
    final title = name != null ? name.toString().toTitleCase() : fallback.toTitleCase();
    if (emoji != null) return '$emoji $title';
    return title;
  }

  String toXml({
    KeyBuilderDef? keyBuilder,
    int indent = 0,
    bool includeMetaData = true,
  }) {
    if (!includeMetaData) {
      remove('metaData');
    }
    keyBuilder ??= (key) => key.toPascalCase();
    final buffer = StringBuffer();
    final prefix = '  ' * indent;
    for (final entry in entries) {
      final key = keyBuilder(entry.key.toString());
      final value = entry.value;
      if (value is Map) {
        buffer.writeln('$prefix<$key>');
        buffer.write(value.toXml(keyBuilder: keyBuilder, indent: indent + 1));
        buffer.writeln('$prefix</$key>');
      } else if (value is List) {
        buffer.writeln('$prefix<$key>');
        for (final item in value) {
          if (item is Map) {
            buffer.writeln('$prefix  <Item>');
            buffer.write(
              item.toXml(keyBuilder: keyBuilder, indent: indent + 2),
            );
            buffer.writeln('$prefix  </Item>');
          } else {
            buffer.writeln('$prefix  <Item>$item</Item>');
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
