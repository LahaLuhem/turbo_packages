extension TSStringExtension on String {
  List<String> get _words {
    if (isEmpty) return [];
    return replaceAllMapped(
          RegExp(r'([a-z\d])([A-Z])'),
          (match) => '${match[1]} ${match[2]}',
        )
        .replaceAllMapped(
          RegExp(r'([A-Z]+)([A-Z][a-z])'),
          (match) => '${match[1]} ${match[2]}',
        )
        .replaceAll(RegExp(r'[_\-]+'), ' ')
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  String _capitalize(String word) => word.isEmpty
      ? word
      : word[0].toUpperCase() + word.substring(1).toLowerCase();

  /// Converts to `PascalCase`.
  ///
  /// ```dart
  /// 'hello_world'.toPascalCase(); // 'HelloWorld'
  /// 'some camelCase text'.toPascalCase(); // 'SomeCamelCaseText'
  /// ```
  String toPascalCase() => _words.map(_capitalize).join();

  /// Converts to `snake_case`.
  ///
  /// ```dart
  /// 'HelloWorld'.toSnakeCase(); // 'hello_world'
  /// 'someHTTPResponse'.toSnakeCase(); // 'some_http_response'
  /// ```
  String toSnakeCase() => _words.map((w) => w.toLowerCase()).join('_');

  /// Converts to `kebab-case`.
  ///
  /// ```dart
  /// 'HelloWorld'.toKebabCase(); // 'hello-world'
  /// 'someHTTPResponse'.toKebabCase(); // 'some-http-response'
  /// ```
  String toKebabCase() => _words.map((w) => w.toLowerCase()).join('-');

  /// Converts to `camelCase`.
  ///
  /// ```dart
  /// 'hello_world'.toCamelCase(); // 'helloWorld'
  /// 'PascalCase'.toCamelCase(); // 'pascalCase'
  /// ```
  String toCamelCase() {
    final words = _words;
    if (words.isEmpty) return '';
    return words.first.toLowerCase() + words.skip(1).map(_capitalize).join();
  }

  /// Converts to `lower case` (space-separated, all lowercase).
  ///
  /// Named `toSpacedLowerCase` to avoid shadowing [String.toLowerCase].
  ///
  /// ```dart
  /// 'HelloWorld'.toSpacedLowerCase(); // 'hello world'
  /// 'some_snake_case'.toSpacedLowerCase(); // 'some snake case'
  /// ```
  String toSpacedLowerCase() => _words.map((w) => w.toLowerCase()).join(' ');

  /// Converts to `UPPER CASE` (space-separated, all uppercase).
  ///
  /// Named `toSpacedUpperCase` to avoid shadowing [String.toUpperCase].
  ///
  /// ```dart
  /// 'helloWorld'.toSpacedUpperCase(); // 'HELLO WORLD'
  /// 'some_snake_case'.toSpacedUpperCase(); // 'SOME SNAKE CASE'
  /// ```
  String toSpacedUpperCase() => _words.map((w) => w.toUpperCase()).join(' ');

  /// Converts to `Title Case` (space-separated, each word capitalized).
  ///
  /// ```dart
  /// 'hello_world'.toTitleCase(); // 'Hello World'
  /// 'someHTTPResponse'.toTitleCase(); // 'Some Http Response'
  /// ```
  String toTitleCase() => _words.map(_capitalize).join(' ');
}
