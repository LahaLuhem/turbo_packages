class TFirestorePage<ITEM, CURSOR> {
  const TFirestorePage({
    required this.items,
    required this.cursor,
    required this.hasMore,
    required this.pageSize,
  }) : assert(pageSize >= 1, 'pageSize must be >= 1');

  final List<ITEM> items;
  final CURSOR? cursor;
  final bool hasMore;
  final int pageSize;
}