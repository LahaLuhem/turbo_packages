import 'dart:ui';

/// Computed layout result for a single item in the bento grid.
class BentoLayoutResult {
  const BentoLayoutResult({
    required this.index,
    required this.position,
    required this.size,
  });

  final int index;
  final Offset position;
  final Size size;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BentoLayoutResult &&
          index == other.index &&
          position == other.position &&
          size == other.size;

  @override
  int get hashCode => Object.hash(index, position, size);
}
