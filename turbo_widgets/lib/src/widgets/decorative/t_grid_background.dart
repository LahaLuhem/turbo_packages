import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';

class TGridBackground extends StatelessWidget {
  const TGridBackground({
    super.key,
    required this.child,
    this.backgroundColor = const Color(0xFF030306),
    this.gridSpacing = 60.0,
    this.gridOpacity = 0.04,
    this.showScanlines = true,
    this.scanlineOpacity = 0.02,
    this.showRadialGlow = true,
    this.glowColor,
    this.glowOpacity = 0.08,
    this.showVignette = true,
  });

  final Widget child;
  final Color backgroundColor;
  final double gridSpacing;
  final double gridOpacity;
  final bool showScanlines;
  final double scanlineOpacity;
  final bool showRadialGlow;
  final Color? glowColor;
  final double glowOpacity;
  final bool showVignette;

  @override
  Widget build(BuildContext context) {
    final resolvedGlowColor = glowColor ?? context.colors.primary;
    return RepaintBoundary(
      child: CustomPaint(
        painter: _GridBackgroundPainter(
          backgroundColor: backgroundColor,
          gridSpacing: gridSpacing,
          gridOpacity: gridOpacity,
          showScanlines: showScanlines,
          scanlineOpacity: scanlineOpacity,
          showRadialGlow: showRadialGlow,
          glowColor: resolvedGlowColor,
          glowOpacity: glowOpacity,
          showVignette: showVignette,
        ),
        child: child,
      ),
    );
  }
}

class _GridBackgroundPainter extends CustomPainter {
  _GridBackgroundPainter({
    required this.backgroundColor,
    required this.gridSpacing,
    required this.gridOpacity,
    required this.showScanlines,
    required this.scanlineOpacity,
    required this.showRadialGlow,
    required this.glowColor,
    required this.glowOpacity,
    required this.showVignette,
  });

  final Color backgroundColor;
  final double gridSpacing;
  final double gridOpacity;
  final bool showScanlines;
  final double scanlineOpacity;
  final bool showRadialGlow;
  final Color glowColor;
  final double glowOpacity;
  final bool showVignette;

  @override
  void paint(Canvas canvas, Size size) {
    final fullRect = Offset.zero & size;

    // Background fill
    canvas.drawRect(fullRect, Paint()..color = backgroundColor);

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: gridOpacity)
      ..strokeWidth = 1;

    // Vertical lines
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Scanlines
    if (showScanlines) {
      final scanlinePaint = Paint()
        ..color = Colors.white.withValues(alpha: scanlineOpacity * 0.1)
        ..strokeWidth = 2;

      for (double y = 0; y < size.height; y += 4) {
        canvas.drawLine(
          Offset(0, y + 2),
          Offset(size.width, y + 2),
          scanlinePaint,
        );
      }
    }

    // Radial glow
    if (showRadialGlow) {
      final glowCenter = Offset(size.width / 2, size.height / 4);
      const glowRadiusX = 600.0;
      const glowRadiusY = 400.0;

      canvas.save();
      canvas.translate(glowCenter.dx, glowCenter.dy);
      canvas.scale(1.0, glowRadiusY / glowRadiusX);
      canvas.translate(-glowCenter.dx, -glowCenter.dy);

      final glowShader = ui.Gradient.radial(
        glowCenter,
        glowRadiusX,
        [
          glowColor.withValues(alpha: glowOpacity),
          Colors.transparent,
        ],
        [0.0, 0.6],
      );

      canvas.drawRect(
        Rect.fromLTWH(
          0,
          glowCenter.dy - glowRadiusX,
          size.width,
          glowRadiusX * 2,
        ),
        Paint()..shader = glowShader,
      );
      canvas.restore();
    }

    // Vignette
    if (showVignette) {
      final vignetteCenter = Offset(size.width / 2, size.height / 2);
      final vignetteRadius =
          (size.width > size.height ? size.width : size.height) / 1.5;

      final vignetteShader = ui.Gradient.radial(
        vignetteCenter,
        vignetteRadius,
        [Colors.transparent, const Color(0x66000000)],
        [0.0, 1.0],
      );

      canvas.drawRect(
        fullRect,
        Paint()..shader = vignetteShader,
      );
    }
  }

  @override
  bool shouldRepaint(_GridBackgroundPainter oldDelegate) =>
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.gridSpacing != gridSpacing ||
      oldDelegate.gridOpacity != gridOpacity ||
      oldDelegate.showScanlines != showScanlines ||
      oldDelegate.scanlineOpacity != scanlineOpacity ||
      oldDelegate.showRadialGlow != showRadialGlow ||
      oldDelegate.glowColor != glowColor ||
      oldDelegate.glowOpacity != glowOpacity ||
      oldDelegate.showVignette != showVignette;
}
