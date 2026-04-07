import 'package:turbo_serializable/extensions/ts_string_extenion.dart';
import 'package:turbo_serializable/typedefs/key_builder_def.dart';

extension TSMapExtenionExtension on Map {

  String toYaml({KeyBuilderDef? keyBuilder, int indent = 0}) {
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

  String toXml({KeyBuilderDef? keyBuilder, int indent = 0}) {
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
