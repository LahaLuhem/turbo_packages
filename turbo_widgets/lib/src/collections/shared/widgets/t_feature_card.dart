import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class TFeatureCard extends StatelessWidget {
  const TFeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    super.key,
    this.accent,
    this.borderRadius = 16,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color? accent;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final accentColor = accent ?? theme.colorScheme.primary;
    final innerRadius = math.max(0.0, borderRadius - 1);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: theme.colorScheme.border.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(innerRadius),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 1.5,
                    colors: [
                      accentColor.withValues(alpha: 0.15),
                      theme.colorScheme.background,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final hasBoundedHeight = constraints.hasBoundedHeight;
                  final descriptionWidget = Text(
                    description,
                    style: theme.textTheme.muted.copyWith(
                      fontSize: 13,
                      height: 1.4,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(
                          icon,
                          size: 22,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: theme.textTheme.large.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.foreground,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      if (hasBoundedHeight)
                        Expanded(child: descriptionWidget)
                      else
                        descriptionWidget,
                      const SizedBox(height: 12),
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
