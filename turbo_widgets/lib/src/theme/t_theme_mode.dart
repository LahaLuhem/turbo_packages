import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TThemeMode {
  dark,
  light;

  bool get isDark => this == TThemeMode.dark;
  bool get isLight => this == TThemeMode.light;

  ThemeMode get materialThemeMode {
    switch (this) {
      case TThemeMode.light:
        return ThemeMode.light;
      case TThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  SystemUiOverlayStyle get systemUiOverlayStyle {
    switch (this) {
      case TThemeMode.light:
        return SystemUiOverlayStyle.dark;
      case TThemeMode.dark:
        return SystemUiOverlayStyle.light;
    }
  }

  ThemeMode get themeMode {
    switch (this) {
      case TThemeMode.light:
        return ThemeMode.light;
      case TThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  static const TThemeMode defaultValue = TThemeMode.dark;
}
