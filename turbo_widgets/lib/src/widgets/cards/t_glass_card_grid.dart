import 'package:flutter/material.dart';

class TGlassCardGrid extends StatelessWidget {
  const TGlassCardGrid({
    super.key,
    required this.children,
    this.columns = 2,
    this.maxWidth = 896,
    this.spacing = 16,
    this.bottomSpacing = 80,
  });

  final List<Widget> children;
  final int columns;
  final double maxWidth;
  final double spacing;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      margin: EdgeInsets.only(bottom: bottomSpacing),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final effectiveColumns = availableWidth >= 640 ? columns : 1;
          final childWidth =
              (availableWidth - (effectiveColumns - 1) * spacing) /
              effectiveColumns;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final child in children)
                SizedBox(width: childWidth, child: child),
            ],
          );
        },
      ),
    );
  }
}
