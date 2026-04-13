import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/theme/t_sizes.dart';
import 'package:turbo_widgets/src/widgets/content/t_cta_bar_action_card.dart';

class TCtaBarScrollable extends StatefulWidget {
  const TCtaBarScrollable({
    super.key,
    required this.itemCount,
    required this.labelBuilder,
    required this.iconBuilder,
    required this.onActionPressed,
    required this.minTouchTarget,
  });

  final int itemCount;
  final String Function(int index) labelBuilder;
  final IconData Function(int index) iconBuilder;
  final void Function(int index) onActionPressed;
  final double minTouchTarget;

  @override
  State<TCtaBarScrollable> createState() => _TCtaBarScrollableState();
}

class _TCtaBarScrollableState extends State<TCtaBarScrollable> {
  late final ScrollController _controller;

  bool _fadeLeft = false;
  bool _fadeRight = false;
  bool _scrollable = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()..addListener(_updateFade);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFade());
  }

  @override
  void didUpdateWidget(covariant TCtaBarScrollable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateFade());
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_updateFade)
      ..dispose();
    super.dispose();
  }

  void _updateFade() {
    if (!mounted) return;
    if (!_controller.hasClients) {
      setState(() {
        _scrollable = false;
        _fadeLeft = false;
        _fadeRight = false;
      });
      return;
    }
    final position = _controller.position;
    final maxExtent = position.maxScrollExtent;
    final scrollable = maxExtent > 0;
    final fadeLeft = scrollable && position.pixels > 0;
    final fadeRight = scrollable && position.pixels < maxExtent;
    setState(() {
      _scrollable = scrollable;
      _fadeLeft = fadeLeft;
      _fadeRight = fadeRight;
    });
  }

  @override
  Widget build(BuildContext context) {
    const fadePx = TSizes.elementGap;

    Widget list = ListView.separated(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: TSizes.elementGap),
      itemCount: widget.itemCount,
      separatorBuilder: (_, __) => const SizedBox(width: TSizes.itemGap),
      itemBuilder: (context, index) {
        return TCtaBarActionCard(
          key: ValueKey<int>(index),
          label: widget.labelBuilder(index),
          icon: widget.iconBuilder(index),
          minTouchTarget: widget.minTouchTarget,
          onPressed: () => widget.onActionPressed(index),
        );
      },
    );

    if (_scrollable && (_fadeLeft || _fadeRight)) {
      list = ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) {
          final leftOpaque = !_fadeLeft ? 1.0 : 0.0;
          final rightOpaque = !_fadeRight ? 1.0 : 0.0;
          final t = fadePx / bounds.width;
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color.fromARGB((255 * leftOpaque).round(), 255, 255, 255),
              Colors.white,
              Colors.white,
              Color.fromARGB((255 * rightOpaque).round(), 255, 255, 255),
            ],
            stops: [
              0,
              t.clamp(0.01, 0.49),
              (1 - t).clamp(0.51, 0.99),
              1,
            ],
          ).createShader(bounds);
        },
        child: list,
      );
    }

    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateFade());
        return false;
      },
      child: list,
    );
  }
}
