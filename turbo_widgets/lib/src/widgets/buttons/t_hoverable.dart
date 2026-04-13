import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/constants/t_durations.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/theme/t_sizes.dart';
import 'package:turbo_widgets/src/widgets/buttons/hover_builder.dart';

/// Determines whether the hover effect appears in front of or behind the child widget.
enum HoverLayer {
  /// The hover effect will be drawn behind the child.
  background,

  /// The hover effect will be drawn in front of the child.
  foreground,
}

/// A widget that shows a hover animation effect when the user hovers over it.
///
/// The hover effect can be positioned either in front of or behind the child,
/// and can be customized with color, opacity, border radius, and animation settings.
class THoverable extends StatefulWidget {
  const THoverable({
    super.key,
    this.child,
    this.color,
    this.opacity = 1,
    this.borderRadius = TSizes.buttonBorderRadius,
    this.padding = EdgeInsets.zero,
    this.layer = HoverLayer.background,
    this.duration = TDurations.hover,
    this.curve = Curves.fastOutSlowIn,
    this.isActive = true,
    this.borderWidth = 0,
    this.borderColor,
    this.hoverBuilder,
  });

  /// The widget to display with the hover effect.
  final Widget? child;

  /// The color of the hover effect.
  final Color? color;

  /// The opacity of the hover effect when fully visible.
  final double opacity;

  /// The border radius of the hover effect.
  final double borderRadius;

  /// Padding to apply around the child for the hover effect.
  final EdgeInsets padding;

  /// Whether the hover effect appears in front of or behind the child.
  final HoverLayer layer;

  /// The duration of the hover animation.
  final Duration duration;

  /// The curve to use for the hover animation.
  final Curve curve;

  /// Whether the hover effect is active.
  final bool isActive;

  /// The width of the border. If greater than 0, a border will be drawn.
  final double borderWidth;

  /// The color of the border. If null, defaults to the border color from the theme.
  final Color? borderColor;

  /// Pew pew
  final HoverWidgetBuilder? hoverBuilder;

  @override
  State<THoverable> createState() => _THoverableState();
}

class _THoverableState extends State<THoverable> with TickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _setupControllerIfNeeded();
  }

  bool get hasCustomBuilder => widget.hoverBuilder != null;

  void _setupControllerIfNeeded() {
    if (!hasCustomBuilder && _controller == null) {
      _controller = AnimationController(vsync: this, duration: widget.duration);
      _initAnimation();
    }
  }

  void _disposeControllerIfNeeded() {
    if (_controller != null) {
      _controller!.dispose();
      _controller = null;
      _opacityAnimation = null;
    }
  }

  @override
  void didUpdateWidget(THoverable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.hoverBuilder != oldWidget.hoverBuilder) {
      if (hasCustomBuilder) {
        _disposeControllerIfNeeded();
      } else {
        _setupControllerIfNeeded();
      }
    }
  }

  void _initAnimation() {
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller!, curve: widget.curve));
  }

  @override
  void dispose() {
    _disposeControllerIfNeeded();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    if (_controller == null) return;

    if (isHovered) {
      _controller!.forward();
    } else {
      _controller!.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.borderColor ?? context.colors.border;

    return HoverBuilder(
      isActive: widget.isActive,
      onHover: hasCustomBuilder ? null : _onHover,
      child: widget.child,
      builder: (context, isHovered, child) {
        if (widget.hoverBuilder != null) {
          return widget.hoverBuilder!(context, isHovered, widget.child);
        }

        return AnimatedBuilder(
          animation: _controller!,
          builder: (context, child) {
            final Widget hoverEffect = CustomPaint(
              painter: _HoverPainter(
                color: widget.color ?? context.colors.cardMidground,
                opacity: widget.opacity,
                animationValue: _opacityAnimation!.value,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                padding: widget.padding,
                borderWidth: widget.borderWidth,
                borderColor: borderColor,
              ),
              size: Size.infinite,
              child: widget.layer == HoverLayer.background
                  ? widget.child
                  : null,
            );

            if (widget.layer == HoverLayer.background) {
              return hoverEffect;
            } else {
              return Stack(
                children: [
                  widget.child!,
                  Positioned.fill(child: hoverEffect),
                ],
              );
            }
          },
        );
      },
    );
  }
}

/// Custom painter that draws the hover effect.
class _HoverPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double animationValue;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final double borderWidth;
  final Color borderColor;

  _HoverPainter({
    required this.color,
    required this.opacity,
    required this.animationValue,
    required this.borderRadius,
    required this.padding,
    required this.borderWidth,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect =
        Offset(0 - padding.left, 0 - padding.top) &
        Size(
          size.width + padding.left + padding.right,
          size.height + padding.top + padding.bottom,
        );

    final rRect = RRect.fromRectAndCorners(
      rect,
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );

    // Draw the background fill
    final Paint fillPaint = Paint()
      ..color = color.withValues(alpha: opacity * animationValue);
    canvas.drawRRect(rRect, fillPaint);

    // Draw the border if borderWidth > 0
    if (borderWidth > 0) {
      final Paint borderPaint = Paint()
        ..color = borderColor.withValues(alpha: animationValue)
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;

      canvas.drawRRect(rRect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HoverPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color ||
        oldDelegate.opacity != opacity ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.padding != padding ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.borderColor != borderColor;
  }
}
