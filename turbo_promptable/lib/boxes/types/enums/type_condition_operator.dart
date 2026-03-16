enum TypeConditionOperator {
  is_,
  isNot,
  contains,
  containsNot,
  startsWith,
  startsNotWith,
  endsWith,
  endsNotWith;

  static const _jsonMap = {
    'is': is_,
    'isNot': isNot,
    'contains': contains,
    'containsNot': containsNot,
    'startsWith': startsWith,
    'startsNotWith': startsNotWith,
    'endsWith': endsWith,
    'endsNotWith': endsNotWith,
  };

  static TypeConditionOperator fromJson(String value) => _jsonMap[value]!;
  String toJson() => _jsonMap.entries.firstWhere((e) => e.value == this).key;
}
