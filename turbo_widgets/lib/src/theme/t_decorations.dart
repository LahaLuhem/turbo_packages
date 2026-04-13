import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/responsive/enums/t_device_type.dart';
import 'package:turbo_widgets/src/theme/t_colors.dart';
import 'package:turbo_widgets/src/theme/t_gradient.dart';
import 'package:turbo_widgets/src/theme/t_sizes.dart';
import 'package:turbo_widgets/src/theme/t_theme_mode.dart';

class TDecorations {
  const TDecorations({
    required this.deviceType,
    required this.themeMode,
    required this.colors,
  });

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  final TDeviceType deviceType;
  final TThemeMode themeMode;
  final TColors colors;

  // 🏗 HELPERS ------------------------------------------------------------------------------- \\
  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  List<BoxShadow> get cardShadow => [
    const BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 15,
      spreadRadius: -5,
      offset: Offset(0, 4),
    ),
  ];

  List<BoxShadow> get shadowHard => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 0,
      offset: const Offset(3, 3),
    ),
  ];

  List<BoxShadow> get shadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(2, 0),
    ),
  ];

  List<BoxShadow> get shadowBottomNavigation => onCardShadow;

  List<BoxShadow> get shadowButton => [
    const BoxShadow(
      color: Color(0x10000000),
      blurRadius: 5,
      offset: Offset(4, 2),
    ),
  ];

  // FANCY

  List<BoxShadow> get outerShadow {
    switch (themeMode) {
      case TThemeMode.dark:
      case TThemeMode.light:
        return [
          const BoxShadow(
            color: Color(0x80000000),
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ];
    }
  }

  List<BoxShadow> get bottomNavShadow {
    switch (themeMode) {
      case TThemeMode.dark:
      case TThemeMode.light:
        return [
          BoxShadow(
            blurStyle: BlurStyle.outer,
            color: colors.background,
            blurRadius: 16,
          ),
        ];
    }
  }

  List<BoxShadow> get outerOnCardShadow {
    switch (themeMode) {
      case TThemeMode.dark:
      case TThemeMode.light:
        return [
          const BoxShadow(
            blurStyle: BlurStyle.outer,
            color: Color(0x89000000),
            offset: Offset(0, 2),
          ),
        ];
    }
  }

  List<BoxShadow> get onCardShadow {
    switch (themeMode) {
      case TThemeMode.dark:
      case TThemeMode.light:
        return [
          BoxShadow(
            color: colors.filled.withValues(alpha: 0.7),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ];
    }
  }

  TGradient get topLeftTransparantCardGradient =>
      TGradient.topLeft(colors: colors.transparantCardGradient);

  TGradient get topCenterTransparantCardGradient =>
      TGradient.topCenter(colors: colors.transparantCardGradient);

  TGradient get primaryButtonGradient =>
      TGradient.topCenter(colors: colors.primaryButtonGradient);

  TGradient get secondaryButtonGradient =>
      TGradient.topCenter(colors: colors.secondaryButtonGradient);

  TGradient get topLeftColorCardGradient =>
      TGradient.topLeft(colors: colors.colorCardGradient);

  TGradient get topCenterColorCardGradient =>
      TGradient.topCenter(colors: colors.colorCardGradient);

  BoxBorder get darkBorder => Border.all(
    color: colors.transparantDarkCardBorder,
    width: TSizes.borderWidth,
  );

  BoxBorder get selectedBorder =>
      Border.all(color: colors.focus, width: TSizes.borderWidth);

  BoxBorder get transparantLightBorder => Border.all(
    color: colors.transparantLightCardBorder,
    width: TSizes.borderWidth,
  );

  BoxBorder get solidLightBorder =>
      Border.all(color: colors.solidLightCardBorder, width: TSizes.borderWidth);

  BoxBorder get transparantLightHideBottom => Border(
    top: BorderSide(
      color: colors.transparantLightCardBorder,
      width: TSizes.borderWidth,
    ),
    left: BorderSide(
      color: colors.transparantLightCardBorder,
      width: TSizes.borderWidth,
    ),
    right: BorderSide(
      color: colors.transparantLightCardBorder,
      width: TSizes.borderWidth,
    ),
  );
}
