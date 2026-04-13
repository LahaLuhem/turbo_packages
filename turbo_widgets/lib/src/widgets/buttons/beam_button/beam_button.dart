import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/widgets/buttons/beam_button/beam_button_border_reveal_painter.dart';
import 'package:turbo_widgets/src/widgets/buttons/beam_button/beam_line_painter.dart';

class BeamButton extends StatefulWidget {
  const BeamButton({
    super.key,
    required this.label,
    this.onPressed,
    this.disabled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool disabled;

  @override
  State<BeamButton> createState() => _BeamButtonState();
}

class _BeamButtonState extends State<BeamButton> with TickerProviderStateMixin {
  static const _buttonBorderColor = Color(0xFFFEFEFE);

  late final AnimationController _leftBeamController;
  late final AnimationController _rightBeamController;
  late final AnimationController _hoverController;

  late final Animation<double> _leftBeamAnimation;
  late final Animation<double> _rightBeamAnimation;

  @override
  void initState() {
    super.initState();
    _leftBeamController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _rightBeamController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _leftBeamAnimation = CurvedAnimation(
      parent: _leftBeamController,
      curve: Curves.easeInOut,
    );
    _rightBeamAnimation = CurvedAnimation(
      parent: _rightBeamController,
      curve: Curves.easeInOut,
    );

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _leftBeamController.dispose();
    _rightBeamController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  void _onHoverChanged(bool hovering) {
    if (widget.disabled) return;
    if (hovering) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final beamColor = colors.primary;
    final lineColor = colors.border;

    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        final hoverProgress = _hoverController.value;
        final borderColor = Color.lerp(
          _buttonBorderColor,
          colors.primary.withValues(alpha: 0.5),
          hoverProgress,
        )!;
        final shadowBlur = lerpDouble(0, 20, hoverProgress)!;
        final shadowAlpha = lerpDouble(0, 0.3, hoverProgress)!;

        return MouseRegion(
          cursor: widget.disabled
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.click,
          onEnter: (_) => _onHoverChanged(true),
          onExit: (_) => _onHoverChanged(false),
          child: GestureDetector(
            onTap: widget.disabled ? null : widget.onPressed,
            child: Opacity(
              opacity: widget.disabled ? 0.5 : 1.0,
              child: Row(
                children: [
                  Expanded(
                    child: RepaintBoundary(
                      child: SizedBox(
                        height: 1,
                        child: ClipRect(
                          child: CustomPaint(
                            painter: BeamLinePainter(
                              animation: _leftBeamAnimation,
                              lineColor: lineColor,
                              beamColor: beamColor,
                              isReversed: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _BeamButtonBody(
                      label: widget.label,
                      hoverAnimation: _hoverController,
                      borderColor: borderColor,
                      shadowBlur: shadowBlur,
                      shadowColor: colors.primary.withValues(
                        alpha: shadowAlpha,
                      ),
                    ),
                  ),
                  Expanded(
                    child: RepaintBoundary(
                      child: SizedBox(
                        height: 1,
                        child: ClipRect(
                          child: CustomPaint(
                            painter: BeamLinePainter(
                              animation: _rightBeamAnimation,
                              lineColor: lineColor,
                              beamColor: beamColor,
                              isReversed: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BeamButtonBody extends StatelessWidget {
  const _BeamButtonBody({
    required this.label,
    required this.hoverAnimation,
    required this.borderColor,
    required this.shadowBlur,
    required this.shadowColor,
  });

  final String label;
  final Animation<double> hoverAnimation;
  final Color borderColor;
  final double shadowBlur;
  final Color shadowColor;

  static const _buttonBgColor = Color(0xFF212121);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _buttonBgColor,
        boxShadow: shadowBlur > 0
            ? [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: shadowBlur,
                  spreadRadius: -5,
                ),
              ]
            : null,
      ),
      child: CustomPaint(
        painter: BeamButtonBorderRevealPainter(
          animation: hoverAnimation,
          borderColor: borderColor,
          coverColor: _buttonBgColor,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFFEFEFE),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
