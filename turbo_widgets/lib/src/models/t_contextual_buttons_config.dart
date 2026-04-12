import 'package:flutter/widgets.dart';
import 'package:turbo_widgets/src/enums/t_contextual_allow_filter.dart';
import 'package:turbo_widgets/src/enums/t_contextual_position.dart';

/// Callback that builds a list of widgets for a contextual position.
typedef TContextualPositionWidgetsBuilder =
    List<Widget> Function(
      BuildContext context,
    );

/// Default empty position builder.
List<Widget> _emptyPosition(BuildContext _) => const [];

/// Configuration model for contextual buttons widget.
///
/// Contains all parameters needed to configure the display of contextual
/// buttons at various positions (top, bottom, left, right).
///
/// Each position uses a [TContextualPositionWidgetsBuilder] callback that
/// receives a [BuildContext] and returns a list of widgets to display.
class TContextualButtonsConfig {
  const TContextualButtonsConfig({
    this.top = _emptyPosition,
    this.bottom = _emptyPosition,
    this.left = _emptyPosition,
    this.right = _emptyPosition,
    this.allowFilter = TContextualAllowFilter.all,
    this.positionOverrides = const {},
    this.hiddenPositions = const {},
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });

  /// Builder for top position widgets.
  final TContextualPositionWidgetsBuilder top;

  /// Builder for bottom position widgets.
  final TContextualPositionWidgetsBuilder bottom;

  /// Builder for left position widgets.
  final TContextualPositionWidgetsBuilder left;

  /// Builder for right position widgets.
  final TContextualPositionWidgetsBuilder right;

  /// Filter to restrict which positions can display content.
  ///
  /// When set to [TContextualAllowFilter.all], all positions are allowed.
  /// When set to a specific position, only that position is allowed.
  final TContextualAllowFilter allowFilter;

  /// Overrides to move content from one position to another.
  ///
  /// Key is the source position, value is the target position.
  /// Content from the source position will be displayed at the target position.
  final Map<TContextualPosition, TContextualPosition> positionOverrides;

  /// Positions that should be hidden (content preserved but not displayed).
  final Set<TContextualPosition> hiddenPositions;

  /// Total duration for the animation (split 50/50 between out and in phases).
  final Duration animationDuration;

  /// Curve applied to both out and in animation phases.
  final Curve animationCurve;

  /// Returns the builder for a specific position.
  TContextualPositionWidgetsBuilder builderFor(TContextualPosition position) {
    switch (position) {
      case TContextualPosition.top:
        return top;
      case TContextualPosition.bottom:
        return bottom;
      case TContextualPosition.left:
        return left;
      case TContextualPosition.right:
        return right;
    }
  }

  /// Creates a copy with updated values.
  TContextualButtonsConfig copyWith({
    TContextualPositionWidgetsBuilder? top,
    TContextualPositionWidgetsBuilder? bottom,
    TContextualPositionWidgetsBuilder? left,
    TContextualPositionWidgetsBuilder? right,
    TContextualAllowFilter? allowFilter,
    Map<TContextualPosition, TContextualPosition>? positionOverrides,
    Set<TContextualPosition>? hiddenPositions,
    Duration? animationDuration,
    Curve? animationCurve,
  }) {
    return TContextualButtonsConfig(
      top: top ?? this.top,
      bottom: bottom ?? this.bottom,
      left: left ?? this.left,
      right: right ?? this.right,
      allowFilter: allowFilter ?? this.allowFilter,
      positionOverrides: positionOverrides ?? this.positionOverrides,
      hiddenPositions: hiddenPositions ?? this.hiddenPositions,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TContextualButtonsConfig &&
          runtimeType == other.runtimeType &&
          top == other.top &&
          bottom == other.bottom &&
          left == other.left &&
          right == other.right &&
          allowFilter == other.allowFilter &&
          _mapEquals(positionOverrides, other.positionOverrides) &&
          _setEquals(hiddenPositions, other.hiddenPositions) &&
          animationDuration == other.animationDuration &&
          animationCurve == other.animationCurve;

  @override
  int get hashCode => Object.hash(
    top,
    bottom,
    left,
    right,
    allowFilter,
    Object.hashAll(positionOverrides.entries),
    Object.hashAll(hiddenPositions),
    animationDuration,
    animationCurve,
  );

  static bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final item in a) {
      if (!b.contains(item)) return false;
    }
    return true;
  }

  static bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
