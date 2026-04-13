import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:turbo_widgets/src/theme/t_theme_mode.dart';
import 'package:turbo_widgets/src/typedefs/t_lazy_locator_def.dart';

/// A theme model that provides access to both shadcn and material design themes.
///
/// Lazily initializes theme components when first accessed, using the provided
/// locator functions to resolve dependencies.
class TTheme {
  /// Creates a theme with the specified theme components.
  ///
  /// All parameters are required and should be functions that return the
  /// corresponding theme objects when called.
  TTheme({
    required TLazyLocatorDef<ShadTextTheme> text,
    required TLazyLocatorDef<ShadThemeData> data,
    required TLazyLocatorDef<TThemeMode> mode,
    required TLazyLocatorDef<TextTheme> materialText,
    required TLazyLocatorDef<ThemeData> materialData,
  }) : _data = data,
       _materialData = materialData,
       _materialText = materialText,
       _mode = mode,
       _text = text;

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  final TLazyLocatorDef<ShadTextTheme> _text;
  final TLazyLocatorDef<ShadThemeData> _data;
  final TLazyLocatorDef<TThemeMode> _mode;
  final TLazyLocatorDef<TextTheme> _materialText;
  final TLazyLocatorDef<ThemeData> _materialData;

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  /// The shadcn text theme for typography styling.
  late final ShadTextTheme text = _text();

  /// The shadcn theme data containing colors and other visual properties.
  late final ShadThemeData data = _data();

  /// The current theme mode (light, dark, or system).
  late final TThemeMode mode = _mode();

  /// The Material Design text theme for typography styling.
  late final TextTheme materialText = _materialText();

  /// The Material Design theme data containing colors and other visual properties.
  late final ThemeData materialData = _materialData();
}
