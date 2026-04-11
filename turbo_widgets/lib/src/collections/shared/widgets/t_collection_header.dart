import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class TCollectionHeader extends StatelessWidget {
  const TCollectionHeader({
    required this.title,
    required this.description,
    super.key,
    this.backgroundImage,
    this.borderRadius = 16.0,
  });

  final String title;
  final String description;
  final ImageProvider? backgroundImage;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        theme.colorScheme.primary.withValues(alpha: 0.9),
        theme.colorScheme.secondary.withValues(alpha: 0.9),
      ],
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          if (backgroundImage != null)
            Positioned.fill(
              child: Image(
                image: backgroundImage!,
                fit: BoxFit.cover,
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: gradient),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.large.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primaryForeground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.muted.copyWith(
                    color: theme.colorScheme.primaryForeground.withValues(
                      alpha: 0.85,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
