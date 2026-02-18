import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/enums/t_bento_grid_animation.dart';
import 'package:turbo_widgets/src/models/layout/bento_layout_result.dart';
import 'package:turbo_widgets/src/models/layout/t_bento_item.dart';
import 'package:turbo_widgets/src/utils/bento_layout_calculator.dart';
import 'package:turbo_widgets/src/widgets/layout/t_calculated_height.dart';

/// High-performance delegate that positions items based on pre-computed layout.
/// Used for fade, scale, and none animation types.
class _StaticFlowDelegate extends FlowDelegate {
  _StaticFlowDelegate({
    required this.layout,
  });

  final List<BentoLayoutResult> layout;

  @override
  void paintChildren(FlowPaintingContext context) {
    for (int i = 0; i < context.childCount; i++) {
      final result = _findResult(i);
      if (result == null) continue;

      context.paintChild(
        i,
        transform: Matrix4.translationValues(
          result.position.dx,
          result.position.dy,
          0,
        ),
      );
    }
  }

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    final result = _findResult(i);
    if (result == null) return BoxConstraints.tight(Size.zero);
    return BoxConstraints.tight(result.size);
  }

  BentoLayoutResult? _findResult(int index) {
    for (final r in layout) {
      if (r.index == index) return r;
    }
    return null;
  }

  @override
  Size getSize(BoxConstraints constraints) => constraints.biggest;

  @override
  bool shouldRepaint(_StaticFlowDelegate oldDelegate) {
    return !listEquals(layout, oldDelegate.layout);
  }

  @override
  bool shouldRelayout(_StaticFlowDelegate oldDelegate) {
    return !listEquals(layout, oldDelegate.layout);
  }
}

/// Delegate that interpolates between layouts during animation.
/// Used for slide animation type.
class _SlideFlowDelegate extends FlowDelegate {
  _SlideFlowDelegate({
    required this.currentLayout,
    this.previousLayout,
    required this.animation,
  }) : super(repaint: animation);

  final List<BentoLayoutResult> currentLayout;
  final List<BentoLayoutResult>? previousLayout;
  final Animation<double> animation;

  @override
  void paintChildren(FlowPaintingContext context) {
    for (int i = 0; i < context.childCount; i++) {
      final current = _findResult(currentLayout, i);
      if (current == null) continue;

      Offset position = current.position;
      if (previousLayout != null && animation.value < 1.0) {
        final previous = _findResult(previousLayout!, i) ?? current;
        position = Offset.lerp(
          previous.position,
          current.position,
          animation.value,
        )!;
      }

      context.paintChild(
        i,
        transform: Matrix4.translationValues(position.dx, position.dy, 0),
      );
    }
  }

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    final current = _findResult(currentLayout, i);
    if (current == null) return BoxConstraints.tight(Size.zero);

    if (previousLayout == null || animation.value >= 1.0) {
      return BoxConstraints.tight(current.size);
    }

    final previous = _findResult(previousLayout!, i) ?? current;
    final interpolatedSize = Size.lerp(
      previous.size,
      current.size,
      animation.value,
    )!;
    return BoxConstraints.tight(interpolatedSize);
  }

  BentoLayoutResult? _findResult(
    List<BentoLayoutResult> results,
    int index,
  ) {
    for (final r in results) {
      if (r.index == index) return r;
    }
    return null;
  }

  @override
  Size getSize(BoxConstraints constraints) => constraints.biggest;

  @override
  bool shouldRepaint(_SlideFlowDelegate oldDelegate) => true;

  @override
  bool shouldRelayout(_SlideFlowDelegate oldDelegate) {
    return animation.value != oldDelegate.animation.value ||
        !listEquals(currentLayout, oldDelegate.currentLayout);
  }
}

/// A bento grid that fills 100% of available space.
///
/// Items are sized based on their [TBentoItem.size] values relative to
/// each other. Larger sizes get proportionally more area.
///
/// Example: If items have sizes [4, 2, 2, 2], total is 10.
/// - Item 1 gets 40% of area (4/10)
/// - Items 2-4 each get 20% of area (2/10)
///
/// The layout algorithm (squarified treemap) automatically arranges items
/// to minimize aspect ratio distortion while guaranteeing 100% space fill.
class TBentoGrid extends StatefulWidget {
  const TBentoGrid({
    super.key,
    required this.items,
    this.spacing = 8.0,
    this.animation = TBentoGridAnimation.fade,
    this.animationDuration = const Duration(milliseconds: 225),
    this.animationCurve = Curves.easeInOut,
    this.debounceDuration = const Duration(milliseconds: 225),
    this.maxHeight,
    this.maxWidth,
    this.baseHeight = 480,
    this.multiplierThreshold = 3,
    this.calculatedMinHeight = 280,
    this.calculatedMaxHeight,
  });

  /// The items to display in the grid.
  final List<TBentoItem> items;

  /// Spacing between items.
  final double spacing;

  /// The animation type to use for layout transitions.
  final TBentoGridAnimation animation;

  /// Duration of the animation.
  final Duration animationDuration;

  /// Curve of the animation.
  final Curve animationCurve;

  /// How long to wait after changes stop before recalculating layout.
  /// Only used for [TBentoGridAnimation.fade] and [TBentoGridAnimation.scale].
  final Duration debounceDuration;

  final double? maxHeight;
  final double? maxWidth;

  final double baseHeight;
  final int multiplierThreshold;
  final double calculatedMinHeight;
  final double? calculatedMaxHeight;

  @override
  State<TBentoGrid> createState() => _TBentoGridState();
}

class _TBentoGridState extends State<TBentoGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  Timer? _debounceTimer;
  List<BentoLayoutResult>? _currentLayout;
  List<BentoLayoutResult>? _previousLayout;
  Size? _lastSize;
  List<double>? _lastSizes;
  double? _lastSpacing;

  bool _isWaitingForStability = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    );

    if (widget.animation == TBentoGridAnimation.slide) {
      _controller.addListener(_onAnimationTick);
    }
  }

  void _onAnimationTick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_onAnimationTick);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TBentoGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animationDuration != oldWidget.animationDuration) {
      _controller.duration = widget.animationDuration;
    }
    if (widget.animationCurve != oldWidget.animationCurve) {
      _animation = CurvedAnimation(
        parent: _controller,
        curve: widget.animationCurve,
      );
    }
    if (widget.animation != oldWidget.animation) {
      _controller.removeListener(_onAnimationTick);
      if (widget.animation == TBentoGridAnimation.slide) {
        _controller.addListener(_onAnimationTick);
      }
    }
  }

  bool _hasLayoutChanged(
    Size availableSize,
    List<double> sizes,
    double spacing,
  ) {
    if (_currentLayout == null) return true;
    if (_lastSize != availableSize) return true;
    if (_lastSpacing != spacing) return true;
    if (_lastSizes == null || _lastSizes!.length != sizes.length) return true;
    for (int i = 0; i < sizes.length; i++) {
      if (_lastSizes![i] != sizes[i]) return true;
    }
    return false;
  }

  void _updateLayoutImmediate(
    Size availableSize,
    List<double> sizes,
    double spacing,
  ) {
    final newLayout = BentoLayoutCalculator.calculate(
      sizes: sizes,
      availableSize: availableSize,
      spacing: spacing,
    );

    _previousLayout = _currentLayout;
    _currentLayout = newLayout;
    _lastSize = availableSize;
    _lastSizes = List.from(sizes);
    _lastSpacing = spacing;
  }

  void _onLayoutChangedSlide(
    Size availableSize,
    List<double> sizes,
    double spacing,
  ) {
    if (!_hasLayoutChanged(availableSize, sizes, spacing)) return;

    setState(() {
      _updateLayoutImmediate(availableSize, sizes, spacing);
    });

    if (_previousLayout != null) {
      _controller.forward(from: 0);
    }
  }

  void _onLayoutChangedDebounced(
    Size availableSize,
    List<double> sizes,
    double spacing,
  ) {
    _debounceTimer?.cancel();

    if (!_isWaitingForStability) {
      _isWaitingForStability = true;
      _controller.reverse();
    }

    _debounceTimer = Timer(widget.debounceDuration, () {
      if (!mounted) return;

      setState(() {
        _updateLayoutImmediate(availableSize, sizes, spacing);
        _isWaitingForStability = false;
      });

      _controller.forward();
    });
  }

  void _onLayoutChangedNone(
    Size availableSize,
    List<double> sizes,
    double spacing,
  ) {
    if (!_hasLayoutChanged(availableSize, sizes, spacing)) return;

    setState(() {
      _updateLayoutImmediate(availableSize, sizes, spacing);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return TCalculatedHeight(
      count: widget.items.length,
      baseHeight: widget.baseHeight,
      multiplierThreshold: widget.multiplierThreshold,
      minHeight: widget.calculatedMinHeight,
      maxHeight: widget.calculatedMaxHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableSize = Size(
            widget.maxWidth ?? constraints.maxWidth,
            widget.maxHeight ?? (constraints.hasBoundedHeight ? constraints.maxHeight : 400),
          );

          final sizes = widget.items.map((item) => item.size).toList();
          final spacing = widget.spacing;

          if (_currentLayout == null) {
            _updateLayoutImmediate(availableSize, sizes, spacing);
            if (widget.animation == TBentoGridAnimation.fade ||
                widget.animation == TBentoGridAnimation.scale) {
              _controller.value = 1.0;
            }
          }

          if (_hasLayoutChanged(availableSize, sizes, spacing)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              switch (widget.animation) {
                case TBentoGridAnimation.slide:
                  _onLayoutChangedSlide(availableSize, sizes, spacing);
                case TBentoGridAnimation.fade:
                case TBentoGridAnimation.scale:
                  _onLayoutChangedDebounced(availableSize, sizes, spacing);
                case TBentoGridAnimation.none:
                  _onLayoutChangedNone(availableSize, sizes, spacing);
              }
            });
          }

          return SizedBox(
            width: availableSize.width,
            height: availableSize.height,
            child: _BentoGridAnimatedContent(
              animation: _animation,
              animationType: widget.animation,
              currentLayout: _currentLayout!,
              previousLayout: _previousLayout,
              items: widget.items,
            ),
          );
        },
      ),
    );
  }
}

class _BentoGridAnimatedContent extends StatelessWidget {
  const _BentoGridAnimatedContent({
    required this.animation,
    required this.animationType,
    required this.currentLayout,
    required this.items,
    this.previousLayout,
  });

  final Animation<double> animation;
  final TBentoGridAnimation animationType;
  final List<BentoLayoutResult> currentLayout;
  final List<BentoLayoutResult>? previousLayout;
  final List<TBentoItem> items;

  @override
  Widget build(BuildContext context) {
    final flow = Flow(
      delegate: animationType == TBentoGridAnimation.slide
          ? _SlideFlowDelegate(
              currentLayout: currentLayout,
              previousLayout: previousLayout,
              animation: animation,
            )
          : _StaticFlowDelegate(layout: currentLayout),
      children: items
          .map((item) => RepaintBoundary(child: item.child))
          .toList(),
    );

    return switch (animationType) {
      TBentoGridAnimation.slide => flow,
      TBentoGridAnimation.fade => FadeTransition(
        opacity: animation,
        child: flow,
      ),
      TBentoGridAnimation.scale => ScaleTransition(
        scale: animation,
        child: flow,
      ),
      TBentoGridAnimation.none => flow,
    };
  }
}
