import 'package:flutter/material.dart';

class BeamButtonBorderRevealPainter extends CustomPainter {
  BeamButtonBorderRevealPainter({
    required this.animation,
    required this.borderColor,
    required this.coverColor,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color borderColor;
  final Color coverColor;

  static const _borderWidth = 2.0;
  static const _inset = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _borderWidth;
    canvas.drawRect(
      Rect.fromLTWH(
        _borderWidth / 2,
        _borderWidth / 2,
        size.width - _borderWidth,
        size.height - _borderWidth,
      ),
      borderPaint,
    );

    final progress = animation.value;
    final coverPaint = Paint()
      ..color = coverColor
      ..style = PaintingStyle.fill;

    // Vertical cover (::before pseudo-element)
    // Positioned at left:-2px, top:6px, width: 100%+4px, height: 100%-12px
    // Scales Y from 1 to 0 during first half of animation
    final scaleY = progress <= 0.5 ? 1.0 - (progress / 0.5) : 0.0;
    if (scaleY > 0) {
      final coverHeight = (size.height - _inset * 2) * scaleY;
      final coverTop = _inset + (size.height - _inset * 2 - coverHeight) / 2;
      canvas.drawRect(
        Rect.fromLTWH(
          -_borderWidth,
          coverTop,
          size.width + _borderWidth * 2,
          coverHeight,
        ),
        coverPaint,
      );
    }

    // Horizontal cover (::after pseudo-element)
    // Positioned at left:6px, top:-2px, width: 100%-12px, height: 100%+4px
    // Scales X from 1 to 0 during second half (with 500ms delay in React,
    // mapped to second half of animation interval)
    final scaleX = progress <= 0.5 ? 1.0 : 1.0 - ((progress - 0.5) / 0.5);
    if (scaleX > 0) {
      final coverWidth = (size.width - _inset * 2) * scaleX;
      final coverLeft = _inset + (size.width - _inset * 2 - coverWidth) / 2;
      canvas.drawRect(
        Rect.fromLTWH(
          coverLeft,
          -_borderWidth,
          coverWidth,
          size.height + _borderWidth * 2,
        ),
        coverPaint,
      );
    }
  }

  @override
  bool shouldRepaint(BeamButtonBorderRevealPainter oldDelegate) => false;
}
