import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:turbo_widgets/src/models/buttons/t_button_config.dart';
import 'package:turbo_widgets/src/widgets/navigation/t_contextual_nav_button.dart';

class TContextualAppBar extends StatelessWidget {
  const TContextualAppBar({
    super.key,
    this.leading,
    this.title,
    this.actions = const [],
    this.showLabels = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.backgroundColor,
  });

  final TButtonConfig? leading;
  final String? title;
  final List<TButtonConfig> actions;
  final bool showLabels;
  final EdgeInsets padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final titleStyle = theme.textTheme.large.copyWith(
      fontWeight: FontWeight.w600,
    );

    return Material(
      color: Colors.transparent,
      child: Container(
        color: backgroundColor ?? theme.colorScheme.background,
        padding: padding,
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              if (leading != null)
                TContextualNavButton(
                  config: leading!,
                  showLabel: showLabels,
                  variant: ShadButtonVariant.ghost,
                ),
              if (leading != null) const SizedBox(width: 8),
              if (title != null)
                Expanded(
                  child: Text(
                    title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle,
                  ),
                )
              else
                const Spacer(),
              if (actions.isNotEmpty)
                Row(
                  children: [
                    for (final action in actions)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: TContextualNavButton(
                          config: action,
                          showLabel: showLabels,
                          variant: ShadButtonVariant.ghost,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
