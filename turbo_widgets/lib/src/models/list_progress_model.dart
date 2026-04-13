class ListProgressModel {
  const ListProgressModel({
    required this.completedCount,
    required this.maxCount,
  });

  factory ListProgressModel.empty() =>
      const ListProgressModel(completedCount: 0, maxCount: 0);

  final int completedCount;
  final int maxCount;

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  bool get isEmpty => completedCount == 0 && maxCount == 0;
  String get progressCount => '$completedCount/$maxCount';
  double get progressPercentage =>
      maxCount == 0 ? 0 : completedCount / maxCount;
}
