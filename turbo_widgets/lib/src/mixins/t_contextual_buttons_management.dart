import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:turbo_widgets/src/abstracts/t_contextual_buttons_service_interface.dart';
import 'package:turbo_widgets/src/enums/t_contextual_position.dart';
import 'package:turbo_widgets/src/models/t_contextual_buttons_config.dart';
import 'package:turbo_widgets/src/services/t_contextual_buttons_service.dart';

/// Mixin that provides convenient methods for managing contextual buttons.
///
/// By default, uses the singleton [TContextualButtonsService.instance].
/// Override [contextualButtonsService] to use a custom service instance.
///
/// Example:
/// ```dart
/// class MyViewModel with TContextualButtonsManagement {
///   // Uses default singleton service
///   void showTopButtons() {
///     setTopWidgets([MyButton()]);
///   }
/// }
///
/// class MyCustomViewModel with TContextualButtonsManagement {
///   // Uses custom service instance
///   @override
///   TContextualButtonsServiceInterface get contextualButtonsService => _myService;
///
///   final _myService = TContextualButtonsService();
/// }
/// ```
mixin TContextualButtonsManagement {
  /// The service instance to use for managing contextual buttons.
  ///
  /// Override this getter to provide a custom service instance.
  /// Defaults to the singleton [TContextualButtonsService.instance].
  TContextualButtonsServiceInterface get contextualButtonsService =>
      TContextualButtonsService.instance;

  /// Current configuration value from the service.
  TContextualButtonsConfig get contextualButtonsConfig =>
      contextualButtonsService.value;

  /// Updates the configuration directly.
  void setContextualButtonsConfig(
    TContextualButtonsConfig config, {
    bool doNotifyListeners = true,
  }) {
    contextualButtonsService.update(
      config,
      doNotifyListeners: doNotifyListeners,
    );
  }

  /// Updates the configuration using an updater function.
  void updateContextualButtonsConfig(
    TContextualButtonsConfig Function(TContextualButtonsConfig current)
    updater, {
    bool doNotifyListeners = true,
  }) {
    contextualButtonsService.updateWith(
      updater,
      doNotifyListeners: doNotifyListeners,
    );
  }

  /// Updates the configuration with animated transitions.
  ///
  /// See [TContextualButtonsServiceInterface.updateContextualButtons] for details.
  Future<void> updateContextualButtonsAnimated(
    TContextualButtonsConfig Function(TContextualButtonsConfig current)
    updater, {
    bool doNotifyListeners = true,
    bool animated = true,
    Set<TContextualPosition>? positionsToAnimate,
  }) {
    return contextualButtonsService.updateContextualButtons(
      updater,
      doNotifyListeners: doNotifyListeners,
      animated: animated,
      positionsToAnimate: positionsToAnimate,
    );
  }

  /// Hides all buttons.
  void hideAllButtons({bool doNotifyListeners = true}) {
    contextualButtonsService.hideAllButtons(
      doNotifyListeners: doNotifyListeners,
    );
  }

  /// Shows all buttons.
  void showAllButtons({bool doNotifyListeners = true}) {
    contextualButtonsService.showAllButtons(
      doNotifyListeners: doNotifyListeners,
    );
  }

  /// Hides a specific position.
  void hidePosition(
    TContextualPosition position, {
    bool doNotifyListeners = true,
  }) {
    contextualButtonsService.hidePosition(
      position,
      doNotifyListeners: doNotifyListeners,
    );
  }

  /// Shows a specific position.
  void showPosition(
    TContextualPosition position, {
    bool doNotifyListeners = true,
  }) {
    contextualButtonsService.showPosition(
      position,
      doNotifyListeners: doNotifyListeners,
    );
  }

  /// Resets the configuration to empty.
  void clearContextualButtons({bool doNotifyListeners = true}) {
    contextualButtonsService.reset(doNotifyListeners: doNotifyListeners);
  }

  /// Sets widgets for a specific position.
  void setPositionWidgets(
    TContextualPosition position,
    List<Widget> widgets, {
    bool doNotifyListeners = true,
  }) {
    updateContextualButtonsConfig(
      (config) {
        switch (position) {
          case TContextualPosition.top:
            return config.copyWith(top: (_) => widgets);
          case TContextualPosition.bottom:
            return config.copyWith(bottom: (_) => widgets);
          case TContextualPosition.left:
            return config.copyWith(left: (_) => widgets);
          case TContextualPosition.right:
            return config.copyWith(right: (_) => widgets);
        }
      },
      doNotifyListeners: doNotifyListeners,
    );
  }

  /// Clears widgets for a specific position.
  void clearPosition(
    TContextualPosition position, {
    bool doNotifyListeners = true,
  }) {
    setPositionWidgets(
      position,
      const [],
      doNotifyListeners: doNotifyListeners,
    );
  }

  /// Sets widgets for top position.
  void setTopWidgets(List<Widget> widgets, {bool doNotifyListeners = true}) {
    setPositionWidgets(
      TContextualPosition.top,
      widgets,
      doNotifyListeners: doNotifyListeners,
    );
  }

  /// Sets widgets for bottom position.
  void setBottomWidgets(List<Widget> widgets, {bool doNotifyListeners = true}) {
    setPositionWidgets(
      TContextualPosition.bottom,
      widgets,
      doNotifyListeners: doNotifyListeners,
    );
  }

  /// Sets widgets for left position.
  void setLeftWidgets(List<Widget> widgets, {bool doNotifyListeners = true}) {
    setPositionWidgets(
      TContextualPosition.left,
      widgets,
      doNotifyListeners: doNotifyListeners,
    );
  }

  /// Sets widgets for right position.
  void setRightWidgets(List<Widget> widgets, {bool doNotifyListeners = true}) {
    setPositionWidgets(
      TContextualPosition.right,
      widgets,
      doNotifyListeners: doNotifyListeners,
    );
  }
}
