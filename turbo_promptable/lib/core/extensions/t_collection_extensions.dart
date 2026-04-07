extension TPListExtensionExtension on List {
  String toArrayString() =>
      '[${[
        for (var item in this) item.toString(),
      ].join(', ')}]';
}
