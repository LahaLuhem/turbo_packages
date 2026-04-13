import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/constants/t_durations.dart';
import 'package:turbo_widgets/src/theme/t_font_families.dart';
import 'package:turbo_widgets/src/theme/t_sizes.dart';

class TStatusIndicator extends StatefulWidget {
  const TStatusIndicator({
    super.key,
    required this.label,
    this.isLive = false,
    this.dotColor,
    this.dotSize = 6.0,
    this.labelStyle,
  });

  final String label;
  final bool isLive;
  final Color? dotColor;
  final double dotSize;
  final TextStyle? labelStyle;

  @override
  State<TStatusIndicator> createState() => _TStatusIndicatorState();
}

class _TStatusIndicatorState extends State<TStatusIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<double> _opacityAnimation;

  static const _defaultDotColor = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    if (widget.isLive) {
      _initPulseController();
    }
  }

  void _initPulseController() {
    _controller = AnimationController(
      duration: TDurations.second,
      vsync: this,
    );
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.5,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_controller!);
    _controller!.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(TStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLive && !oldWidget.isLive) {
      _initPulseController();
    } else if (!widget.isLive && oldWidget.isLive) {
      _controller?.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: TSizes.textGap,
      children: [
        if (widget.isLive)
          _PulsingDot(
            animation: _opacityAnimation,
            color: widget.dotColor ?? _defaultDotColor,
            size: widget.dotSize,
          ),
        Flexible(
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                widget.labelStyle ??
                const TextStyle(
                  fontFamily: TFontFamilies.jetBrainsMono,
                  fontSize: 10,
                  letterSpacing: 3.0,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF52525B),
                ),
          ),
        ),
      ],
    );
  }
}

class _PulsingDot extends StatelessWidget {
  const _PulsingDot({
    required this.animation,
    required this.color,
    required this.size,
  });

  final Animation<double> animation;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
