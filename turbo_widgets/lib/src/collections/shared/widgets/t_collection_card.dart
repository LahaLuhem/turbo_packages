import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class TCollectionCard extends StatelessWidget {
  const TCollectionCard({
    required this.title,
    super.key,
    this.subtitle,
    this.meta,
    this.thumbnail,
    this.onPressed,
    this.borderRadius = 12.0,
  });

  final String title;
  final String? subtitle;
  final String? meta;
  final ImageProvider? thumbnail;
  final VoidCallback? onPressed;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isEnabled = onPressed != null;

    return ShadCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          mouseCursor: isEnabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (thumbnail != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image(
                      image: thumbnail!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: _TCollectionCardContent(
                    title: title,
                    subtitle: subtitle,
                    meta: meta,
                    theme: theme,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TCollectionCardContent extends StatelessWidget {
  const _TCollectionCardContent({
    required this.title,
    required this.theme,
    this.subtitle,
    this.meta,
  });

  final String title;
  final String? subtitle;
  final String? meta;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.p.copyWith(fontWeight: FontWeight.w600),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.muted.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        ],
        if (meta != null) ...[
          const SizedBox(height: 6),
          Text(
            meta!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.small.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        ],
      ],
    );
  }
}
