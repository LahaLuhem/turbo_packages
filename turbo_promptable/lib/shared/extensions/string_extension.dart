extension StringNormalizedExtension on String {
  String get normalized => replaceAll(RegExp(r'\s+'), ' ').trim();
}
