import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/theme/t_colors.dart';
import 'package:turbo_widgets/src/theme/t_sizes.dart';
import 'package:turbo_widgets/src/widgets/decorative/t_corner_brackets.dart';

class TCardShell extends StatelessWidget {
  const TCardShell({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.boxShadow,
    this.showGridPattern = false,
    this.showBrackets = true,
    this.bracketSize = 12.0,
    this.bracketColor,
    this.showBackdropBlur = false,
    this.blurSigma = 24.0,
  });

  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final bool showGridPattern;
  final bool showBrackets;
  final double bracketSize;
  final Color? bracketColor;
  final bool showBackdropBlur;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final resolvedBg = backgroundColor ?? context.colors.card;
    final resolvedBorder = borderColor ?? Colors.white.withValues(alpha: 0.1);
    final resolvedBracketColor =
        bracketColor ?? TColors.primaryDark.withValues(alpha: 0.3);

    Widget result = child;

    if (showGridPattern) {
      result = CustomPaint(
        painter: const _CardGridPainter(),
        child: result,
      );
    }

    result = DecoratedBox(
      decoration: BoxDecoration(
        color: resolvedBg,
        border: Border.all(
          width: TSizes.borderWidth,
          color: resolvedBorder,
        ),
        boxShadow: boxShadow,
      ),
      child: result,
    );

    if (showBrackets) {
      result = TCornerBrackets(
        bracketSize: bracketSize,
        strokeWidth: 1.0,
        color: resolvedBracketColor,
        child: result,
      );
    }

    if (showBackdropBlur) {
      result = ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: result,
        ),
      );
    }

    return result;
  }
}

class _CardGridPainter extends CustomPainter {
  const _CardGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x04808080)
      ..strokeWidth = 1;

    const step = 24.0;

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_CardGridPainter oldDelegate) => false;
}
