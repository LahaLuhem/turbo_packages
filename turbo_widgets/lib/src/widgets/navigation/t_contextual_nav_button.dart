import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:turbo_widgets/src/models/buttons/t_button_config.dart';

class TContextualNavButton extends StatelessWidget {
  const TContextualNavButton({
    required this.config,
    this.showLabel = true,
    this.variant = ShadButtonVariant.outline,
    this.size = ShadButtonSize.sm,
    this.iconSize,
    super.key,
  });

  final TButtonConfig config;
  final bool showLabel;
  final ShadButtonVariant variant;
  final ShadButtonSize size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final label = showLabel ? config.label : null;
    final iconData = config.icon;
    final icon = iconData == null ? null : Icon(iconData, size: iconSize);

    if (label == null && icon == null) {
      return const SizedBox.shrink();
    }

    final button = ShadButton.raw(
      onPressed: config.onPressed,
      size: size,
      variant: variant,
      padding: label == null
          ? const EdgeInsets.all(8)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: label == null
          ? icon!
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  icon,
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );

    return config.tooltip == null
        ? button
        : Tooltip(
            message: config.tooltip,
            child: button,
          );
  }
}
