import 'package:turbolytics/turbolytics.dart';

import '../services/mock_content_service.dart';
import '../services/showcase_catalog_service.dart';
import '../../shell/views/showcase_shell/showcase_shell_view_model.dart';
import '../services/theme_service.dart';

/// Composition root for the Turbo Widgets Shop example app.
///
/// Registers all services with GetIt. Call [registerInitialDependencies]
/// once at app startup before [runApp].
class LocatorService with Turbolytics {
  LocatorService._();

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static LocatorService? _instance;
  static LocatorService get locate {
    _instance ??= LocatorService._();
    return _instance!;
  }

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\
  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\
  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\
  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\

  void _registerLazySingletons() {
    ShowcaseCatalogService.registerLazySingleton();
    MockContentService.registerLazySingleton();
    ThemeService.registerLazySingleton();
  }

  void _registerFactories() {
    ShowcaseShellViewModel.registerFactory();
  }

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void registerInitialDependencies() {
    _registerLazySingletons();
    _registerFactories();
  }
}
