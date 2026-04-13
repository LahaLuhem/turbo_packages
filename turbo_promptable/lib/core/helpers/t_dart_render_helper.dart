import 'package:turbo_promptable/core/helpers/t_dart_string_helper.dart';

/// Pure helper functions for rendering Dart source fragments.
///
/// Used internally by entity `toDart()` / `toDartInline()` implementations.
/// Not exported from the package barrel.

// ---------------------------------------------------------------------------
// Named arguments
// ---------------------------------------------------------------------------

/// Renders a named argument for a string value.
///
/// Returns `null` when [value] is `null`.
String? renderStringArg(String name, String? value, {required int indent}) {
  if (value == null) return null;
  final prefix = _indent(indent);
  return '$prefix$name: ${renderDartStringLiteral(value)},';
}

/// Renders a named argument for a bool value.
///
/// Returns `null` when [value] is `null`.
String? renderBoolArg(String name, bool? value, {required int indent}) {
  if (value == null) return null;
  final prefix = _indent(indent);
  return '$prefix$name: $value,';
}

/// Renders a named argument for an enum value using `EnumType.valueName`.
///
/// Returns `null` when [value] is `null`.
String? renderEnumArg(
  String name,
  Enum? value, {
  required String enumTypeName,
  required int indent,
}) {
  if (value == null) return null;
  final prefix = _indent(indent);
  return '$prefix$name: $enumTypeName.${value.name},';
}

/// Renders a named argument whose value is an already-rendered inline
/// expression (e.g. a nested constructor call).
///
/// Returns `null` when [expression] is `null`.
/// Strips leading whitespace from [expression] so the `name:` prefix
/// provides the correct indentation on the first line.
String? renderExpressionArg(
  String name,
  String? expression, {
  required int indent,
}) {
  if (expression == null) return null;
  final prefix = _indent(indent);
  return '$prefix$name: ${expression.trimLeft()},';
}

// ---------------------------------------------------------------------------
// List rendering
// ---------------------------------------------------------------------------

/// Renders a named argument whose value is a `const` list of string literals.
///
/// Returns `null` when [items] is `null` or empty.
String? renderStringListArg(
  String name,
  List<String>? items, {
  required int indent,
}) {
  if (items == null || items.isEmpty) return null;
  final prefix = _indent(indent);
  final itemIndent = _indent(indent + 1);
  final buffer = StringBuffer();
  buffer.writeln('$prefix$name: const [');
  for (final item in items) {
    buffer.writeln('$itemIndent${renderDartStringLiteral(item)},');
  }
  buffer.write('$prefix],');
  return buffer.toString();
}

/// Renders a named argument whose value is a `const` list of pre-rendered
/// inline constructor expressions.
///
/// Returns `null` when [expressions] is `null` or empty.
String? renderExpressionListArg(
  String name,
  List<String>? expressions, {
  required int indent,
}) {
  if (expressions == null || expressions.isEmpty) return null;
  final prefix = _indent(indent);
  final itemIndent = _indent(indent + 1);
  final buffer = StringBuffer();
  buffer.writeln('$prefix$name: const [');
  for (final expr in expressions) {
    // The expression may already have indentation from renderConstructorCall;
    // strip leading whitespace so itemIndent provides consistent positioning.
    final trimmed = expr.trimLeft();
    final lines = trimmed.split('\n');
    for (int i = 0; i < lines.length; i++) {
      if (i == 0) {
        buffer.writeln('$itemIndent$trimmed'.split('\n').first);
      } else {
        buffer.writeln('$itemIndent${lines[i].trimLeft()}');
      }
    }
  }
  buffer.write('$prefix],');
  return buffer.toString();
}

// ---------------------------------------------------------------------------
// Constructor call
// ---------------------------------------------------------------------------

/// Builds a multiline constructor call from a type name and a list of
/// already-rendered named-argument lines.
///
/// [namedArgs] may contain `null` entries — they are filtered out.
/// Set [includeConst] to `false` when the caller already provides `const`
/// (e.g. inside a `const [...]` list or a `const =` declaration).
String renderConstructorCall(
  String typeName,
  List<String?> namedArgs, {
  int indentLevel = 0,
  bool includeConst = true,
}) {
  final prefix = _indent(indentLevel);
  final constPrefix = includeConst ? 'const ' : '';
  final filtered = namedArgs.whereType<String>().toList();
  if (filtered.isEmpty) {
    return '$prefix$constPrefix$typeName()';
  }
  final buffer = StringBuffer();
  buffer.writeln('$prefix$constPrefix$typeName(');
  for (final arg in filtered) {
    buffer.writeln(arg);
  }
  buffer.write('$prefix)');
  return buffer.toString();
}

// ---------------------------------------------------------------------------
// Standalone file wrapper
// ---------------------------------------------------------------------------

/// Wraps a constructor [expression] in a complete standalone `.dart` file
/// with the standard turbo_promptable import and a top-level `const` variable.
///
/// [variableName] should be camelCase (typically from `TPromptable.jsonKey`).
/// [expression] should NOT include a leading `const` — the variable
/// declaration provides it.
String wrapStandaloneDartFile({
  required String variableName,
  required String expression,
}) =>
    "import 'package:turbo_promptable/turbo_promptable.dart';\n"
    '\n'
    'const $variableName = $expression;\n';

// ---------------------------------------------------------------------------
// Internal
// ---------------------------------------------------------------------------

String _indent(int level) => '  ' * level;
