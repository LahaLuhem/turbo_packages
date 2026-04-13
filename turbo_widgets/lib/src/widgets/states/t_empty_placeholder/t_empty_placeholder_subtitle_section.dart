import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/theme/t_colors.dart';
import 'package:turbo_widgets/src/theme/t_font_families.dart';
import 'package:turbo_widgets/src/theme/t_theme_mode.dart';

class TEmptyPlaceholderSubtitleSection extends StatelessWidget {
  const TEmptyPlaceholderSubtitleSection({
    super.key,
    required this.subtitle,
    required this.isSmall,
  });

  final String subtitle;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeMode == TThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        subtitle,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: TFontFamilies.jetBrainsMono,
          fontWeight: FontWeight.w400,
          fontSize: isSmall ? 12 : 14,
          color: isDark ? TColors.textHintDark : TColors.textHintLight,
        ),
      ),
    );
  }
}
