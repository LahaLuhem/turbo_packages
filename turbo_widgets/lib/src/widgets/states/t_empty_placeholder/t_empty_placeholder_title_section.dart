import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/theme/t_font_families.dart';

class TEmptyPlaceholderTitleSection extends StatelessWidget {
  const TEmptyPlaceholderTitleSection({
    super.key,
    required this.title,
    required this.isSmall,
  });

  final String title;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: TFontFamilies.manrope,
          fontWeight: FontWeight.w500,
          fontSize: isSmall ? 24 : 30,
          letterSpacing: -0.4,
          color: colors.heading,
        ),
      ),
    );
  }
}
