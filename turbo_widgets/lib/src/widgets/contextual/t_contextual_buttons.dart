import 'dart:async';
import 'dart:collection';
import 'package:flutter/widgets.dart';
import 'package:turbo_widgets/src/abstracts/t_contextual_buttons_service_interface.dart';
import 'package:turbo_widgets/src/enums/t_contextual_allow_filter.dart';
import 'package:turbo_widgets/src/enums/t_contextual_position.dart';
import 'package:turbo_widgets/src/models/t_contextual_buttons_config.dart';
import 'package:turbo_widgets/src/services/t_contextual_buttons_service.dart';

/// A widget that displays contextual buttons at configurable positions
/// (top, bottom, left, right) as overlays on top of the main content.
///
/// Content at each position animates with per-widget granularity:
/// widgets with stable keys across config changes remain in place,
/// new widgets animate in, and removed widgets animate out.
///
/// Configuration is managed through [TContextualButtonsService]. By default,
/// uses the singleton [TContextualButtonsService.instance]. Pass a custom
/// service to use a different instance.
///
/// Example:
/// ```dart
/// TContextualButtons(
///   child: mainContent,
/// )
///
/// // Configure buttons via service
/// TContextualButtonsService.instance.update(
///   TContextualButtonsConfig(
///     top: (context) => [AppBar(...)],
///     bottom: (context) => [BottomNavBar(...)],
///   ),
/// );
/// ```
class TContextualButtons extends StatelessWidget {
  const TContextualButtons({
    required this.child,
    super.key,
    this.service,
  });

  /// The main content that fills the wrapper.
  final Widget child;

  /// Optional service instance. If not provided, uses the singleton
  /// [TContextualButtonsService.instance].
  final TContextualButtonsServiceInterface? service;

  @override
  Widget build(BuildContext context) {
    final effectiveService = service ?? TContextualButtonsService.instance;

    return ValueListenableBuilder<TContextualButtonsConfig>(
      valueListenable: effectiveService,
      child: child,
      builder: (context, config, child) => _TContextualButtonsAnimated(
        child: child!,
        config: config,
      ),
    );
  }
}

enum _AnimationPhase { idle, animatingOut, animatingIn }

class _TContextualButtonsAnimated extends StatefulWidget {
  const _TContextualButtonsAnimated({
    required this.child,
    required this.config,
  });

  final Widget child;
  final TContextualButtonsConfig config;

  @override
  State<_TContextualButtonsAnimated> createState() =>
      _TContextualButtonsAnimatedState();
}

class _TContextualButtonsAnimatedState
    extends State<_TContextualButtonsAnimated>
    with TickerProviderStateMixin {
  /// Per-widget animation controllers, keyed by widget identity key.
  final Map<Object, AnimationController> _widgetControllers = {};

  /// Per-widget animation phases, keyed by widget identity key.
  final Map<Object, _AnimationPhase> _widgetPhases = {};

  /// Currently displayed widgets per position (includes stable + animating-out).
  Map<TContextualPosition, List<Widget>> _displayedContent = {};

  /// Widgets that are animating out (kept visible until animation completes).
  final Map<TContextualPosition, List<Widget>> _animatingOutWidgets = {};

  final Queue<Map<TContextualPosition, List<Widget>>> _pendingQueue = Queue();
  bool _isAnimating = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _displayedContent = _ContentResolver.resolve(widget.config, context);
  }

  @override
  void didUpdateWidget(_TContextualButtonsAnimated oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newContent = _ContentResolver.resolve(widget.config, context);
    if (!_contentMapsEqual(_displayedContent, newContent)) {
      _enqueueAnimation(newContent);
    } else {
      _displayedContent = newContent;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    for (final controller in _widgetControllers.values) {
      controller.dispose();
    }
    _widgetControllers.clear();
    super.dispose();
  }

  Duration get _halfDuration => Duration(
    milliseconds: widget.config.animationDuration.inMilliseconds ~/ 2,
  );

  void _enqueueAnimation(Map<TContextualPosition, List<Widget>> newContent) {
    _pendingQueue.add(newContent);
    if (!_isAnimating) {
      _processNextAnimation();
    }
  }

  Future<void> _processNextAnimation() async {
    if (_pendingQueue.isEmpty || _isDisposed) {
      _isAnimating = false;
      return;
    }

    _isAnimating = true;
    final newContent = _pendingQueue.removeFirst();

    await _animateContentChanges(newContent);

    if (!_isDisposed && mounted) {
      unawaited(_processNextAnimation());
    }
  }

  bool _contentMapsEqual(
    Map<TContextualPosition, List<Widget>> a,
    Map<TContextualPosition, List<Widget>> b,
  ) {
    for (final position in TContextualPosition.values) {
      if (!_listKeyEquals(a[position] ?? const [], b[position] ?? const [])) {
        return false;
      }
    }
    return true;
  }

  Object _widgetIdentityKey(Widget widget) => widget.key ?? widget;

  bool _listKeyEquals(List<Widget> a, List<Widget> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (_widgetIdentityKey(a[i]) != _widgetIdentityKey(b[i])) return false;
    }
    return true;
  }

  AnimationController _getOrCreateController(Object key) {
    return _widgetControllers.putIfAbsent(
      key,
      () => AnimationController(duration: _halfDuration, vsync: this),
    );
  }

  void _disposeController(Object key) {
    _widgetControllers.remove(key)?.dispose();
    _widgetPhases.remove(key);
  }

  Future<void> _animateContentChanges(
    Map<TContextualPosition, List<Widget>> newContent,
  ) async {
    if (_isDisposed) return;

    final widgetsToAnimateOut = <Object, Widget>{};
    final widgetsToAnimateIn = <Object, Widget>{};
    final stableKeys = <Object>{};

    for (final position in TContextualPosition.values) {
      final oldWidgets = _displayedContent[position] ?? const [];
      final newWidgets = newContent[position] ?? const [];

      final oldKeyMap = <Object, Widget>{
        for (final w in oldWidgets) _widgetIdentityKey(w): w,
      };
      final newKeyMap = <Object, Widget>{
        for (final w in newWidgets) _widgetIdentityKey(w): w,
      };

      for (final key in oldKeyMap.keys) {
        if (newKeyMap.containsKey(key)) {
          stableKeys.add(key);
        } else {
          widgetsToAnimateOut[key] = oldKeyMap[key]!;
        }
      }

      for (final key in newKeyMap.keys) {
        if (!oldKeyMap.containsKey(key)) {
          widgetsToAnimateIn[key] = newKeyMap[key]!;
        }
      }
    }

    // Snapshot removed widgets per position before updating displayed content.
    final removedPerPosition = <TContextualPosition, List<Widget>>{};
    if (widgetsToAnimateOut.isNotEmpty) {
      for (final position in TContextualPosition.values) {
        final oldWidgets = _displayedContent[position] ?? const [];
        final removedFromPosition = <Widget>[];
        for (final w in oldWidgets) {
          final key = _widgetIdentityKey(w);
          if (widgetsToAnimateOut.containsKey(key)) {
            removedFromPosition.add(w);
          }
        }
        if (removedFromPosition.isNotEmpty) {
          removedPerPosition[position] = removedFromPosition;
        }
      }
    }

    // Update displayed content to stable + removed widgets only.
    // Exclude widgets that need to animate in — they get added in Phase 2
    // to prevent them flashing at full opacity during the out-animation.
    _displayedContent = {
      for (final position in TContextualPosition.values)
        position: (newContent[position] ?? const [])
            .where(
              (w) => !widgetsToAnimateIn.containsKey(_widgetIdentityKey(w)),
            )
            .toList(),
    };

    // Phase 1: Animate out removed widgets (in parallel)
    if (widgetsToAnimateOut.isNotEmpty) {
      _animatingOutWidgets.addAll(removedPerPosition);

      final outFutures = <Future<void>>[];
      for (final entry in widgetsToAnimateOut.entries) {
        final controller = _getOrCreateController(entry.key);
        controller.duration = _halfDuration;
        controller.reset();
        _widgetPhases[entry.key] = _AnimationPhase.animatingOut;
        outFutures.add(controller.forward().orCancel.catchError((_) {}));
      }

      if (mounted && !_isDisposed) setState(() {});

      await Future.wait(outFutures);

      if (!mounted || _isDisposed) return;

      for (final key in widgetsToAnimateOut.keys) {
        _disposeController(key);
      }
      _animatingOutWidgets.clear();
    }

    // Add in-animation widgets to displayed content now that out-animation
    // is complete. They start hidden (controller at 0, animatingIn phase).
    if (widgetsToAnimateIn.isNotEmpty) {
      _displayedContent = {
        for (final position in TContextualPosition.values)
          position: newContent[position] ?? const [],
      };
    }

    // Phase 2: Animate in new widgets (in parallel)
    if (widgetsToAnimateIn.isNotEmpty) {
      final inFutures = <Future<void>>[];
      for (final entry in widgetsToAnimateIn.entries) {
        final controller = _getOrCreateController(entry.key);
        controller.duration = _halfDuration;
        controller.reset();
        _widgetPhases[entry.key] = _AnimationPhase.animatingIn;
        inFutures.add(controller.forward().orCancel.catchError((_) {}));
      }

      if (mounted && !_isDisposed) setState(() {});

      await Future.wait(inFutures);

      if (!mounted || _isDisposed) return;

      // Reset phases to idle
      for (final key in widgetsToAnimateIn.keys) {
        _widgetPhases[key] = _AnimationPhase.idle;
      }
    }

    // Ensure all phases are idle
    for (final key in _widgetPhases.keys.toList()) {
      _widgetPhases[key] = _AnimationPhase.idle;
    }

    if (mounted && !_isDisposed) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: RepaintBoundary(
            child: _TPositionContent(
              widgets: _displayedContent[TContextualPosition.top] ?? const [],
              animatingOutWidgets:
                  _animatingOutWidgets[TContextualPosition.top] ?? const [],
              position: TContextualPosition.top,
              widgetPhases: _widgetPhases,
              widgetControllers: _widgetControllers,
              curve: config.animationCurve,
              widgetIdentityKey: _widgetIdentityKey,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: RepaintBoundary(
            child: _TPositionContent(
              widgets:
                  _displayedContent[TContextualPosition.bottom] ?? const [],
              animatingOutWidgets:
                  _animatingOutWidgets[TContextualPosition.bottom] ?? const [],
              position: TContextualPosition.bottom,
              widgetPhases: _widgetPhases,
              widgetControllers: _widgetControllers,
              curve: config.animationCurve,
              widgetIdentityKey: _widgetIdentityKey,
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          bottom: 0,
          child: RepaintBoundary(
            child: _TPositionContent(
              widgets: _displayedContent[TContextualPosition.left] ?? const [],
              animatingOutWidgets:
                  _animatingOutWidgets[TContextualPosition.left] ?? const [],
              position: TContextualPosition.left,
              widgetPhases: _widgetPhases,
              widgetControllers: _widgetControllers,
              curve: config.animationCurve,
              widgetIdentityKey: _widgetIdentityKey,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          bottom: 0,
          child: RepaintBoundary(
            child: _TPositionContent(
              widgets: _displayedContent[TContextualPosition.right] ?? const [],
              animatingOutWidgets:
                  _animatingOutWidgets[TContextualPosition.right] ?? const [],
              position: TContextualPosition.right,
              widgetPhases: _widgetPhases,
              widgetControllers: _widgetControllers,
              curve: config.animationCurve,
              widgetIdentityKey: _widgetIdentityKey,
            ),
          ),
        ),
      ],
    );
  }
}

/// Separates content resolution logic from animation orchestration.
class _ContentResolver {
  const _ContentResolver._();

  static Map<TContextualPosition, List<Widget>> resolve(
    TContextualButtonsConfig config,
    BuildContext context,
  ) {
    var result = _buildInitialStructure(config, context);
    result = _applyPositionOverrides(result, config);
    result = _applyAllowFilter(result, config);
    result = _applyHiddenPositions(result, config);
    return result;
  }

  static Map<TContextualPosition, List<Widget>> _buildInitialStructure(
    TContextualButtonsConfig config,
    BuildContext context,
  ) {
    return {
      TContextualPosition.top: config.top(context),
      TContextualPosition.bottom: config.bottom(context),
      TContextualPosition.left: config.left(context),
      TContextualPosition.right: config.right(context),
    };
  }

  static Map<TContextualPosition, List<Widget>> _applyPositionOverrides(
    Map<TContextualPosition, List<Widget>> input,
    TContextualButtonsConfig config,
  ) {
    final result = <TContextualPosition, List<Widget>>{
      for (final position in TContextualPosition.values)
        position: List.from(input[position]!),
    };

    for (final entry in config.positionOverrides.entries) {
      final source = entry.key;
      final target = entry.value;

      final sourceContent = result[source] ?? const [];
      if (sourceContent.isNotEmpty) {
        result[target] = [
          ...(result[target] ?? const []),
          ...sourceContent,
        ];
        result[source] = const [];
      }
    }

    return result;
  }

  static Map<TContextualPosition, List<Widget>> _applyAllowFilter(
    Map<TContextualPosition, List<Widget>> input,
    TContextualButtonsConfig config,
  ) {
    if (config.allowFilter == TContextualAllowFilter.all) {
      return input;
    }

    final targetPosition = TContextualPosition.values.firstWhere(
      (p) => p.name == config.allowFilter.name,
    );

    final allContent = <Widget>[
      ...input[TContextualPosition.top] ?? const [],
      ...input[TContextualPosition.bottom] ?? const [],
      ...input[TContextualPosition.left] ?? const [],
      ...input[TContextualPosition.right] ?? const [],
    ];

    return {
      for (final position in TContextualPosition.values)
        position: position == targetPosition ? allContent : const [],
    };
  }

  static Map<TContextualPosition, List<Widget>> _applyHiddenPositions(
    Map<TContextualPosition, List<Widget>> input,
    TContextualButtonsConfig config,
  ) {
    return {
      for (final position in TContextualPosition.values)
        position: config.hiddenPositions.contains(position)
            ? const []
            : input[position]!,
    };
  }
}

/// Renders content for a position with per-widget animation.
///
/// Each widget gets its own independent animation wrapper (fade + slide)
/// based on its current phase. Stable widgets render without animation.
/// For bottom/top positions, groups stack perpendicular to the edge
/// (primary closest to edge, secondary inward).
/// For left/right positions, groups stack perpendicular to the edge
/// (primary closest to edge, secondary inward).
class _TPositionContent extends StatelessWidget {
  const _TPositionContent({
    required this.widgets,
    required this.animatingOutWidgets,
    required this.position,
    required this.widgetPhases,
    required this.widgetControllers,
    required this.curve,
    required this.widgetIdentityKey,
  });

  final List<Widget> widgets;
  final List<Widget> animatingOutWidgets;
  final TContextualPosition position;
  final Map<Object, _AnimationPhase> widgetPhases;
  final Map<Object, AnimationController> widgetControllers;
  final Curve curve;
  final Object Function(Widget) widgetIdentityKey;

  bool get _isTopOrBottom =>
      position == TContextualPosition.top ||
      position == TContextualPosition.bottom;

  /// The axis along which multiple groups stack (perpendicular to the edge).
  Axis get _stackAxis => _isTopOrBottom ? Axis.vertical : Axis.horizontal;

  /// Whether to reverse the stack order so primary is closest to the edge.
  bool get _reverseStack =>
      position == TContextualPosition.bottom ||
      position == TContextualPosition.right;

  Offset _getSlideOffset() {
    switch (position) {
      case TContextualPosition.top:
        return const Offset(0, -1);
      case TContextualPosition.bottom:
        return const Offset(0, 1);
      case TContextualPosition.left:
        return const Offset(-1, 0);
      case TContextualPosition.right:
        return const Offset(1, 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allWidgets = [
      ...widgets,
      ...animatingOutWidgets,
    ];

    if (allWidgets.isEmpty) {
      return const SizedBox.shrink();
    }

    final children = <Widget>[];
    for (final w in allWidgets) {
      final key = widgetIdentityKey(w);
      final phase = widgetPhases[key] ?? _AnimationPhase.idle;
      final controller = widgetControllers[key];

      if (phase == _AnimationPhase.idle || controller == null) {
        children.add(w);
      } else {
        children.add(
          _AnimatedWidgetWrapper(
            widget: w,
            phase: phase,
            controller: controller,
            curve: curve,
            slideOffset: _getSlideOffset(),
          ),
        );
      }
    }

    final orderedChildren = _reverseStack
        ? children.reversed.toList()
        : children;

    return Semantics(
      container: true,
      liveRegion: true,
      label: '${position.name} contextual content',
      child: Flex(
        direction: _stackAxis,
        mainAxisSize: MainAxisSize.min,
        children: orderedChildren,
      ),
    );
  }
}

/// Wraps a single widget with fade + slide animation based on its phase.
class _AnimatedWidgetWrapper extends StatelessWidget {
  const _AnimatedWidgetWrapper({
    required this.widget,
    required this.phase,
    required this.controller,
    required this.curve,
    required this.slideOffset,
  });

  final Widget widget;
  final _AnimationPhase phase;
  final AnimationController controller;
  final Curve curve;
  final Offset slideOffset;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: phase != _AnimationPhase.idle,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final curvedValue = curve.transform(controller.value);

          final double opacity;
          final Offset offset;

          switch (phase) {
            case _AnimationPhase.idle:
              opacity = 1.0;
              offset = Offset.zero;
            case _AnimationPhase.animatingOut:
              opacity = 1.0 - curvedValue;
              offset = Offset(
                slideOffset.dx * curvedValue,
                slideOffset.dy * curvedValue,
              );
            case _AnimationPhase.animatingIn:
              opacity = curvedValue;
              offset = Offset(
                slideOffset.dx * (1.0 - curvedValue),
                slideOffset.dy * (1.0 - curvedValue),
              );
          }

          return Opacity(
            opacity: opacity,
            child: FractionalTranslation(
              translation: offset,
              child: child,
            ),
          );
        },
        child: widget,
      ),
    );
  }
}
