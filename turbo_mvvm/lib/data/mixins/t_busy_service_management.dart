import 'package:flutter/foundation.dart';
import 'package:turbo_mvvm/data/constants/turbo_mvvm_defaults.dart';
import 'package:turbo_mvvm/data/enums/t_busy_type.dart';
import 'package:turbo_mvvm/data/models/t_busy_model.dart';
import 'package:turbo_mvvm/services/t_busy_service.dart';

/// Mixin to manage the busy state using [TBusyService].
///
/// Provides utilities to set the busy state with optional title, message,
/// minimum duration and busy type. Also exposes getters for busy title,
/// busy message and busy state itself.
mixin TBusyServiceManagement {
  /// Instance of [TBusyService].
  final TBusyService _busyService = TBusyService.instance();

  /// Sets the busy state.
  ///
  /// [isBusy] The new busy state.
  /// [busyTitle] Optional title for the busy state.
  /// [busyMessage] Optional message for the busy state.
  /// [minBusyDuration] Minimum duration to remain in busy state.
  /// [busyType] Optional busy type.
  void setBusy(
    bool isBusy, {
    String? busyTitle,
    String? busyMessage,
    Duration minBusyDuration = TurboMvvmDefaults.minBusy,
    TBusyType? busyType,
    Duration? timeoutDuration,
    VoidCallback? onTimeout,
    dynamic payload,
  }) => _busyService.setBusy(
    isBusy,
    busyTitle: busyTitle,
    busyMessage: busyMessage,
    minBusyDuration: minBusyDuration,
    busyType: busyType,
    timeoutDuration: timeoutDuration,
    onTimeout: onTimeout,
    payload: payload,
  );

  /// Sets the busy state to idle.
  void setIdle() => _busyService.setBusy(false);

  /// Getter for the busy title.
  String? get busyTitle => _busyService.isBusyListenable.value.busyTitle;

  /// Getter for the busy message.
  String? get busyMessage => _busyService.isBusyListenable.value.busyMessage;

  /// ValueListenable for the busy state.
  ValueListenable<TBusyModel> get isBusyListenable =>
      _busyService.isBusyListenable;

  /// Getter for the busy state.
  bool get isBusy => _busyService.isBusy;

  /// Dispose the [TBusyService] used in this mixin.
  void disposeBusyManagement() => _busyService.dispose();
}
