import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class BeamLinePainter extends CustomPainter {
  BeamLinePainter({
    required this.animation,
    required this.lineColor,
    required this.beamColor,
    required this.isReversed,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color lineColor;
  final Color beamColor;
  final bool isReversed;

  static const _beamWidth = 160.0;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..shader = ui.Gradient.linear(
        isReversed ? Offset(size.width, 0) : Offset.zero,
        isReversed ? Offset.zero : Offset(size.width, 0),
        [Colors.transparent, lineColor, lineColor],
        [0.0, 0.4, 1.0],
      );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      linePaint,
    );

    final progress = animation.value;
    final double beamX;
    if (isReversed) {
      beamX = size.width - progress * (size.width + _beamWidth * 4);
    } else {
      beamX = -_beamWidth + progress * (size.width + _beamWidth * 4);
    }

    final beamPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(beamX, 0),
        Offset(beamX + _beamWidth, 0),
        [Colors.transparent, beamColor, Colors.transparent],
        [0.0, 0.5, 1.0],
      );
    canvas.drawRect(
      Rect.fromLTWH(beamX, 0, _beamWidth, size.height),
      beamPaint,
    );
  }

  @override
  bool shouldRepaint(BeamLinePainter oldDelegate) => false;
}
