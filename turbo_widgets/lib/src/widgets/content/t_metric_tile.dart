import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/theme/t_font_families.dart';

class TMetricTile extends StatelessWidget {
  const TMetricTile({
    super.key,
    required this.value,
    required this.label,
    this.unit,
    this.valueStyle,
    this.labelStyle,
    this.unitStyle,
  });

  final String value;
  final String label;
  final String? unit;
  final TextStyle? valueStyle;
  final TextStyle? labelStyle;
  final TextStyle? unitStyle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style:
              valueStyle ??
              TextStyle(
                fontFamily: TFontFamilies.jetBrainsMono,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: colors.heading,
                height: 1.0,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style:
              labelStyle ??
              const TextStyle(
                fontFamily: TFontFamilies.jetBrainsMono,
                fontSize: 10,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w400,
                color: Color(0xFF52525B),
              ),
        ),
        if (unit != null) ...[
          const SizedBox(height: 4),
          Text(
            unit!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style:
                unitStyle ??
                TextStyle(
                  fontFamily: TFontFamilies.jetBrainsMono,
                  fontSize: 9,
                  letterSpacing: 1.35,
                  fontWeight: FontWeight.w400,
                  color: colors.primary,
                ),
          ),
        ],
      ],
    );
  }
}
