import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/theme/t_colors.dart';
import 'package:turbo_widgets/src/theme/t_font_families.dart';

class TViewHeaderTypeLabel extends StatelessWidget {
  const TViewHeaderTypeLabel({
    super.key,
    required this.label,
    this.isSmall = false,
  });

  final String label;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    final dashWidth = isSmall ? 16.0 : 24.0;
    final gap = isSmall ? 8.0 : 12.0;
    final fontSize = isSmall ? 10.0 : 12.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: dashWidth,
          height: 1,
          child: const ColoredBox(color: TColors.primaryDark),
        ),
        SizedBox(width: gap),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: TFontFamilies.jetBrainsMono,
            fontWeight: FontWeight.w700,
            fontSize: fontSize,
            color: TColors.primaryDark,
            letterSpacing: 2.0,
            height: 1,
          ),
        ),
      ],
    );
  }
}
