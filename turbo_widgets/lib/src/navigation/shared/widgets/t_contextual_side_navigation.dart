import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:turbo_widgets/src/navigation/shared/models/t_button_config.dart';
import 'package:turbo_widgets/src/navigation/shared/widgets/t_contextual_nav_button.dart';

class TContextualSideNavigation extends StatelessWidget {
  const TContextualSideNavigation({
    required this.buttons,
    super.key,
    this.selectedKey,
    this.onSelect,
    this.showLabels = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    this.spacing = 8,
    this.activeVariant = ShadButtonVariant.primary,
    this.inactiveVariant = ShadButtonVariant.ghost,
  });

  final Map<String, TButtonConfig> buttons;
  final String? selectedKey;
  final ValueChanged<String>? onSelect;
  final bool showLabels;
  final EdgeInsets padding;
  final double spacing;
  final ShadButtonVariant activeVariant;
  final ShadButtonVariant inactiveVariant;

  @override
  Widget build(BuildContext context) {
    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    final children = <Widget>[];
    for (final entry in buttons.entries) {
      children.add(
        TContextualNavButton(
          config: entry.value.copyWith(
            isActive: entry.key == selectedKey,
            onPressed: () {
              entry.value.onPressed();
              if (onSelect != null) {
                onSelect!(entry.key);
              }
            },
          ),
          showLabel: showLabels,
          variant: entry.key == selectedKey ? activeVariant : inactiveVariant,
        ),
      );
    }

    return SafeArea(
      right: false,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1) SizedBox(height: spacing),
            ],
          ],
        ),
      ),
    );
  }
}
