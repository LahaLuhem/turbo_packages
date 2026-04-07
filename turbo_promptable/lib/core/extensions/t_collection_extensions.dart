extension TListExtensionExtension on List {
  String toArrayString() =>
      '[${[
        for (var item in this!) item.toString(),
      ].join(', ')}]';
}

extension TMapExtension on Map {
  String toFrontMatterString() =>
      '---\n${[
        for (var entry in entries) '${entry.key}: ${entry.value}',
      ].join('\n')}\n---';
}
