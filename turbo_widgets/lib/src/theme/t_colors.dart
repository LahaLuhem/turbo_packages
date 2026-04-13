import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:turbo_widgets/src/extensions/t_color_extension.dart';
import 'package:turbo_widgets/src/theme/t_gradient.dart';
import 'package:turbo_widgets/src/theme/t_sizes.dart';
import 'package:turbo_widgets/src/theme/t_theme.dart';
import 'package:turbo_widgets/src/theme/t_theme_mode.dart';

class TColors {
  const TColors({
    required this.context,
    required this.themeMode,
    required this.theme,
  });

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  final BuildContext context;
  final TThemeMode themeMode;
  final TTheme theme;

  // 🎩 STATE --------------------------------------------------------------------------------- \\
  static const primaryLight = Color(0xFF0891B2);
  static const primaryDark = Color(0xFF07B6D4);

  static const secondaryLight = Color(0xFFF4F4F5);
  static const secondaryDark = Color(0xFF181920);

  static const accentLight = Color(0xFFECFEFF);
  static const accentDark = Color(0xFF011318);

  static const backgroundLight = Color(0xFFFFFFFF);
  static const backgroundDark = Color(0xFF000000);

  static const cardLight = Color(0xFFFFFFFF);
  static const cardDark = Color(0xFF080808);

  static const textPrimaryLight = Color(0xFF09090B);
  static const textPrimaryDark = Color(0xFFD4D4D8);

  static const textSecondaryLight = Color(0xFF71717A);
  static const textSecondaryDark = Color(0xFF9FA0A8);

  static const borderLight = Color(0xFFE4E4E7);
  static const borderDark = Color(0xFF262729);

  static const destructiveLight = Color(0xFFEF4444);
  static const destructiveDark = Color(0xFF7F1D1D);

  static const focusLight = Color(0xFF0891B2);
  static const focusDark = Color(0xFF07B6D4);

  static const dialogLight = Color(0xFFFFFFFF);
  static const dialogDark = Color(0xFF080808);

  static const mutedLight = Color(0xFFF4F4F5);
  static const mutedDark = Color(0xFF181920);

  static const headingLight = Color(0xFF09090B);
  static const headingDark = Color(0xFFFAFAFA);

  static const textHintLight = Color(0xFF71717A);
  static const textHintDark = Color(0xFF9FA0A8);

  static const shellLight = Color(0xFFFAFAFA);
  static const shellDark = Color(0xFF000000);

  static const dividerLight = Color(0xFFE4E4E7);
  static const dividerDark = Color(0xFF262729);

  static const iconPrimaryLight = Color(0xFF0891B2);
  static const iconPrimaryDark = Color(0xFF07B6D4);

  static const iconPrimaryBgLight = Color(0xFFF4F4F5);
  static const iconPrimaryBgDark = Color(0xFF181920);

  static const iconSecondaryLight = Color(0xFF71717A);
  static const iconSecondaryDark = Color(0xFF9FA0A8);

  static const iconSecondaryBgLight = Color(0xFFE4E4E7);
  static const iconSecondaryBgDark = Color(0xFF262729);

  static const successLight = Color(0xFF22C55E);
  static const successDark = Color(0xFF4ADE80);

  static const warningLight = Color(0xFFF57C00);
  static const warningDark = Color(0xFFFFB74D);

  static const infoLight = Color(0xFF0288D1);
  static const infoDark = Color(0xFF4FC3F7);

  static const subtitleLight = Color(0xFF71717A);
  static const subtitleDark = Color(0xFF9FA0A8);
  static const captionLight = Color(0xFF71717A);
  static const captionDark = Color(0xFF9FA0A8);
  static const listItemLight = Color(0xFF09090B);
  static const listItemDark = Color(0xFFFAFAFA);
  static const subLabelLight = Color(0xFF71717A);
  static const subLabelDark = Color(0xFF9FA0A8);

  static const overlayLight = Color(0xF2FFFFFF);
  static const overlayDark = Color(0xE609090B);

  static const overlayBorderLight = Color(0x1A000000);
  static const overlayBorderDark = Color(0x1AFFFFFF);

  static const overlayHeaderLight = Color(0x80F5F5F5);
  static const overlayHeaderDark = Color(0x80171717);

  static const overlayTextLight = Color(0xFF52525B);
  static const overlayTextDark = Color(0xFF9CA3AF);

  // 🏗 HELPERS ------------------------------------------------------------------------------- \\

  ShadColorScheme get colorScheme => theme.data.colorScheme;

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  Color get cardBorder => switch (themeMode) {
    TThemeMode.dark => TColors.borderDark,
    TThemeMode.light => TColors.borderLight,
  };

  Color get hover => switch (themeMode) {
    TThemeMode.light => card.onHover,
    TThemeMode.dark => card.onHover,
  };

  Color get secondary => colorScheme.secondary;
  Color get appBar => shell;
  Color get background => colorScheme.background;
  Color get border => colorScheme.border;
  Color get icon => colorScheme.ring;
  Color get input => colorScheme.input;
  Color get focus => colorScheme.selection;
  Color get primary => colorScheme.primary;
  Color get card => colorScheme.card;
  Color get destructive => colorScheme.destructive;

  Color get shell => switch (themeMode) {
    TThemeMode.light => shellLight,
    TThemeMode.dark => shellDark,
  };

  Color get cardMidground {
    switch (themeMode) {
      case TThemeMode.dark:
        return TColors.secondaryDark;
      case TThemeMode.light:
        return card.darken(3);
    }
  }

  Color get success => switch (themeMode) {
    TThemeMode.dark => successDark,
    TThemeMode.light => successLight,
  };

  Color get warning => switch (themeMode) {
    TThemeMode.dark => warningDark,
    TThemeMode.light => warningLight,
  };

  Color get info => switch (themeMode) {
    TThemeMode.dark => infoDark,
    TThemeMode.light => infoLight,
  };

  Color get listItem => switch (themeMode) {
    TThemeMode.dark => listItemDark,
    TThemeMode.light => listItemLight,
  };

  Color get primaryText => switch (themeMode) {
    TThemeMode.light => textPrimaryLight,
    TThemeMode.dark => textPrimaryDark,
  };

  Color get filled => switch (themeMode) {
    TThemeMode.light => card.darken(4),
    TThemeMode.dark => card.darken(4),
  };

  Color get softBorder => switch (themeMode) {
    TThemeMode.light => borderLight,
    TThemeMode.dark => borderDark,
  };

  Color get caption => switch (themeMode) {
    TThemeMode.light => captionLight,
    TThemeMode.dark => captionDark,
  };

  Color get subLabel => switch (themeMode) {
    TThemeMode.light => subLabelLight,
    TThemeMode.dark => subLabelDark,
  };

  Color get divider => switch (themeMode) {
    TThemeMode.light => dividerLight,
    TThemeMode.dark => dividerDark,
  };

  Color get error => switch (themeMode) {
    TThemeMode.light => destructiveLight,
    TThemeMode.dark => destructiveDark,
  };

  Color get dialog => switch (themeMode) {
    TThemeMode.light => dialogLight,
    TThemeMode.dark => dialogDark,
  };

  Color get overlay => switch (themeMode) {
    TThemeMode.dark => overlayDark,
    TThemeMode.light => overlayLight,
  };

  Color get overlayBorder => switch (themeMode) {
    TThemeMode.dark => overlayBorderDark,
    TThemeMode.light => overlayBorderLight,
  };

  Color get overlayHeader => switch (themeMode) {
    TThemeMode.dark => overlayHeaderDark,
    TThemeMode.light => overlayHeaderLight,
  };

  Color get overlayText => switch (themeMode) {
    TThemeMode.dark => overlayTextDark,
    TThemeMode.light => overlayTextLight,
  };

  Color get heading => switch (themeMode) {
    TThemeMode.dark => headingDark,
    TThemeMode.light => headingLight,
  };

  Color get transparantLightCardBorder => border.withValues(alpha: 0.75);
  Color get transparantDarkCardBorder =>
      background.onColor.withValues(alpha: TSizes.opacityDisabled);

  Color get solidLightCardBorder => const Color(0xBF272727);

  // 🖼️ GRADIENTS ----------------------------------------------------------------------------- \\

  List<Color> get primaryButtonGradient => primaryGradient;
  List<Color> get secondaryButtonGradient => secondaryGradient;

  List<Color> get primaryGradient => [primary.lighten(10), primary];

  List<Color> get secondaryGradient => [secondary.lighten(10), secondary];

  List<Color> get transparantCardGradient => [
    Colors.transparent,
    switch (themeMode) {
      TThemeMode.dark => Colors.white.withValues(alpha: 0.03),
      TThemeMode.light => Colors.black.withValues(alpha: 0.03),
    },
  ];

  TGradient get topCenterTransparantCardGradient => TGradient.topCenter(
    colors: [
      Colors.transparent,
      switch (themeMode) {
        TThemeMode.dark => Colors.white.withValues(alpha: 0.03),
        TThemeMode.light => Colors.black.withValues(alpha: 0.03),
      },
    ],
  );

  List<Color> get colorCardGradient => [
    background,
    switch (themeMode) {
      TThemeMode.dark => Colors.white.withValues(alpha: 0.03),
      TThemeMode.light => Colors.black.withValues(alpha: 0.03),
    },
  ];
}
