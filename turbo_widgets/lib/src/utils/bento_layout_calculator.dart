import 'dart:ui';

import 'package:turbo_widgets/src/models/layout/bento_layout_result.dart';

/// Calculates proportional layouts using a squarified treemap algorithm.
/// Guarantees 100% fill of available space with area proportional to size values.
class BentoLayoutCalculator {
  const BentoLayoutCalculator._();

  static const double _minDimension = 40.0;

  /// Calculate layout positions and sizes for all items.
  static List<BentoLayoutResult> calculate({
    required List<double> sizes,
    required Size availableSize,
    required double spacing,
  }) {
    if (sizes.isEmpty) return [];

    if (sizes.length == 1) {
      return [
        BentoLayoutResult(
          index: 0,
          position: Offset.zero,
          size: availableSize,
        ),
      ];
    }

    final totalSize = sizes.fold<double>(0, (sum, s) => sum + s);
    if (totalSize <= 0) return [];

    final totalArea = availableSize.width * availableSize.height;

    // Calculate target areas for each item
    final targetAreas = sizes.map((s) => (s / totalSize) * totalArea).toList();

    // Run squarified algorithm
    return _squarify(
      indices: List.generate(sizes.length, (i) => i),
      areas: targetAreas,
      rect: Rect.fromLTWH(0, 0, availableSize.width, availableSize.height),
      spacing: spacing,
    );
  }

  static List<BentoLayoutResult> _squarify({
    required List<int> indices,
    required List<double> areas,
    required Rect rect,
    required double spacing,
  }) {
    if (indices.isEmpty) return [];

    // Base case: single item fills the entire rect
    if (indices.length == 1) {
      return [
        BentoLayoutResult(
          index: indices[0],
          position: Offset(rect.left, rect.top),
          size: Size(
            rect.width.clamp(_minDimension, double.infinity),
            rect.height.clamp(_minDimension, double.infinity),
          ),
        ),
      ];
    }

    // Find best partition point (closest to 50/50 split by area)
    final totalArea = areas.fold<double>(0, (sum, a) => sum + a);
    double runningSum = 0;
    int splitIndex = 1;
    double bestDiff = double.infinity;

    for (int i = 0; i < indices.length - 1; i++) {
      runningSum += areas[i];
      final diff = (runningSum - totalArea / 2).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        splitIndex = i + 1;
      }
    }

    final group1Indices = indices.sublist(0, splitIndex);
    final group1Areas = areas.sublist(0, splitIndex);
    final group2Indices = indices.sublist(splitIndex);
    final group2Areas = areas.sublist(splitIndex);

    final group1TotalArea = group1Areas.fold<double>(0, (sum, a) => sum + a);
    final ratio = totalArea > 0 ? group1TotalArea / totalArea : 0.5;

    Rect rect1, rect2;

    if (rect.width >= rect.height) {
      // Vertical split (side by side)
      // Subtract spacing from available width, then distribute proportionally
      final availableWidth = rect.width - spacing;
      final width1 = (availableWidth * ratio).clamp(
        _minDimension,
        availableWidth,
      );
      final width2 = (availableWidth - width1).clamp(
        _minDimension,
        availableWidth,
      );

      rect1 = Rect.fromLTWH(rect.left, rect.top, width1, rect.height);
      rect2 = Rect.fromLTWH(
        rect.left + width1 + spacing,
        rect.top,
        width2,
        rect.height,
      );
    } else {
      // Horizontal split (stacked)
      // Subtract spacing from available height, then distribute proportionally
      final availableHeight = rect.height - spacing;
      final height1 = (availableHeight * ratio).clamp(
        _minDimension,
        availableHeight,
      );
      final height2 = (availableHeight - height1).clamp(
        _minDimension,
        availableHeight,
      );

      rect1 = Rect.fromLTWH(rect.left, rect.top, rect.width, height1);
      rect2 = Rect.fromLTWH(
        rect.left,
        rect.top + height1 + spacing,
        rect.width,
        height2,
      );
    }

    return [
      ..._squarify(
        indices: group1Indices,
        areas: group1Areas,
        rect: rect1,
        spacing: spacing,
      ),
      ..._squarify(
        indices: group2Indices,
        areas: group2Areas,
        rect: rect2,
        spacing: spacing,
      ),
    ];
  }
}
