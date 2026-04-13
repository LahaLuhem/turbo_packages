import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/constants/t_durations.dart';
import 'package:turbo_widgets/src/theme/t_sizes.dart';
import 'package:turbo_widgets/src/widgets/content/t_cta_bar_scrollable.dart';

/// Horizontal bar of medium-sized action cards (larger than `TBigChip` chips).
///
/// Primitive/builder API for stable references from the parent.
class TCtaBar extends StatelessWidget {
  const TCtaBar({
    super.key,
    required this.itemCount,
    required this.labelBuilder,
    required this.iconBuilder,
    required this.onActionPressed,
  });

  final int itemCount;
  final String Function(int index) labelBuilder;
  final IconData Function(int index) iconBuilder;
  final void Function(int index) onActionPressed;

  static const double _minTouchTarget = 48;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: TDurations.animation,
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: itemCount <= 0
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: TSizes.textGap),
              child: TCtaBarScrollable(
                itemCount: itemCount,
                labelBuilder: labelBuilder,
                iconBuilder: iconBuilder,
                onActionPressed: onActionPressed,
                minTouchTarget: _minTouchTarget,
              ),
            ),
    );
  }
}
