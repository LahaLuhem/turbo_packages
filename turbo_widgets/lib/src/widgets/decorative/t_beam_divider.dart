import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/constants/t_durations.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/theme/t_colors.dart';
import 'package:turbo_widgets/src/theme/t_sizes.dart';

/// Animated beam line used under the side nav header (infinite sweep).
class TBeamDivider extends StatefulWidget {
  const TBeamDivider({super.key});

  @override
  State<TBeamDivider> createState() => _TBeamDividerState();
}

class _TBeamDividerState extends State<TBeamDivider>
    with SingleTickerProviderStateMixin {
  late final AnimationController _beamController;

  @override
  void initState() {
    super.initState();
    _beamController = AnimationController(
      duration: TDurations.toastDefault,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _beamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: TSizes.borderWidth,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _SideNavBeamPainter(
            animation: _beamController,
            lineColor: context.colors.border,
            beamColor: TColors.primaryDark,
          ),
        ),
      ),
    );
  }
}

class _SideNavBeamPainter extends CustomPainter {
  _SideNavBeamPainter({
    required this.animation,
    required this.lineColor,
    required this.beamColor,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color lineColor;
  final Color beamColor;

  static const _beamWidth = 40.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = lineColor,
    );

    final progress = animation.value;
    final beamX = -_beamWidth + progress * (size.width + _beamWidth * 2);

    final beamPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(beamX, 0),
        Offset(beamX + _beamWidth, 0),
        [
          Colors.transparent,
          beamColor.withValues(alpha: 0.6),
          Colors.transparent,
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawRect(Offset.zero & size, beamPaint);
  }

  @override
  bool shouldRepaint(_SideNavBeamPainter oldDelegate) => false;
}
