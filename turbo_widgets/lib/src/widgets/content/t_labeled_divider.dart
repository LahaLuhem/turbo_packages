import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/theme/t_font_families.dart';
import 'package:turbo_widgets/src/theme/t_sizes.dart';

class TLabeledDivider extends StatelessWidget {
  const TLabeledDivider({
    super.key,
    required this.title,
    this.titleColor,
    this.trailing,
    this.trailingColor,
    this.accentColor,
    this.accentWidth = 32.0,
    this.lineColor,
  });

  final String title;
  final Color? titleColor;
  final String? trailing;
  final Color? trailingColor;
  final Color? accentColor;
  final double accentWidth;
  final Color? lineColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const monoStyle = TextStyle(
      fontFamily: TFontFamilies.jetBrainsMono,
      fontSize: 10,
      letterSpacing: 3.0,
      fontWeight: FontWeight.w400,
    );

    return Row(
      spacing: TSizes.elementGap,
      children: [
        if (accentColor != null)
          Container(
            height: 1,
            width: accentWidth,
            color: accentColor!.withValues(alpha: 0.5),
          ),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: monoStyle.copyWith(
            color: titleColor ?? const Color(0xFF52525B),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: lineColor ?? colors.border,
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: monoStyle.copyWith(
              color: trailingColor ?? colors.primary,
            ),
          ),
      ],
    );
  }
}
