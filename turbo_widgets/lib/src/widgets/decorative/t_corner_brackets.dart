import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';

class TCornerBrackets extends StatelessWidget {
  const TCornerBrackets({
    super.key,
    required this.child,
    this.bracketSize = 128.0,
    this.strokeWidth = 2.0,
    this.color,
  });

  final Widget child;
  final double bracketSize;
  final double strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolvedColor =
        color ?? context.colors.primary.withValues(alpha: 0.2);
    return CustomPaint(
      foregroundPainter: _TCornerBracketsPainter(
        bracketSize: bracketSize,
        strokeWidth: strokeWidth,
        color: resolvedColor,
      ),
      child: child,
    );
  }
}

class _TCornerBracketsPainter extends CustomPainter {
  _TCornerBracketsPainter({
    required this.bracketSize,
    required this.strokeWidth,
    required this.color,
  });

  final double bracketSize;
  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final half = strokeWidth / 2;

    // Top-left
    canvas.drawLine(
      Offset(half, half),
      Offset(bracketSize, half),
      paint,
    );
    canvas.drawLine(
      Offset(half, half),
      Offset(half, bracketSize),
      paint,
    );

    // Top-right
    canvas.drawLine(
      Offset(size.width - half, half),
      Offset(size.width - bracketSize, half),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - half, half),
      Offset(size.width - half, bracketSize),
      paint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(half, size.height - half),
      Offset(bracketSize, size.height - half),
      paint,
    );
    canvas.drawLine(
      Offset(half, size.height - half),
      Offset(half, size.height - bracketSize),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(size.width - half, size.height - half),
      Offset(size.width - bracketSize, size.height - half),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - half, size.height - half),
      Offset(size.width - half, size.height - bracketSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(_TCornerBracketsPainter oldDelegate) =>
      oldDelegate.bracketSize != bracketSize ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.color != color;
}
