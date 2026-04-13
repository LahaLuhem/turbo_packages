import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/constants/t_durations.dart';

/// Wraps [child] in a fade + slide-up entrance animation, delayed by
/// [index] * [interval].
///
/// Use ascending [index] values on sibling widgets to create a staggered
/// cascade effect where each element enters shortly after the previous one.
class TStaggeredEntrance extends StatefulWidget {
  const TStaggeredEntrance({
    super.key,
    required this.index,
    required this.child,
    this.duration = TDurations.animationX1p5,
    this.interval = TDurations.animationX1p5,
    this.slideBegin = const Offset(0, 0.15),
    this.curve = Curves.ease,
  });

  /// Position in the stagger sequence. Delay = [index] * [interval].
  final int index;

  /// The widget to animate in.
  final Widget child;

  /// Total duration of the fade + slide animation.
  final Duration duration;

  /// Delay increment per [index] step.
  final Duration interval;

  /// Starting offset for the slide (fraction of child size).
  final Offset slideBegin;

  /// Animation curve applied to both fade and slide.
  final Curve curve;

  @override
  State<TStaggeredEntrance> createState() => _TStaggeredEntranceState();
}

class _TStaggeredEntranceState extends State<TStaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curved;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _curved = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    _slide = Tween<Offset>(
      begin: widget.slideBegin,
      end: Offset.zero,
    ).animate(_curved);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final delay = widget.interval * widget.index;
      if (delay == Duration.zero) {
        _controller.forward();
      } else {
        Future.delayed(delay, () {
          if (mounted) _controller.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curved,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
