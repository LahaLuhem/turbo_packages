import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:turbo_widgets/src/models/buttons/t_button_config.dart';
import 'package:turbo_widgets/src/widgets/navigation/t_contextual_nav_button.dart';

class TContextualBottomNavigation extends StatelessWidget {
  const TContextualBottomNavigation({
    required this.buttons,
    super.key,
    this.selectedKey,
    this.onSelect,
    this.showLabels = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    this.activeVariant = ShadButtonVariant.primary,
    this.inactiveVariant = ShadButtonVariant.outline,
  });

  final Map<String, TButtonConfig> buttons;
  final String? selectedKey;
  final ValueChanged<String>? onSelect;
  final bool showLabels;
  final EdgeInsets padding;
  final ShadButtonVariant activeVariant;
  final ShadButtonVariant inactiveVariant;

  @override
  Widget build(BuildContext context) {
    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            for (final entry in buttons.entries)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TContextualNavButton(
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
                    variant: entry.key == selectedKey
                        ? activeVariant
                        : inactiveVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
