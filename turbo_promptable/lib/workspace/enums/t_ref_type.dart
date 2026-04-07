enum TRefType {
  brackets,
  parentheses,
  curlyBraces,
  angleBrackets,
  ;

  String get open => switch (this) {
    TRefType.brackets => '[',
    TRefType.parentheses => '(',
    TRefType.angleBrackets => '<',
    TRefType.curlyBraces => '{',
  };

  String get openDouble => open * 2;

  String get close => switch (this) {
    TRefType.brackets => ']',
    TRefType.parentheses => ')',
    TRefType.angleBrackets => '>',
    TRefType.curlyBraces => '}',
  };

  String get closeDouble => close * 2;
}
