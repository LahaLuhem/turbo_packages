import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/constants/t_durations.dart';
import 'package:turbo_widgets/src/extensions/t_color_extension.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/models/list_progress_model.dart';
import 'package:turbo_widgets/src/theme/t_gradient.dart';

class TProgressBar extends StatelessWidget {
  const TProgressBar({
    super.key,
    required this.progressModel,
    required this.scrolledPixels,
    this.maxWidth,
  });

  final ListProgressModel progressModel;
  final double scrolledPixels;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    // Calculate available width
    final availableWidth = maxWidth ?? context.maxWidth - 40;
    const appBarDistance = 96;
    const progressBarDistance = appBarDistance + kToolbarHeight;
    final percentage =
        1 -
        (scrolledPixels.clamp(0, progressBarDistance) / progressBarDistance);

    return Container(
      margin: EdgeInsets.only(
        top: percentage * 0,
        left: percentage * 20,
        right: percentage * 20,
      ),
      height: 24,
      // Container with fixed width for background
      width: availableWidth,
      decoration: BoxDecoration(
        color: context.colors.card,
        boxShadow: context.decorations.shadowBottomNavigation,
        border: Border(
          left: BorderSide(
            color: context.colors.cardBorder,
            width: percentage * 1,
          ),
          right: BorderSide(
            color: context.colors.cardBorder,
            width: percentage * 1,
          ),
          top: BorderSide(
            color: context.colors.cardBorder,
            width: percentage * 1,
          ),
          bottom: BorderSide(
            color: context.colors.cardBorder,
            width: 0.5 + 0.5 * percentage,
          ),
        ),
        borderRadius: BorderRadius.circular(percentage * 10),
      ),
      alignment: Alignment.centerLeft,
      child: Stack(
        children: [
          // Progress indicator that grows from left
          AnimatedContainer(
            duration: TDurations.animation,
            width:
                progressModel.progressPercentage *
                (availableWidth + (40 * (1 - percentage))),
            height: 24,
            decoration: BoxDecoration(
              gradient: TGradient.topCenter(
                colors: context.colors.primaryButtonGradient,
              ),
              borderRadius: BorderRadius.circular(percentage * 10),
            ),
          ),
          // Centered progress text
          Center(
            child: Text(
              progressModel.progressCount,
              style: context.texts.button.copyWith(
                color: context.colors.primary.onColor,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
