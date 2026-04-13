import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/constants/t_durations.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/theme/t_sizes.dart';

enum TFancyCardBackground {
  topLeftTransparantGradient,
  topLeftColorGradient,
  topCenterTransparantGradient,
  topCenterColorGradient,
  redGradient,
  blueGradient,
  appBackground,
  transparant,
}

enum TFancyCardBorder {
  none,
  transparantLight,
  transparantLightHideBottom,
  solidLight,
  dark,
  selected,
  icon,
}

class TFancyCard extends StatelessWidget {
  const TFancyCard({
    Key? key,
    required this.child,
    this.borderRadius = TSizes.cardRadius,
    this.clipBehavior = Clip.none,
    this.height,
    this.width,
    this.margin,
    this.padding,
    this.background = TFancyCardBackground.topLeftTransparantGradient,
    this.border = TFancyCardBorder.transparantLight,
    this.constraints,
  }) : super(key: key);

  final double borderRadius;
  final Clip clipBehavior;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? height;
  final double? width;
  final Widget child;
  final TFancyCardBackground background;
  final TFancyCardBorder border;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) => Container(
    margin: margin,
    constraints: constraints,
    height: height,
    width: width,
    padding: padding,
    clipBehavior: clipBehavior,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: context.decorations.outerShadow,
      color: switch (background) {
        TFancyCardBackground.appBackground => context.colors.background,
        (_) => null,
      },
      gradient: switch (background) {
        TFancyCardBackground.topLeftTransparantGradient =>
          context.decorations.topLeftTransparantCardGradient,
        TFancyCardBackground.topCenterTransparantGradient =>
          context.decorations.topCenterTransparantCardGradient,
        TFancyCardBackground.redGradient =>
          context.decorations.primaryButtonGradient,
        TFancyCardBackground.blueGradient =>
          context.decorations.secondaryButtonGradient,
        TFancyCardBackground.transparant => null,
        TFancyCardBackground.topLeftColorGradient =>
          context.decorations.topLeftColorCardGradient,
        TFancyCardBackground.topCenterColorGradient =>
          context.decorations.topCenterColorCardGradient,
        TFancyCardBackground.appBackground => null,
      },
      border: switch (border) {
        TFancyCardBorder.transparantLight =>
          context.decorations.transparantLightBorder,
        TFancyCardBorder.solidLight => context.decorations.solidLightBorder,
        TFancyCardBorder.dark => context.decorations.darkBorder,
        TFancyCardBorder.selected => context.decorations.selectedBorder,
        TFancyCardBorder.none => null,
        TFancyCardBorder.transparantLightHideBottom =>
          context.decorations.transparantLightHideBottom,
        TFancyCardBorder.icon => Border.all(
          color: context.colors.focus,
          strokeAlign: BorderSide.strokeAlignInside,
          width: TSizes.borderWidth,
        ),
      },
    ),
    child: child,
  );
}

class TFancyAnimatedCard extends StatelessWidget {
  const TFancyAnimatedCard({
    Key? key,
    required this.child,
    this.borderRadius = TSizes.cardRadius,
    this.clipBehavior = Clip.none,
    this.height,
    this.width,
    this.margin,
    this.padding,
    this.background = TFancyCardBackground.topLeftTransparantGradient,
    this.border = TFancyCardBorder.transparantLight,
    this.duration = TDurations.animation,
  }) : super(key: key);

  final double borderRadius;
  final Clip clipBehavior;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? height;
  final double? width;
  final Widget child;
  final TFancyCardBackground background;
  final TFancyCardBorder border;
  final Duration duration;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: duration,
    margin: margin,
    height: height,
    width: width,
    padding: padding,
    clipBehavior: clipBehavior,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: context.decorations.outerShadow,
      color: switch (background) {
        TFancyCardBackground.appBackground => context.colors.background,
        (_) => null,
      },
      gradient: switch (background) {
        TFancyCardBackground.topLeftTransparantGradient =>
          context.decorations.topLeftTransparantCardGradient,
        TFancyCardBackground.topCenterTransparantGradient =>
          context.decorations.topCenterTransparantCardGradient,
        TFancyCardBackground.redGradient =>
          context.decorations.primaryButtonGradient,
        TFancyCardBackground.blueGradient =>
          context.decorations.secondaryButtonGradient,
        TFancyCardBackground.transparant => null,
        TFancyCardBackground.topLeftColorGradient =>
          context.decorations.topLeftColorCardGradient,
        TFancyCardBackground.topCenterColorGradient =>
          context.decorations.topCenterColorCardGradient,
        TFancyCardBackground.appBackground => null,
      },
      border: switch (border) {
        TFancyCardBorder.transparantLight =>
          context.decorations.transparantLightBorder,
        TFancyCardBorder.solidLight => context.decorations.solidLightBorder,
        TFancyCardBorder.dark => context.decorations.darkBorder,
        TFancyCardBorder.selected => context.decorations.selectedBorder,
        TFancyCardBorder.none => null,
        TFancyCardBorder.transparantLightHideBottom =>
          context.decorations.transparantLightHideBottom,
        TFancyCardBorder.icon => Border.all(
          color: context.colors.focus,
          strokeAlign: BorderSide.strokeAlignInside,
          width: 1,
        ),
      },
    ),
    child: child,
  );
}
