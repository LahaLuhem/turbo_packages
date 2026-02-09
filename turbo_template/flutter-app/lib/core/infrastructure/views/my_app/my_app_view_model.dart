import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:turbo_flutter_template/core/analytics/models/analytics_implementation.dart';
import 'package:turbo_flutter_template/core/analytics/models/crash_reports_implementation.dart';
import 'package:turbo_flutter_template/core/auth/analytics/user_analytics.dart';
import 'package:turbo_flutter_template/core/auth/services/auth_service.dart';
import 'package:turbo_flutter_template/core/connection/services/connection_service.dart';
import 'package:turbo_flutter_template/core/environment/config/emulator_config.dart';
import 'package:turbo_flutter_template/core/environment/enums/environment.dart';
import 'package:turbo_flutter_template/core/infrastructure/enums/t_route.dart';
import 'package:turbo_flutter_template/core/infrastructure/services/base_router_service.dart';
import 'package:turbo_flutter_template/core/infrastructure/services/locator_service.dart';
import 'package:turbo_flutter_template/core/infrastructure/services/package_info_service.dart';
import 'package:turbo_flutter_template/core/state/manage-state/abstracts/t_view_model.dart';
import 'package:turbo_flutter_template/core/state/manage-state/models/contextual_button_entry.dart';
import 'package:turbo_flutter_template/core/state/manage-state/typedefs/lazy_locator_def.dart';
import 'package:turbo_flutter_template/core/storage/save-local-data/services/local_storage_service.dart';
import 'package:turbo_flutter_template/core/ui/enums/t_theme_mode.dart';
import 'package:turbo_flutter_template/core/ui/services/theme_service.dart';
import 'package:turbo_flutter_template/core/ux/enums/t_supported_language.dart';
import 'package:turbo_flutter_template/core/ux/services/language_service.dart';
import 'package:turbo_flutter_template/core/ux/services/shake_gesture_service.dart';
import 'package:turbo_flutter_template/core/ux/services/toast_service.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbolytics/turbolytics.dart';
import 'package:url_strategy/url_strategy.dart';

class MyAppViewModel extends TViewModel with Turbolytics {
  MyAppViewModel({
    required LazyLocatorDef<BaseRouterService> baseRouterService,
    required LazyLocatorDef<TBusyService> busyService,
    required LazyLocatorDef<ConnectionService> connectionService,
    required LazyLocatorDef<PackageInfoService> packageInfoService,
    required LocatorService locatorService,
    required LazyLocatorDef<LocalStorageService> localStorageService,
    required LazyLocatorDef<LanguageService> languageService,
    required LazyLocatorDef<AuthService> authService,
    required LazyLocatorDef<ThemeService> themeService,
  }) : _baseRouterService = baseRouterService,
       _busyService = busyService,
       _authService = authService,
       _connectionService = connectionService,
       _packageInfoService = packageInfoService,
       _locatorService = locatorService,
       _localStorageService = localStorageService,
       _languageService = languageService,
       _themeService = themeService;

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static MyAppViewModel get locate => GetIt.I.get();
  static void registerFactory() => GetIt.I.registerFactory(
    () => MyAppViewModel(
      packageInfoService: () => PackageInfoService(),
      baseRouterService: () => BaseRouterService.locate,
      busyService: () => TBusyService.instance(),
      connectionService: () => ConnectionService.locate,
      languageService: () => LanguageService.locate,
      themeService: () => ThemeService.locate,
      locatorService: LocatorService.locate,
      localStorageService: () => LocalStorageService.locate,
      authService: () => AuthService.locate,
    ),
  );

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  final LazyLocatorDef<BaseRouterService> _baseRouterService;
  final LazyLocatorDef<TBusyService> _busyService;
  final LazyLocatorDef<ConnectionService> _connectionService;
  final LazyLocatorDef<PackageInfoService> _packageInfoService;
  final LocatorService _locatorService;
  final LazyLocatorDef<LocalStorageService> _localStorageService;
  final LazyLocatorDef<LanguageService> _languageService;
  final LazyLocatorDef<ThemeService> _themeService;
  final LazyLocatorDef<AuthService> _authService;
  late final _shakeGestureService = ShakeGestureService.locate;

  BaseRouterService get baseRouterService => _baseRouterService();
  TBusyService get busyService => _busyService();

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    log.info('Initialising app..');
    WidgetsFlutterBinding.ensureInitialized();

    // Firebase is initialized in main.dart before runApp
    // Only initialize if not already done (e.g., during Phoenix.rebirth)
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: Environment.current.firebaseOptions,
      );
    }

    await EmulatorConfig.tryConfigureEmulators();

    await _trySetCurrentVersion();
    await _setupStrings();
    await _setupTurbolytics();
    if (kIsWeb) {
      setPathUrlStrategy();
    }
    _locatorService.registerSingletons();
    Animate.restartOnHotReload = true;
    Provider.debugCheckInvalidValueType = null;
    await _initEssentials();
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  // 👂 LISTENERS ----------------------------------------------------------------------------- \\
  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\

  TRoute? get contextualButtonsRoute => null;

  List<ContextualButtonEntry> get contextualButtons => const [];

  // 🎩 STATE --------------------------------------------------------------------------------- \\
  // 🛠 UTIL ---------------------------------------------------------------------------------- \\
  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  LazyLocatorDef<ToastService> get lazyToastService =>
      () => ToastService.locate;
  GoRouter get coreRouter => baseRouterService.coreRouter;
  ValueListenable<TBusyModel> get busyListenable =>
      busyService.isBusyListenable;
  ValueListenable<TSupportedLanguage> get language =>
      _languageService().language;
  ValueListenable<TThemeMode> get themeMode =>
      _themeService().themeModeListenable;
  ValueListenable<bool> get hasInternetConnection =>
      _connectionService().hasInternetConnection;

  // 🏗 HELPERS ------------------------------------------------------------------------------- \\
  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  Future<void> _initEssentials() async {
    await _authService().isReady;
    await _localStorageService().isReady;
    await _handleEnvironmentChange();
    await _languageService().isReady;
  }

  Future<void> _handleEnvironmentChange() async {
    final localStorageService = _localStorageService();
    final currentEnvironment = Environment.current.name;
    final lastEnvironment = localStorageService.lastEnvironment;

    if (lastEnvironment != null && lastEnvironment != currentEnvironment) {
      log.info(
        'Environment changed from $lastEnvironment to $currentEnvironment. Signing out user.',
      );
      // Update before logout; logout triggers GetIt.reset and disposes services.
      await localStorageService.updateLastEnvironment(
        environment: currentEnvironment,
      );
      await FirebaseAuth.instance.signOut();
      return;
    }

    await localStorageService.updateLastEnvironment(
      environment: currentEnvironment,
    );
  }

  Future<void> _trySetCurrentVersion() async {
    try {
      final packageInfoService = _packageInfoService;
      Environment.currentVersion = await packageInfoService().version;
    } catch (error, stackTrace) {
      log.error(
        'Unexpected ${error.runtimeType} caught while trying to set current version!',
        error: error,
        stackTrace: stackTrace,
      );
      Environment.currentVersion = '0.1.0';
    }
  }

  Future<void> _setupTurbolytics() async {
    try {
      if (Turbolytics.isActive) {
        await Turbolytics.disposeMe();
      }
      Turbolytics.setUp(
        logLevel: TLogLevel.debug,
        logTime: false,
        addAnalyticsToCrashReports: true,
        maxLinesStackTrace: 100,
        analyticsInterface: AnalyticsImplementation(),
        crashReportsInterface: CrashReportsImplementation(),
        analytics: (analyticsFactory) {
          analyticsFactory.registerAnalytic(() => UserAnalytics());
        },
      );
    } catch (error, stackTrace) {
      log.error(
        '$error caught while setting up Turbolytics!',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _setupStrings() async {
    // Flutter's gen-l10n handles localization automatically through delegates
    // No manual loading needed - the locale is set via MaterialApp.locale
  }

  void onShakeDetected({required BuildContext context}) {
    _shakeGestureService.onShakeDetected(context: context);
  }
}
