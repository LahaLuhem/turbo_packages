import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';

/// Owns the app-wide brightness state (light/dark mode).
///
/// Registered as a lazy singleton. Views observe [brightness] via
/// [ValueListenableBuilder]; the top app bar calls [toggleBrightness]
/// to flip between light and dark.
class ThemeService {
  ThemeService();

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static ThemeService get locate => GetIt.I<ThemeService>();

  static void registerLazySingleton() {
    GetIt.I.registerLazySingleton<ThemeService>(() => ThemeService());
  }

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\
  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final TNotifier<Brightness> _brightness = TNotifier<Brightness>(
    Brightness.light,
  );

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// The current brightness mode, observable by views.
  ValueListenable<Brightness> get brightness => _brightness;

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  /// Flips between [Brightness.light] and [Brightness.dark].
  void toggleBrightness() {
    _brightness.value =
        _brightness.value == Brightness.light
            ? Brightness.dark
            : Brightness.light;
  }
}
