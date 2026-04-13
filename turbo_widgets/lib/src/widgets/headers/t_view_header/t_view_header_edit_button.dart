import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/widgets/buttons/hover_icon_button.dart';

class TViewHeaderEditButton extends StatelessWidget {
  const TViewHeaderEditButton({
    super.key,
    required this.onTap,
    this.icon = Icons.edit_outlined,
    this.iconSize = 12,
    this.tooltip,
  });

  final VoidCallback onTap;
  final IconData icon;
  final double iconSize;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return HoverIconButton(
      onTap: onTap,
      icon: icon,
      iconSize: iconSize,
      borderColorIdle: const Color(0x1AFFFFFF),
      borderColorHover: const Color(0x4DFFFFFF),
      iconColorIdle: const Color(0xFF52525B),
      iconColorHover: const Color(0xFFFFFFFF),
    );
  }
}
