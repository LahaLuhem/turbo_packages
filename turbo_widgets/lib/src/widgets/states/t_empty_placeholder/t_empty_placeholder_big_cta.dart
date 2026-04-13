import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/constants/t_durations.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/theme/t_colors.dart';
import 'package:turbo_widgets/src/theme/t_theme_mode.dart';
import 'package:turbo_widgets/src/widgets/buttons/beam_button/beam_button.dart';
import 'package:turbo_widgets/src/widgets/states/t_empty_placeholder/dashed_border_painter.dart';
import 'package:turbo_widgets/src/widgets/states/t_empty_placeholder/t_empty_placeholder_icon_section.dart';
import 'package:turbo_widgets/src/widgets/states/t_empty_placeholder/t_empty_placeholder_subtitle_section.dart';
import 'package:turbo_widgets/src/widgets/states/t_empty_placeholder/t_empty_placeholder_title_section.dart';

class TEmptyPlaceholderBigCta extends StatefulWidget {
  const TEmptyPlaceholderBigCta({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.icon,
    this.onButtonPressed,
    this.isButtonBusy = false,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final IconData icon;
  final VoidCallback? onButtonPressed;
  final bool isButtonBusy;

  @override
  State<TEmptyPlaceholderBigCta> createState() =>
      _TEmptyPlaceholderBigCtaState();
}

class _TEmptyPlaceholderBigCtaState extends State<TEmptyPlaceholderBigCta>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      duration: TDurations.second,
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_glowController);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.themeMode == TThemeMode.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 640;
        final verticalPadding = isSmall
            ? 64.0
            : (constraints.maxWidth >= 768 ? 128.0 : 96.0);
        final spacingAfterIcon = isSmall ? 24.0 : 32.0;
        final spacingAfterTitle = isSmall ? 8.0 : 12.0;
        final spacingAfterSubtitle = isSmall ? 24.0 : 32.0;

        final bgColor = isDark
            ? TColors.backgroundDark.withValues(alpha: 0.3)
            : TColors.backgroundLight.withValues(alpha: 0.3);
        final borderColor = context.colors.border;

        return CustomPaint(
          foregroundPainter: DashedBorderPainter(color: borderColor),
          child: ColoredBox(
            color: bgColor,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: verticalPadding,
                horizontal: 16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TEmptyPlaceholderIconSection(
                    icon: widget.icon,
                    glowAnimation: _glowAnimation,
                    isSmall: isSmall,
                  ),
                  SizedBox(height: spacingAfterIcon),
                  TEmptyPlaceholderTitleSection(
                    title: widget.title,
                    isSmall: isSmall,
                  ),
                  SizedBox(height: spacingAfterTitle),
                  TEmptyPlaceholderSubtitleSection(
                    subtitle: widget.subtitle,
                    isSmall: isSmall,
                  ),
                  SizedBox(height: spacingAfterSubtitle),
                  if (widget.isButtonBusy) ...[
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.colors.primary,
                      ),
                    ),
                    SizedBox(height: spacingAfterSubtitle),
                  ],
                  BeamButton(
                    label: widget.buttonLabel,
                    onPressed: widget.isButtonBusy ? null : widget.onButtonPressed,
                    disabled: widget.isButtonBusy,
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
