import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:turbo_notifiers/t_notifier.dart';
import 'package:turbo_widgets/src/abstracts/t_base_router_service_interface.dart';
import 'package:turbo_widgets/src/models/buttons/t_show_bars_config.dart';
import 'package:turbo_widgets/src/responsive/typdefs/device_type_builder_def.dart';
import 'package:turbo_widgets/src/utils/t_min_duration_completer.dart';
import 'package:turbolytics/turbolytics.dart';

class TOverlayButtonsService with Turbolytics {
  TOverlayButtonsService({
    required TBaseRouterServiceInterface baseRouterService,
    this.animationDuration = const Duration(milliseconds: 150),
  }) : _baseRouterService = baseRouterService {
    initialise();
  }

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static TOverlayButtonsService get locate => GetIt.I.get();
  static void registerLazySingleton({
    Duration animationDuration = const Duration(milliseconds: 150),
  }) =>
      GetIt.I.registerLazySingleton(
        () => TOverlayButtonsService(
          baseRouterService: TBaseRouterServiceInterface.locate,
          animationDuration: animationDuration,
        ),
      );

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  final TBaseRouterServiceInterface _baseRouterService;
  final Duration animationDuration;

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  Future<void> initialise() async {
    _baseRouterService.addRouteListener(_tryUpdateBars);
    log.debug('TOverlayButtonsService.initialised()');
  }

  void dispose() {
    _baseRouterService.removeRouteListener(_tryUpdateBars);
  }

  // 👂 LISTENERS ----------------------------------------------------------------------------- \\

  Future<void> _tryUpdateBars(String route) async {
    final normalizedRoute = _normalizeRoute(route);
    try {
      _isUpdatingBars = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) async {
          log.debug(
            'Trying to update overlay buttons for route: $normalizedRoute',
          );
          if (_showBarsConfig.value.showNavigationBar) {
            await _withMinAnimationDuration(
              () => hide(hideNavigationBar: true),
            );
          }

          _navigationBar = _activeNavigationBars[normalizedRoute];

          await _withMinAnimationDuration(
            () => show(showNavigationBar: true),
          );
          _isUpdatingBars = false;
        },
      );
    } catch (error, stackTrace) {
      _isUpdatingBars = false;
      log.error(
        '$error caught while updating overlay buttons for route $normalizedRoute',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  // ⚡️ OVERRIDES ----------------------------------------------------------------------------- \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\

  DeviceTypeBuilderDef? _navigationBar;

  final _showBarsConfig = TNotifier<TShowBarsConfig>(
    TShowBarsConfig(showNavigationBar: true),
  );

  final Map<String, DeviceTypeBuilderDef?> _activeNavigationBars = {};

  late final _animationDurationCompleter = TMinDurationCompleter(
    animationDuration,
  );
  bool _isUpdatingBars = false;

  // 🛠 UTIL ---------------------------------------------------------------------------------- \\
  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  DeviceTypeBuilderDef? get navigationBar => _navigationBar;

  ValueListenable<TShowBarsConfig> get showBarsConfig => _showBarsConfig;

  // 🏗️ HELPERS ------------------------------------------------------------------------------- \\

  String _normalizeRoute(String route) {
    final path = Uri.parse(route).path;
    if (path.isEmpty) return '/';
    return path == '/' ? path : path.replaceFirst(RegExp(r'/$'), '');
  }

  Future<void> _withMinAnimationDuration(
    FutureOr<void> Function() action,
  ) async {
    log.trace('_withMinAnimationDuration: Start');
    try {
      _animationDurationCompleter.start();
      await action();
    } catch (error, stackTrace) {
      log.error(
        '$error caught while performing action with minimum animation duration',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      await _animationDurationCompleter.future;
      log.trace('_withMinAnimationDuration: End');
    }
  }

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void add({
    DeviceTypeBuilderDef? navigationBar,
    required String route,
    bool forceUpdate = false,
  }) {
    final normalizedRoute = _normalizeRoute(route);
    log.debug(
      'Adding bars for route: $normalizedRoute, forceUpdate: $forceUpdate',
    );
    _activeNavigationBars[normalizedRoute] = navigationBar;
    final normalizedCurrent = _normalizeRoute(
      _baseRouterService.currentRoute,
    );
    if (!_isUpdatingBars &&
        (forceUpdate || normalizedRoute == normalizedCurrent)) {
      _tryUpdateBars(_baseRouterService.currentRoute);
    }
  }

  void remove({
    required String route,
  }) {
    final normalizedRoute = _normalizeRoute(route);
    log.debug('Removing bars for route: $normalizedRoute');
    _activeNavigationBars.remove(normalizedRoute);
  }

  Future<void> show({
    required bool showNavigationBar,
    bool doNotifyListeners = true,
  }) async {
    log.debug(
      'SHOW | showNavigationBar: $showNavigationBar, doNotifyListeners: $doNotifyListeners',
    );
    _showBarsConfig.updateCurrent(
      (cValue) => cValue.copyWith(
        showNavigationBar: showNavigationBar,
      ),
      doNotifyListeners: doNotifyListeners,
    );
  }

  Future<void> hide({
    bool hideNavigationBar = true,
    bool doNotifyListeners = true,
  }) async {
    _showBarsConfig.updateCurrent(
      (cValue) => cValue.copyWith(
        showNavigationBar: !hideNavigationBar ? null : false,
      ),
      doNotifyListeners: doNotifyListeners,
    );
  }
}
