import 'package:flutter/widgets.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_widgets/src/abstracts/t_contextual_buttons_service_interface.dart';
import 'package:turbo_widgets/src/models/t_contextual_buttons_config.dart';
import 'package:turbo_widgets/src/services/t_contextual_buttons_service.dart';
import 'package:turbo_widgets/src/typedefs/t_view_model_builder_def.dart';
import 'package:turbo_widgets/src/widgets/contextual/t_contextual_buttons.dart';

/// Callback that builds a contextual buttons config from a view model.
typedef TViewContextualButtonsDef<T extends TBaseViewModel> =
    TContextualButtonsConfig? Function(
      BuildContext context,
      T model,
      bool isInitialised,
    );

/// A convenience wrapper that combines [TContextualButtons] and [TViewModelBuilder]
/// for views that need contextual actions.
///
/// This widget wraps [TContextualButtons] around [TViewModelBuilder], exposing all
/// parameters from both widgets for full configurability.
///
/// When [contextualButtonsBuilder] is provided, this widget pushes button
/// configurations to the service, allowing shell-level rendering of buttons
/// defined in individual views.
///
/// Example:
/// ```dart
/// TViewBuilder<MyViewModel>(
///   viewModelBuilder: () => MyViewModel(),
///   builder: (context, viewModel, isInitialised, child) {
///     return MyViewContent(viewModel: viewModel);
///   },
///   contextualButtonsBuilder: (context, model, isInitialised) {
///     if (!isInitialised) return null;
///     return TContextualButtonsConfig(
///       top: (context) => [MyAppBar()],
///     );
///   },
///   contextualButtonsScope: MyRoute.home,
/// )
/// ```
class TViewBuilder<T extends TBaseViewModel> extends StatefulWidget {
  const TViewBuilder({
    required this.builder,
    required this.viewModelBuilder,
    this.contextualButtonsBuilder,
    this.contextualButtonsService,
    this.contextualButtonsScope,
    this.hostContextualButtons = true,
    this.argumentBuilder,
    this.child,
    this.isReactive = TurboMvvmDefaults.isReactive,
    this.minBusyDuration = TurboMvvmDefaults.minBusyAnimation,
    this.contentFadeDuration = TurboMvvmDefaults.animation,
    this.onDispose,
    this.shouldDispose = TurboMvvmDefaults.shouldDispose,
    super.key,
  });

  /// Optional builder for contextual buttons. If provided, builds a config
  /// using the view model and pushes it to the shell-level contextual buttons.
  final TViewContextualButtonsDef<T>? contextualButtonsBuilder;

  /// Optional service instance for contextual buttons.
  /// Defaults to [TContextualButtonsService.instance].
  final TContextualButtonsServiceInterface? contextualButtonsService;

  /// Optional scope for the contextual buttons (e.g., a route enum value).
  /// When set, buttons are scoped and only visible when this scope is active.
  /// When null, buttons are persistent and always visible.
  final Object? contextualButtonsScope;

  /// Whether this widget should host [TContextualButtons] overlay.
  /// Set to false for non-shell views to avoid nested overlays.
  final bool hostContextualButtons;

  /// Child widget that will not rebuild when notifyListeners is called.
  final Widget? child;

  /// Builder method that builds the widget tree.
  final TViewModelBuilderDef<T> builder;

  /// Builder method that provides the [TViewModel].
  final T Function() viewModelBuilder;

  /// Builder method that provides the [TViewModel.initialise] with arguments.
  final dynamic Function()? argumentBuilder;

  /// Whether the [TViewModel] should listen to [TViewModel.notifyListeners] for rebuilds.
  final bool isReactive;

  /// Minimum duration the global busy overlay stays visible during initialisation.
  ///
  /// When non-null, [TBusyService] is set to busy on creation and cleared
  /// after [TBaseViewModel.initialise] completes, with the overlay held for
  /// at least this duration. Content fades in after the overlay has fully
  /// faded out. When `null`, no busy state handling occurs.
  final Duration? minBusyDuration;

  /// Duration of the content fade-in animation after the busy overlay clears.
  final Duration contentFadeDuration;

  /// Whether the [TViewModelBuilder] should dispose the [TViewModel] when
  /// it's removed from the widget tree.
  final bool shouldDispose;

  /// Fires when [TViewModelBuilder] is removed from the widget tree.
  final void Function(T model)? onDispose;

  @override
  State<TViewBuilder<T>> createState() => _TViewBuilderState<T>();
}

class _TViewBuilderState<T extends TBaseViewModel>
    extends State<TViewBuilder<T>> {
  final Object _owner = Object();
  TContextualButtonsConfig? _lastPushedConfig;
  bool _hasPushed = false;

  TContextualButtonsServiceInterface get _service =>
      widget.contextualButtonsService ?? TContextualButtonsService.instance;

  @override
  void dispose() {
    _removeButtons();
    super.dispose();
  }

  void _pushButtons(TContextualButtonsConfig config) {
    _service.pushButtons(
      scope: widget.contextualButtonsScope,
      owner: _owner,
      config: config,
    );
    _lastPushedConfig = config;
    _hasPushed = true;
  }

  void _removeButtons() {
    if (_hasPushed) {
      _service.removeButtons(
        scope: widget.contextualButtonsScope,
        owner: _owner,
      );
      _hasPushed = false;
      _lastPushedConfig = null;
    }
  }

  void _handleViewModelUpdate(
    BuildContext context,
    T model,
    bool isInitialised,
  ) {
    final builder = widget.contextualButtonsBuilder;
    if (builder == null) return;

    final config = builder(context, model, isInitialised);

    if (config == null) {
      _removeButtons();
    } else if (config != _lastPushedConfig) {
      _pushButtons(config);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = TViewModelBuilder<T>(
      child: widget.child,
      viewModelBuilder: widget.viewModelBuilder,
      argumentBuilder: widget.argumentBuilder,
      isReactive: widget.isReactive,
      minBusyDuration: widget.minBusyDuration,
      contentFadeDuration: widget.contentFadeDuration,
      shouldDispose: widget.shouldDispose,
      onDispose: (model) {
        _removeButtons();
        widget.onDispose?.call(model);
      },
      builder: (context, model, isInitialised, child) {
        // Handle button push/update in build phase
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _handleViewModelUpdate(context, model, isInitialised);
          }
        });

        return widget.builder(context, model, isInitialised, child);
      },
    );

    if (widget.hostContextualButtons) {
      content = TContextualButtons(
        service: _service,
        child: content,
      );
    }

    return content;
  }
}
