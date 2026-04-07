enum TBodyType {
  md,
  xml,
  yaml,
  json,
  ;

  String get fileExtension {
    switch (this) {
      case TBodyType.md:
        return 'md';
      case TBodyType.xml:
        return 'xml';
      case TBodyType.yaml:
        return 'yaml';
      case TBodyType.json:
        return 'json';
    }
  }
}
