enum RelationshipType {
  of;

  static RelationshipType fromJson(String value) =>
      RelationshipType.values.firstWhere((e) => e.name == value);

  String toJson() => name;
}
