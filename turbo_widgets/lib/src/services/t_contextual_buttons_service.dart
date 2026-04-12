import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:turbo_widgets/src/abstracts/t_contextual_buttons_service_interface.dart';
import 'package:turbo_widgets/src/enums/t_contextual_position.dart';
import 'package:turbo_widgets/src/models/t_contextual_buttons_config.dart';

/// Service for managing contextual buttons state.
///
/// Extends [TContextualButtonsServiceInterface] and provides a singleton
/// instance for global access. Uses [ChangeNotifier] for manual notification
/// control and implements [ValueListenable] for reactive state management.
///
/// Supports scoped button configurations:
/// - Persistent buttons (scope: null) are always visible
/// - Scoped buttons only contribute when their scope matches [activeScope]
///
/// The singleton instance can be reset for testing via [resetInstance].
class TContextualButtonsService extends TContextualButtonsServiceInterface {
  TContextualButtonsService([TContextualButtonsConfig? initialBaseConfig])
    : _baseConfig = initialBaseConfig ?? const TContextualButtonsConfig() {
    _recomputeValue();
  }

  static TContextualButtonsService? _instance;

  /// Singleton instance.
  ///
  /// Creates a new instance on first access. Use [resetInstance] to clear
  /// the singleton for testing or cleanup purposes.
  static TContextualButtonsService get instance {
    _instance ??= TContextualButtonsService();
    return _instance!;
  }

  /// Resets the singleton instance.
  ///
  /// Disposes the current instance and clears the reference, allowing
  /// a fresh instance to be created on next [instance] access.
  /// Use for testing or when the singleton needs to be completely reset.
  static void resetInstance() {
    _instance?.dispose();
    _instance = null;
  }

  // Base configuration for settings like allowFilter, hiddenPositions, etc.
  TContextualButtonsConfig _baseConfig;

  // Persistent buttons (scope: null) - always contribute to value
  final LinkedHashMap<Object, TContextualButtonsConfig> _persistent =
      LinkedHashMap();

  // Scoped buttons - only contribute when scope matches activeScope
  final Map<Object, LinkedHashMap<Object, TContextualButtonsConfig>> _scoped =
      {};

  Object? _activeScope;
  TContextualButtonsConfig _value = const TContextualButtonsConfig();
  bool _isDisposed = false;
  bool _pendingNotify = false;

  @override
  TContextualButtonsConfig get value => _value;

  @override
  Object? get activeScope => _activeScope;

  @override
  void setActiveScope(Object? scope, {bool doNotifyListeners = true}) {
    if (_isDisposed) return;
    if (_activeScope == scope) return;
    _activeScope = scope;
    _recomputeValue();
    if (doNotifyListeners) {
      _notifyListenersSafely();
    }
  }

  @override
  void pushButtons({
    Object? scope,
    required Object owner,
    required TContextualButtonsConfig config,
    bool doNotifyListeners = true,
  }) {
    if (_isDisposed) return;

    if (scope == null) {
      _persistent[owner] = config;
    } else {
      _scoped.putIfAbsent(scope, () => LinkedHashMap())[owner] = config;
    }

    _recomputeValue();
    if (doNotifyListeners) {
      _notifyListenersSafely();
    }
  }

  @override
  void removeButtons({
    Object? scope,
    required Object owner,
    bool doNotifyListeners = true,
  }) {
    if (_isDisposed) return;

    bool removed = false;
    if (scope == null) {
      removed = _persistent.remove(owner) != null;
    } else {
      final scopedMap = _scoped[scope];
      if (scopedMap != null) {
        removed = scopedMap.remove(owner) != null;
        if (scopedMap.isEmpty) {
          _scoped.remove(scope);
        }
      }
    }

    if (removed) {
      _recomputeValue();
      if (doNotifyListeners) {
        _notifyListenersSafely();
      }
    }
  }

  @override
  void clearButtons({Object? scope, bool doNotifyListeners = true}) {
    if (_isDisposed) return;

    bool cleared = false;
    if (scope == null) {
      if (_persistent.isNotEmpty) {
        _persistent.clear();
        cleared = true;
      }
    } else {
      if (_scoped.remove(scope) != null) {
        cleared = true;
      }
    }

    if (cleared) {
      _recomputeValue();
      if (doNotifyListeners) {
        _notifyListenersSafely();
      }
    }
  }

  /// Recomputes the effective value by merging persistent and active scoped configs.
  void _recomputeValue() {
    final contributors = <TContextualButtonsConfig>[
      ..._persistent.values,
      if (_activeScope != null) ...(_scoped[_activeScope]?.values ?? []),
    ];

    if (contributors.isEmpty) {
      _value = TContextualButtonsConfig(
        top: _baseConfig.top,
        bottom: _baseConfig.bottom,
        left: _baseConfig.left,
        right: _baseConfig.right,
        allowFilter: _baseConfig.allowFilter,
        positionOverrides: _baseConfig.positionOverrides,
        hiddenPositions: _baseConfig.hiddenPositions,
        animationDuration: _baseConfig.animationDuration,
        animationCurve: _baseConfig.animationCurve,
      );
      return;
    }

    _value = TContextualButtonsConfig(
      top: (context) =>
          _mergePosition(contributors, TContextualPosition.top, context),
      bottom: (context) =>
          _mergePosition(contributors, TContextualPosition.bottom, context),
      left: (context) =>
          _mergePosition(contributors, TContextualPosition.left, context),
      right: (context) =>
          _mergePosition(contributors, TContextualPosition.right, context),
      allowFilter: _baseConfig.allowFilter,
      positionOverrides: _baseConfig.positionOverrides,
      hiddenPositions: _baseConfig.hiddenPositions,
      animationDuration: _baseConfig.animationDuration,
      animationCurve: _baseConfig.animationCurve,
    );
  }

  List<Widget> _mergePosition(
    List<TContextualButtonsConfig> configs,
    TContextualPosition position,
    BuildContext context,
  ) {
    final result = <Widget>[];
    for (final config in configs) {
      result.addAll(config.builderFor(position)(context));
    }
    return result;
  }

  @override
  void update(
    TContextualButtonsConfig config, {
    bool doNotifyListeners = true,
  }) {
    if (_isDisposed) return;
    if (_baseConfig == config) return;
    _baseConfig = config;
    _recomputeValue();
    if (doNotifyListeners) {
      _notifyListenersSafely();
    }
  }

  @override
  void updateWith(
    TContextualButtonsConfig Function(TContextualButtonsConfig current)
    updater, {
    bool doNotifyListeners = true,
  }) {
    final newConfig = updater(_baseConfig);
    update(newConfig, doNotifyListeners: doNotifyListeners);
  }

  @override
  Future<void> updateContextualButtons(
    TContextualButtonsConfig Function(TContextualButtonsConfig current)
    updater, {
    bool doNotifyListeners = true,
    bool animated = true,
    Set<TContextualPosition>? positionsToAnimate,
  }) async {
    if (_isDisposed) return;

    final nextConfig = updater(_baseConfig);
    update(nextConfig, doNotifyListeners: doNotifyListeners);
    if (!animated || !doNotifyListeners) {
      return;
    }

    await _animateTransition(
      nextConfig: nextConfig,
      positionsToAnimate: positionsToAnimate,
    );
  }

  /// Orchestrates any additional transition behavior between configurations.
  Future<void> _animateTransition({
    required TContextualButtonsConfig nextConfig,
    Set<TContextualPosition>? positionsToAnimate,
  }) async {
    if (_isDisposed) return;
    await Future<void>.delayed(Duration.zero);
  }

  @override
  void hideAllButtons({bool doNotifyListeners = true}) {
    updateWith(
      (config) => config.copyWith(
        hiddenPositions: TContextualPosition.values.toSet(),
      ),
      doNotifyListeners: doNotifyListeners,
    );
  }

  @override
  void showAllButtons({bool doNotifyListeners = true}) {
    updateWith(
      (config) => config.copyWith(
        hiddenPositions: const {},
      ),
      doNotifyListeners: doNotifyListeners,
    );
  }

  @override
  void hidePosition(
    TContextualPosition position, {
    bool doNotifyListeners = true,
  }) {
    updateWith(
      (config) => config.copyWith(
        hiddenPositions: {...config.hiddenPositions, position},
      ),
      doNotifyListeners: doNotifyListeners,
    );
  }

  @override
  void showPosition(
    TContextualPosition position, {
    bool doNotifyListeners = true,
  }) {
    updateWith(
      (config) {
        final newHidden = {...config.hiddenPositions}..remove(position);
        return config.copyWith(hiddenPositions: newHidden);
      },
      doNotifyListeners: doNotifyListeners,
    );
  }

  @override
  void reset({bool doNotifyListeners = true}) {
    if (_isDisposed) return;
    _baseConfig = const TContextualButtonsConfig();
    _persistent.clear();
    _scoped.clear();
    _activeScope = null;
    _recomputeValue();
    if (doNotifyListeners) {
      _notifyListenersSafely();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pendingNotify = false;
    super.dispose();
  }

  void _notifyListenersSafely() {
    if (_isDisposed) return;
    final phase = SchedulerBinding.instance.schedulerPhase;
    final isBuilding =
        phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks;
    if (!isBuilding) {
      notifyListeners();
      return;
    }
    if (_pendingNotify) return;
    _pendingNotify = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) return;
      _pendingNotify = false;
      notifyListeners();
    });
  }
}
