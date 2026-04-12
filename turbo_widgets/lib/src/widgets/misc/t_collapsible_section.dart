import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:turbo_widgets/src/widgets/misc/t_shrink.dart';

class TCollapsibleSection extends StatelessWidget {
  const TCollapsibleSection({
    required this.title,
    required this.isExpanded,
    required this.onToggle,
    required this.child,
    this.subtitle,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: padding,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.large.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: theme.textTheme.muted,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: isExpanded ? 0.5 : 0,
                    child: Icon(
                      LucideIcons.chevronDown,
                      size: 20,
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
          TVerticalShrink(
            alignment: Alignment.topCenter,
            show: isExpanded,
            child: Padding(
              padding: EdgeInsets.only(
                left: padding.horizontal / 2,
                right: padding.horizontal / 2,
                bottom: padding.vertical / 2,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
