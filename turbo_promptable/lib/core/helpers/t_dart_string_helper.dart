/// Pure helper functions for escaping and quoting Dart string literals.
///
/// Used internally by entity `toDart()` / `toDartInline()` implementations.
/// Not exported from the package barrel.

/// Escapes special characters in [value] for use inside a single-quoted
/// Dart string literal.
///
/// Handles: backslash, single quote, dollar sign, and newline characters.
String escapeDartString(String value) => value
    .replaceAll(r'\', r'\\')
    .replaceAll("'", r"\'")
    .replaceAll(r'$', r'\$')
    .replaceAll('\n', r'\n')
    .replaceAll('\r', r'\r')
    .replaceAll('\t', r'\t');

/// Returns [value] as a single-quoted Dart string literal with proper escaping.
String renderDartStringLiteral(String value) => "'${escapeDartString(value)}'";
