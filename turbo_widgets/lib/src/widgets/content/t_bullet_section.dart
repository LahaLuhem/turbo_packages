import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/widgets/content/t_bullet_item.dart';
import 'package:turbo_widgets/src/widgets/content/t_labeled_divider.dart';

class TBulletSection extends StatelessWidget {
  const TBulletSection({
    super.key,
    required this.title,
    required this.items,
    this.bulletColor,
    this.titleColor,
    this.columns = 2,
    this.maxWidth = 896,
    this.bottomSpacing = 80,
  });

  final String title;
  final List<String> items;
  final Color? bulletColor;
  final Color? titleColor;
  final int columns;
  final double maxWidth;
  final double bottomSpacing;

  static const _defaultBulletColor = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final resolvedBulletColor = bulletColor ?? _defaultBulletColor;

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      margin: EdgeInsets.only(bottom: bottomSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TLabeledDivider(
            title: title,
            titleColor: titleColor ?? resolvedBulletColor,
            accentColor: resolvedBulletColor,
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final effectiveColumns = availableWidth >= 640 ? columns : 1;
              final childWidth =
                  (availableWidth - (effectiveColumns - 1) * 32) /
                  effectiveColumns;

              return Wrap(
                spacing: 32,
                runSpacing: 12,
                children: [
                  for (var i = 0; i < items.length; i++)
                    SizedBox(
                      width: childWidth,
                      child: TBulletItem(
                        text: items[i],
                        bulletColor: resolvedBulletColor,
                        showBottomBorder: true,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
