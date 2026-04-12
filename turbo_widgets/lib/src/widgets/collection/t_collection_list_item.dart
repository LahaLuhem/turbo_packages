import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class TCollectionListItem extends StatelessWidget {
  const TCollectionListItem({
    required this.title,
    super.key,
    this.subtitle,
    this.meta,
    this.leading,
    this.trailing,
    this.onPressed,
    this.borderRadius = 12.0,
  });

  final String title;
  final String? subtitle;
  final String? meta;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isEnabled = onPressed != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        mouseCursor: isEnabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: theme.colorScheme.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: _TCollectionListItemContent(
                  title: title,
                  subtitle: subtitle,
                  meta: meta,
                  theme: theme,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TCollectionListItemContent extends StatelessWidget {
  const _TCollectionListItemContent({
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.p.copyWith(fontWeight: FontWeight.w600),
        ),
        if (subtitle != null || meta != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              if (subtitle != null)
                Expanded(
                  child: Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.muted.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ),
              if (meta != null) ...[
                if (subtitle != null) const SizedBox(width: 8),
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
          ),
        ],
      ],
    );
  }
}
