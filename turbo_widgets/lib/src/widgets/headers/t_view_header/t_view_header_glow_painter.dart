import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

class TViewHeaderGlowPainter extends CustomPainter {
  const TViewHeaderGlowPainter({
    required this.glowDiameter,
    required this.glowOffset,
    required this.glowColor,
  });

  final double glowDiameter;
  final Offset glowOffset;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = glowDiameter / 2;
    final center = Offset(
      glowOffset.dx + radius,
      glowOffset.dy + radius,
    );
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        [glowColor, glowColor.withValues(alpha: 0)],
        [0.0, 1.0],
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(TViewHeaderGlowPainter oldDelegate) =>
      glowDiameter != oldDelegate.glowDiameter ||
      glowOffset != oldDelegate.glowOffset ||
      glowColor != oldDelegate.glowColor;
}
