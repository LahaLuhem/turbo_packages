import 'package:flutter/widgets.dart';
import 'package:turbo_widgets/src/models/t_contextual_buttons_config.dart';
import 'package:turbo_widgets/src/responsive/enums/t_device_type.dart';

/// Provides contextual button configurations keyed by route enum.
///
/// Place this at the app root to provide button configurations for all routes.
/// Each route maps to a [TViewButtonsConfig] that defines device-specific
/// button configurations.
///
/// Example:
/// ```dart
/// ContextualButtonsProvider<MyRoute>(
///   contextualButtonBuilders: {
///     MyRoute.home: TViewButtonsConfig<HomeViewModel>(
///       desktop: (context, model) => TContextualButtonsConfig(
///         top: (context) => [MyAppBar(onAction: model.doSomething)],
///       ),
///       mobile: (context, model) => TContextualButtonsConfig(
///         bottom: (context) => [BottomNav()],
///       ),
///     ),
///   },
///   child: MyApp(),
/// )
/// ```
class ContextualButtonsProvider<ROUTE extends Enum> extends InheritedWidget {
  const ContextualButtonsProvider({
    super.key,
    required this.contextualButtonBuilders,
    required super.child,
  });

  /// Map of route to button configuration builders.
  final Map<ROUTE, TViewButtonsConfig> contextualButtonBuilders;

  /// Gets the provider from context, returning null if not found.
  static ContextualButtonsProvider<R>? maybeOf<R extends Enum>(
    BuildContext context,
  ) {
    return context
        .dependOnInheritedWidgetOfExactType<ContextualButtonsProvider<R>>();
  }

  /// Gets the provider from context, throwing if not found.
  static ContextualButtonsProvider<R> of<R extends Enum>(BuildContext context) {
    final provider = maybeOf<R>(context);
    assert(
      provider != null,
      'No ContextualButtonsProvider<$R> found in context',
    );
    return provider!;
  }

  @override
  bool updateShouldNotify(
    covariant ContextualButtonsProvider<ROUTE> oldWidget,
  ) => contextualButtonBuilders != oldWidget.contextualButtonBuilders;
}

/// Device-aware button configuration.
///
/// Provides builders for mobile, tablet, and desktop that return
/// [TContextualButtonsConfig] for the specific device type.
///
/// Tablet falls back to desktop if not specified.
class TViewButtonsConfig<T> {
  const TViewButtonsConfig({
    this.mobile,
    this.tablet,
    this.desktop,
  });

  /// Button config builder for mobile devices.
  final TContextualButtonsConfig Function(BuildContext context, T model)?
  mobile;

  /// Button config builder for tablet devices.
  /// Falls back to [desktop] if not specified.
  final TContextualButtonsConfig Function(BuildContext context, T model)?
  tablet;

  /// Button config builder for desktop devices.
  final TContextualButtonsConfig Function(BuildContext context, T model)?
  desktop;

  /// Returns the builder for the given device type.
  /// Tablet falls back to desktop if tablet builder is not specified.
  TContextualButtonsConfig Function(BuildContext context, T model)? builderFor(
    TDeviceType deviceType,
  ) {
    switch (deviceType) {
      case TDeviceType.mobile:
        return mobile;
      case TDeviceType.tablet:
        return tablet ?? desktop;
      case TDeviceType.desktop:
        return desktop;
    }
  }
}
