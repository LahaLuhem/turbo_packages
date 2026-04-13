import 'package:flutter/material.dart';

class IconGlowPainter extends CustomPainter {
  IconGlowPainter({
    required this.animation,
    required this.glowColor,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = glowColor.withValues(alpha: 0.2 * animation.value)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(IconGlowPainter oldDelegate) => false;
}
