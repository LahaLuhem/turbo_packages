import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class TCategoryCard extends StatelessWidget {
  const TCategoryCard({
    required this.title,
    super.key,
    this.icon,
    this.onPressed,
    this.backgroundImage,
    this.borderRadius = 12.0,
  });

  final String title;
  final IconData? icon;
  final VoidCallback? onPressed;
  final ImageProvider? backgroundImage;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        theme.colorScheme.primary.withValues(alpha: 0.85),
        theme.colorScheme.secondary.withValues(alpha: 0.85),
      ],
    );
    final isEnabled = onPressed != null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          mouseCursor: isEnabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          hoverColor: theme.colorScheme.muted.withValues(alpha: 0.2),
          focusColor: theme.colorScheme.muted.withValues(alpha: 0.2),
          splashColor: theme.colorScheme.primaryForeground.withValues(
            alpha: 0.12,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: gradient),
                ),
              ),
              if (backgroundImage != null)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.35,
                    child: Image(
                      image: backgroundImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 20,
                        color: theme.colorScheme.primaryForeground,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.small.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primaryForeground,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isEnabled)
                Positioned.fill(
                  child: Container(
                    color: theme.colorScheme.background.withValues(alpha: 0.35),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
