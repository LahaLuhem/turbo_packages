import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:turbo_widgets/src/theme/t_colors.dart';

@immutable
class CustomColorScheme extends ShadColorScheme {
  const CustomColorScheme({
    required super.background,
    required super.foreground,
    required super.card,
    required super.cardForeground,
    required super.popover,
    required super.popoverForeground,
    required super.primary,
    required super.primaryForeground,
    required super.secondary,
    required super.secondaryForeground,
    required super.muted,
    required super.mutedForeground,
    required super.accent,
    required super.accentForeground,
    required super.destructive,
    required super.destructiveForeground,
    required super.border,
    required super.input,
    required super.ring,
    required super.selection,
    required this.shell,
  });

  final Color shell;

  const CustomColorScheme.light()
    : shell = TColors.shellLight,
      super(
        background: const Color(0xFFFFFFFF),
        foreground: const Color(0xFF09090B),
        card: const Color(0xFFFFFFFF),
        cardForeground: const Color(0xFF09090B),
        popover: const Color(0xFFFFFFFF),
        popoverForeground: const Color(0xFF09090B),
        primary: const Color(0xFF0891B2),
        primaryForeground: const Color(0xFFFFFFFF),
        secondary: const Color(0xFFF4F4F5),
        secondaryForeground: const Color(0xFF18181B),
        muted: const Color(0xFFF4F4F5),
        mutedForeground: const Color(0xFF71717A),
        accent: const Color(0xFFECFEFF),
        accentForeground: const Color(0xFF09090B),
        destructive: const Color(0xFFEF4444),
        destructiveForeground: const Color(0xFFFFFFFF),
        border: const Color(0xFFE4E4E7),
        input: const Color(0xFFE4E4E7),
        ring: const Color(0xFF0891B2),
        selection: const Color(0xFFCFFAFE),
      );

  const CustomColorScheme.dark()
    : shell = TColors.shellDark,
      super(
        background: const Color(0xFF000000),
        foreground: const Color(0xFFFAFAFA),
        card: const Color(0xFF080808),
        cardForeground: const Color(0xFFFAFAFA),
        popover: const Color(0xFF080808),
        popoverForeground: const Color(0xFFFAFAFA),
        primary: const Color(0xFF07B6D4),
        primaryForeground: const Color(0xFF000000),
        secondary: const Color(0xFF181920),
        secondaryForeground: const Color(0xFFFAFAFA),
        muted: const Color(0xFF181920),
        mutedForeground: const Color(0xFF9FA0A8),
        accent: const Color(0xFF011318),
        accentForeground: const Color(0xFFFAFAFA),
        destructive: const Color(0xFF7F1D1D),
        destructiveForeground: const Color(0xFFFAFAFA),
        border: const Color(0xFF262729),
        input: const Color(0xFF262729),
        ring: const Color(0xFF07B6D4),
        selection: const Color(0xFF164E63),
      );

  @override
  CustomColorScheme copyWith({
    Color? background,
    Color? foreground,
    Color? card,
    Color? cardForeground,
    Color? popover,
    Color? popoverForeground,
    Color? primary,
    Color? primaryForeground,
    Color? secondary,
    Color? secondaryForeground,
    Color? muted,
    Color? mutedForeground,
    Color? accent,
    Color? accentForeground,
    Color? destructive,
    Color? destructiveForeground,
    Color? border,
    Color? input,
    Color? ring,
    Color? selection,
    Map<String, Color>? custom,
    Color? shell,
  }) {
    return CustomColorScheme(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      card: card ?? this.card,
      cardForeground: cardForeground ?? this.cardForeground,
      popover: popover ?? this.popover,
      popoverForeground: popoverForeground ?? this.popoverForeground,
      primary: primary ?? this.primary,
      primaryForeground: primaryForeground ?? this.primaryForeground,
      secondary: secondary ?? this.secondary,
      secondaryForeground: secondaryForeground ?? this.secondaryForeground,
      muted: muted ?? this.muted,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      accent: accent ?? this.accent,
      accentForeground: accentForeground ?? this.accentForeground,
      destructive: destructive ?? this.destructive,
      destructiveForeground:
          destructiveForeground ?? this.destructiveForeground,
      border: border ?? this.border,
      input: input ?? this.input,
      ring: ring ?? this.ring,
      selection: selection ?? this.selection,
      shell: shell ?? this.shell,
    );
  }
}
