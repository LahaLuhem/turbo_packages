import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/theme/t_font_families.dart';
import 'package:turbo_widgets/src/theme/t_sizes.dart';

class TBulletItem extends StatelessWidget {
  const TBulletItem({
    super.key,
    required this.text,
    this.bulletColor,
    this.bulletSize = 4.0,
    this.textStyle,
    this.showBottomBorder = true,
  });

  final String text;
  final Color? bulletColor;
  final double bulletSize;
  final TextStyle? textStyle;
  final bool showBottomBorder;

  static const _defaultBulletColor = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: showBottomBorder
          ? const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0x0DFFFFFF),
                  width: 1,
                ),
              ),
            )
          : null,
      child: Row(
        spacing: TSizes.itemGap,
        children: [
          Container(
            width: bulletSize,
            height: bulletSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bulletColor ?? _defaultBulletColor,
            ),
          ),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  textStyle ??
                  const TextStyle(
                    fontFamily: TFontFamilies.jetBrainsMono,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFA1A1AA),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
