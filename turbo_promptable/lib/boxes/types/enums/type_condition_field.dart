enum TypeConditionField {
  title,
  content;

  static TypeConditionField fromJson(String value) =>
      TypeConditionField.values.firstWhere((e) => e.name == value);

  String toJson() => name;
}
