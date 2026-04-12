import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:turbo_widgets/src/enums/t_contextual_position.dart';
import 'package:turbo_widgets/src/models/t_contextual_buttons_config.dart';

/// Service interface for managing contextual buttons state.
///
/// Provides reactive state management through [ValueListenable] pattern,
/// allowing widgets to listen to configuration changes and update accordingly.
///
/// Supports scoped button configurations where:
/// - Persistent buttons (scope: null) are always visible
/// - Scoped buttons only contribute when their scope matches [activeScope]
abstract class TContextualButtonsServiceInterface extends ChangeNotifier
    implements ValueListenable<TContextualButtonsConfig> {
  /// Current configuration value.
  @override
  TContextualButtonsConfig get value;

  /// Currently active scope for scoped buttons.
  Object? get activeScope;

  /// Sets the active scope for scoped buttons.
  ///
  /// When the active scope changes, the effective configuration is recomputed
  /// to include only persistent buttons and buttons matching the new scope.
  void setActiveScope(Object? scope, {bool doNotifyListeners = true});

  /// Pushes button configuration for a specific scope and owner.
  ///
  /// - [scope]: The scope for these buttons. Use null for persistent buttons
  ///   that should always be visible regardless of active scope.
  /// - [owner]: Unique identifier for the source of these buttons. Used to
  ///   remove buttons when the owner disposes.
  /// - [config]: The button configuration to push.
  void pushButtons({
    Object? scope,
    required Object owner,
    required TContextualButtonsConfig config,
    bool doNotifyListeners = true,
  });

  /// Removes buttons for a specific scope and owner.
  void removeButtons({
    Object? scope,
    required Object owner,
    bool doNotifyListeners = true,
  });

  /// Clears all buttons for a specific scope.
  ///
  /// If [scope] is null, clears persistent buttons.
  void clearButtons({Object? scope, bool doNotifyListeners = true});

  /// Updates the base configuration settings directly.
  ///
  /// Base settings like [allowFilter], [positionOverrides], [hiddenPositions],
  /// and animation settings are applied on top of merged pushed configs.
  void update(
    TContextualButtonsConfig config, {
    bool doNotifyListeners = true,
  });

  /// Updates the base configuration using an updater function.
  void updateWith(
    TContextualButtonsConfig Function(TContextualButtonsConfig current)
    updater, {
    bool doNotifyListeners = true,
  });

  /// Updates the configuration with animated transitions.
  ///
  /// When [animated] is true, the implementation may coordinate any
  /// extra transition behavior in addition to the widget-level animations.
  ///
  /// [positionsToAnimate] specifies which positions to animate (defaults to all).
  Future<void> updateContextualButtons(
    TContextualButtonsConfig Function(TContextualButtonsConfig current)
    updater, {
    bool doNotifyListeners = true,
    bool animated = true,
    Set<TContextualPosition>? positionsToAnimate,
  });

  /// Hides all buttons by adding all positions to hiddenPositions.
  void hideAllButtons({bool doNotifyListeners = true});

  /// Shows all buttons by clearing hiddenPositions.
  void showAllButtons({bool doNotifyListeners = true});

  /// Hides a specific position by adding it to hiddenPositions.
  void hidePosition(
    TContextualPosition position, {
    bool doNotifyListeners = true,
  });

  /// Shows a specific position by removing it from hiddenPositions.
  void showPosition(
    TContextualPosition position, {
    bool doNotifyListeners = true,
  });

  /// Resets the configuration to empty (no buttons shown).
  void reset({bool doNotifyListeners = true});
}
