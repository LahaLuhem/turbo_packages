import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/constants/t_durations.dart';
import 'package:turbo_widgets/src/theme/t_colors.dart';
import 'package:turbo_widgets/src/widgets/cards/t_card_shell.dart';

class TSpotlightCard extends StatefulWidget {
  const TSpotlightCard({
    super.key,
    required this.builder,
    this.showGridPattern = false,
    this.bracketSize = 12.0,
    this.padding,
    this.footer,
    this.footerReservedHeight = 0,
    this.minHeight,
    this.onTap,
    this.onHoverChanged,
    this.onMouseEnter,
    this.onMouseMove,
    this.onMouseExit,
  });

  final Widget Function(BuildContext context, bool isHovered) builder;
  final bool showGridPattern;
  final double bracketSize;
  final EdgeInsetsGeometry? padding;
  final Widget? footer;
  final double footerReservedHeight;
  final double? minHeight;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onHoverChanged;
  final void Function(PointerEvent)? onMouseEnter;
  final void Function(PointerEvent)? onMouseMove;
  final void Function(PointerEvent)? onMouseExit;

  @override
  State<TSpotlightCard> createState() => _TSpotlightCardState();
}

class _TSpotlightCardState extends State<TSpotlightCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spotlightController;
  late final CurvedAnimation _spotlightOpacity;
  final ValueNotifier<Offset> _mousePosition = ValueNotifier(Offset.zero);
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _spotlightController = AnimationController(
      duration: TDurations.animationX2,
      vsync: this,
    );
    _spotlightOpacity = CurvedAnimation(
      parent: _spotlightController,
      curve: Curves.ease,
    );
  }

  @override
  void dispose() {
    _spotlightOpacity.dispose();
    _spotlightController.dispose();
    _mousePosition.dispose();
    super.dispose();
  }

  void _onEnter(PointerEvent event) {
    _mousePosition.value = event.localPosition;
    setState(() => _isHovered = true);
    _spotlightController.forward();
    widget.onHoverChanged?.call(true);
    widget.onMouseEnter?.call(event);
  }

  void _onHover(PointerEvent event) {
    _mousePosition.value = event.localPosition;
    widget.onMouseMove?.call(event);
  }

  void _onExit(PointerEvent event) {
    setState(() {
      _isHovered = false;
      _isPressed = false;
    });
    _spotlightController.reverse();
    widget.onHoverChanged?.call(false);
    widget.onMouseExit?.call(event);
  }

  void _onTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final padding = widget.padding;
    final footerPadding = padding is EdgeInsets ? padding : null;

    Widget card = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: _onEnter,
      onHover: _onHover,
      onExit: _onExit,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: _spotlightOpacity,
          builder: (context, content) {
            final t = _spotlightOpacity.value;
            final borderAlpha = _isPressed ? 0.3 : ui.lerpDouble(0.1, 0.2, t)!;
            final bracketColor = Color.lerp(
              Colors.white.withValues(alpha: 0.05),
              TColors.primaryDark.withValues(alpha: 0.5),
              t,
            )!;

            return TCardShell(
              borderColor: Colors.white.withValues(alpha: borderAlpha),
              boxShadow: t > 0
                  ? [
                      BoxShadow(
                        color: const Color(
                          0xFF065F71,
                        ).withValues(alpha: 0.1 * t),
                        blurRadius: 25,
                      ),
                    ]
                  : null,
              showGridPattern: widget.showGridPattern,
              bracketSize: widget.bracketSize,
              bracketColor: bracketColor,
              child: ClipRect(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: _SpotlightPainter(
                            mousePosition: _mousePosition,
                            opacity: _spotlightOpacity,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: ImageFiltered(
                          imageFilter: ui.ImageFilter.blur(
                            sigmaX: 80,
                            sigmaY: 80,
                          ),
                          child: SizedBox(
                            width: 160,
                            height: 160,
                            child: ColoredBox(
                              color: TColors.primaryDark.withValues(
                                alpha: ui.lerpDouble(0.05, 0.10, t)!,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (padding != null)
                      Padding(
                        padding: widget.footerReservedHeight > 0
                            ? padding.add(
                                EdgeInsets.only(
                                  bottom: widget.footerReservedHeight,
                                ),
                              )
                            : padding,
                        child: widget.builder(context, _isHovered),
                      )
                    else
                      widget.builder(context, _isHovered),
                    if (widget.footer != null && footerPadding != null)
                      Positioned(
                        left: footerPadding.left,
                        right: footerPadding.right,
                        bottom: footerPadding.bottom,
                        child: widget.footer!,
                      ),
                  ],
                ),
              ),
            );
          },
          child: widget.builder(context, _isHovered),
        ),
      ),
    );

    if (widget.minHeight != null) {
      card = ConstrainedBox(
        constraints: BoxConstraints(minHeight: widget.minHeight!),
        child: card,
      );
    }

    return card;
  }
}

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({
    required this.mousePosition,
    required this.opacity,
  }) : super(repaint: Listenable.merge([mousePosition, opacity]));

  final ValueNotifier<Offset> mousePosition;
  final Animation<double> opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity.value <= 0) return;

    final center = mousePosition.value;
    const radius = 600.0;
    final alpha = (0.04 * opacity.value * 255).round().clamp(0, 255);

    final paint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        [
          Color.fromARGB(alpha, 255, 255, 255),
          Colors.transparent,
        ],
        [0.0, 0.4],
      );

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) => false;
}
