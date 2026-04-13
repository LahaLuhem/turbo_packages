import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/theme/t_sizes.dart';
import 'package:turbo_widgets/src/widgets/states/t_empty_placeholder/icon_glow_painter.dart';

class TEmptyPlaceholderIconSection extends StatelessWidget {
  const TEmptyPlaceholderIconSection({
    super.key,
    required this.icon,
    required this.glowAnimation,
    required this.isSmall,
  });

  final IconData icon;
  final Animation<double> glowAnimation;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final iconSize = isSmall ? 48.0 : 64.0;
    final boxPadding = isSmall ? 24.0 : 32.0;
    final totalBoxSize = iconSize + boxPadding * 2;
    const glowOverflow = 48.0;
    final containerSize = totalBoxSize + glowOverflow;

    return SizedBox(
      width: containerSize,
      height: containerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RepaintBoundary(
            child: CustomPaint(
              size: Size(totalBoxSize, totalBoxSize),
              painter: IconGlowPainter(
                animation: glowAnimation,
                glowColor: colors.primary,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.secondary,
              border: Border.all(
                width: TSizes.borderWidth,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 25,
                  offset: const Offset(0, 25),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(boxPadding),
              child: Icon(
                icon,
                size: iconSize,
                color: colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
