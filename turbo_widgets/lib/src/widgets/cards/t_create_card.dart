import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/constants/t_durations.dart';
import 'package:turbo_widgets/src/theme/t_colors.dart';
import 'package:turbo_widgets/src/theme/t_font_families.dart';
import 'package:turbo_widgets/src/theme/t_sizes.dart';

// ---------------------------------------------------------------------------
// TCreateCard
// ---------------------------------------------------------------------------

/// A "Create Item" card for the workspace grid, featuring a centered circular
/// plus button, optional corner-positioned quick action buttons, a cyan
/// spotlight following the mouse, and a 24 px grid pattern overlay.
class TCreateCard extends StatefulWidget {
  const TCreateCard({
    super.key,
    this.onTap,
    this.label = 'CREATE ITEM',
    this.quickActions = const [],
  });

  /// Tap handler for the center create button.
  final VoidCallback? onTap;

  /// Label displayed below the center button (e.g. "CREATE ITEM").
  final String label;

  /// 0–4 quick action widgets positioned at card corners.
  ///
  /// Layout by count:
  /// - 2: top-left, top-right
  /// - 3: top-center, bottom-left, bottom-right
  /// - 4: all four corners
  ///
  /// For single-suggestion mode, pass no quick actions and set [onTap] /
  /// [label] to the suggestion's values instead.
  final List<Widget> quickActions;

  @override
  State<TCreateCard> createState() => _TCreateCardState();
}

class _TCreateCardState extends State<TCreateCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spotlightController;
  late final CurvedAnimation _spotlightCurve;
  final ValueNotifier<Offset> _mousePosition = ValueNotifier(Offset.zero);
  bool _isHovered = false;

  // Lifecycle -----------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _spotlightController = AnimationController(
      duration: TDurations.animation,
      vsync: this,
    );
    _spotlightCurve = CurvedAnimation(
      parent: _spotlightController,
      curve: Curves.ease,
    );
  }

  @override
  void dispose() {
    _spotlightCurve.dispose();
    _spotlightController.dispose();
    _mousePosition.dispose();
    super.dispose();
  }

  // Hover handlers ------------------------------------------------------------

  void _onEnter(PointerEvent event) {
    _mousePosition.value = event.localPosition;
    setState(() => _isHovered = true);
    _spotlightController.forward();
  }

  void _onHover(PointerEvent event) {
    _mousePosition.value = event.localPosition;
  }

  void _onExit(PointerEvent _) {
    setState(() => _isHovered = false);
    _spotlightController.reverse();
  }

  // Build ---------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onEnter,
      onHover: _onHover,
      onExit: _onExit,
      child: AnimatedBuilder(
        animation: _spotlightCurve,
        builder: (context, content) {
          final t = _spotlightCurve.value;
          final borderColor = Color.lerp(
            Colors.white.withValues(alpha: 0.05),
            TColors.primaryDark.withValues(alpha: 0.3),
            t,
          )!;

          return ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 256),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0x4D09090B),
                border: Border.all(
                  width: TSizes.borderWidth,
                  color: borderColor,
                ),
              ),
              child: content,
            ),
          );
        },
        child: ClipRect(
          child: Stack(
            children: [
              const Positioned.fill(
                child: CustomPaint(painter: _GridPatternPainter()),
              ),
              Positioned.fill(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _CyanSpotlightPainter(
                      mousePosition: _mousePosition,
                      opacity: _spotlightCurve,
                    ),
                  ),
                ),
              ),
              ..._positionedActions(),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CreateButton(onTap: widget.onTap),
                    const SizedBox(height: 12),
                    _CreateLabel(
                      label: widget.label,
                      isHovered: _isHovered,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Quick-action positioning --------------------------------------------------

  List<Widget> _positionedActions() {
    final actions = widget.quickActions;
    if (actions.isEmpty) return const [];

    const inset = 12.0;

    return switch (actions.length) {
      2 => [
        Positioned(top: inset, left: inset, child: actions[0]),
        Positioned(top: inset, right: inset, child: actions[1]),
      ],
      3 => [
        Positioned(
          top: inset,
          left: 0,
          right: 0,
          child: Center(child: actions[0]),
        ),
        Positioned(bottom: inset, left: inset, child: actions[1]),
        Positioned(bottom: inset, right: inset, child: actions[2]),
      ],
      _ => [
        for (var i = 0; i < actions.length && i < 4; i++)
          Positioned(
            top: i < 2 ? inset : null,
            bottom: i >= 2 ? inset : null,
            left: i.isEven ? inset : null,
            right: i.isOdd ? inset : null,
            child: actions[i],
          ),
      ],
    };
  }
}

// ---------------------------------------------------------------------------
// TCreateCardQuickAction
// ---------------------------------------------------------------------------

/// Quick action button for use with [TCreateCard.quickActions].
///
/// Displays an icon, label, and trailing "+" icon. Transitions to a
/// cyan-tinted hover state over [TDurations.animation].
class TCreateCardQuickAction extends StatefulWidget {
  const TCreateCardQuickAction({
    super.key,
    required this.onTap,
    required this.iconData,
    required this.label,
  });

  final VoidCallback onTap;
  final IconData iconData;
  final String label;

  @override
  State<TCreateCardQuickAction> createState() => _TCreateCardQuickActionState();
}

class _TCreateCardQuickActionState extends State<TCreateCardQuickAction> {
  bool _isHovered = false;

  static const _bgIdle = Color(0xCC18181B);
  static const _bgHover = Color(0x1A06B6D4);
  static const _borderIdle = Color(0x1AFFFFFF);
  static const _borderHover = Color(0x8007B6D4);
  static const _fgIdle = Color(0xFFA1A1AA);
  static const _fgHover = Color(0xFF22D3EE);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: _isHovered ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 150),
          builder: (context, t, _) {
            final bg = _isHovered ? _bgHover : _bgIdle;
            final border = Color.lerp(_borderIdle, _borderHover, t)!;
            final fg = Color.lerp(_fgIdle, _fgHover, t)!;

            return DecoratedBox(
              decoration: BoxDecoration(
                color: bg,
                border: Border.all(
                  width: TSizes.borderWidth,
                  color: border,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.iconData, size: 12, color: fg),
                    const SizedBox(width: 6),
                    Text(
                      widget.label.toUpperCase(),
                      style: TextStyle(
                        fontFamily: TFontFamilies.inter,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: fg,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.add,
                      size: 10,
                      color: fg.withValues(alpha: _isHovered ? 1.0 : 0.5),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _CreateButton
// ---------------------------------------------------------------------------

class _CreateButton extends StatefulWidget {
  const _CreateButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  State<_CreateButton> createState() => _CreateButtonState();
}

class _CreateButtonState extends State<_CreateButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverController;
  late final CurvedAnimation _hoverCurve;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: TDurations.animationX2,
      vsync: this,
    );
    _hoverCurve = CurvedAnimation(
      parent: _hoverController,
      curve: Curves.ease,
    );
  }

  @override
  void dispose() {
    _hoverCurve.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _hoverController.forward(),
      onExit: (_) {
        if (_isPressed) setState(() => _isPressed = false);
        _hoverController.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedBuilder(
          animation: _hoverCurve,
          builder: (context, _) {
            final t = _hoverCurve.value;

            final bg = Color.lerp(
              const Color(0xFF18181B),
              const Color(0xFF27272A),
              t,
            )!;
            final border = Color.lerp(
              Colors.white.withValues(alpha: 0.1),
              TColors.primaryDark.withValues(alpha: 0.5),
              t,
            )!;
            final iconColor = Color.lerp(
              const Color(0xFF71717A),
              const Color(0xFF22D3EE),
              t,
            )!;
            final shadowColor = Color.lerp(
              const Color(0x80000000),
              const Color(0x4D22D3EE),
              t,
            )!;
            final scale = _isPressed ? 1.05 : ui.lerpDouble(1.0, 1.10, t)!;

            return Transform.scale(
              scale: scale,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: TSizes.borderWidth,
                    color: border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 20,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Icon(
                    Icons.add,
                    size: 24,
                    color: iconColor,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _CreateLabel
// ---------------------------------------------------------------------------

class _CreateLabel extends StatelessWidget {
  const _CreateLabel({
    required this.label,
    required this.isHovered,
  });

  final String label;
  final bool isHovered;

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: TDurations.animationX0p5,
      curve: Curves.ease,
      style: TextStyle(
        fontFamily: TFontFamilies.manrope,
        fontWeight: FontWeight.w700,
        fontSize: 13,
        letterSpacing: 1.3,
        color: isHovered ? Colors.white : const Color(0xFF71717A),
      ),
      child: Text(
        label.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _CyanSpotlightPainter
// ---------------------------------------------------------------------------

class _CyanSpotlightPainter extends CustomPainter {
  _CyanSpotlightPainter({
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
    final alpha = (0.06 * opacity.value * 255).round().clamp(0, 255);

    final paint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        [
          Color.fromARGB(alpha, 6, 182, 212),
          Colors.transparent,
        ],
        [0.0, 0.4],
      );

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_CyanSpotlightPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// _GridPatternPainter
// ---------------------------------------------------------------------------

class _GridPatternPainter extends CustomPainter {
  const _GridPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x08808080)
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
  bool shouldRepaint(_GridPatternPainter oldDelegate) => false;
}
