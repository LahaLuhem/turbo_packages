part of '../data/models/t_base_view_model.dart';

/// Used to build and provide a [TBaseViewModel] to the widget tree.
class TViewModelBuilder<T extends TBaseViewModel> extends StatefulWidget {
  const TViewModelBuilder({
    this.child,
    required Widget Function(
      BuildContext context,
      T model,
      bool isInitialised,
      Widget? child,
    )
    builder,
    required T Function() viewModelBuilder,
    Object? Function()? argumentBuilder,
    this.isReactive = TurboMvvmDefaults.isReactive,
    this.shouldDispose = TurboMvvmDefaults.shouldDispose,
    this.minBusyDuration,
    this.contentFadeDuration = TurboMvvmDefaults.animation,
    this.onDispose,
    Key? key,
  }) : _builder = builder,
       _viewModelBuilder = viewModelBuilder,
       _argumentBuilder = argumentBuilder,
       super(key: key);

  /// Child widget that will not rebuild when notifyListeners is called.
  final Widget? child;

  /// Builder method that builds the widget tree.
  final Widget Function(
    BuildContext context,
    T model,
    bool isInitialised,
    Widget? child,
  )
  _builder;

  /// Builder method that provides the [TBaseViewModel].
  final T Function() _viewModelBuilder;

  /// Builder method that provides the [TBaseViewModel.initialise] with arguments.
  final dynamic Function()? _argumentBuilder;

  /// Whether the [TBaseViewModel] should listen to [TBaseViewModel.notifyListeners] for rebuilds.
  final bool isReactive;

  /// Whether the [ChangeNotifierProvider] should dispose the [TBaseViewModel] when it's removed from the widget tree.
  final bool shouldDispose;

  /// Minimum duration the global busy overlay stays visible during initialisation.
  ///
  /// When non-null, [TBusyService] is set to busy on creation and cleared
  /// after [TBaseViewModel.initialise] completes, with the overlay held for
  /// at least this duration. Content fades in after the overlay has fully
  /// faded out. When `null`, no busy state handling occurs.
  final Duration? minBusyDuration;

  /// Duration of the content fade-in animation after the busy overlay clears.
  final Duration contentFadeDuration;

  /// Fires when [TViewModelBuilder] is removed from the widget tree.
  final void Function(T model)? onDispose;

  @override
  TViewModelBuilderState<T> createState() => TViewModelBuilderState<T>();
}

class TViewModelBuilderState<T extends TBaseViewModel>
    extends State<TViewModelBuilder<T>> {
  /// The current [TBaseViewModel].
  late final T _viewModel;

  /// Listener for busy state changes.
  VoidCallback? _busyListener;

  /// Initialises the [TBaseViewModel] and its needed methods.
  @override
  void initState() {
    _viewModel = widget._viewModelBuilder()
      ..disposableBuildContext = DisposableBuildContext(this)
      .._mounted = (() => mounted)
      ..arguments = widget._argumentBuilder?.call();
    final minBusyDuration = widget.minBusyDuration;
    final showLoadingIndicator = minBusyDuration != null;
    if (showLoadingIndicator) {
      final busyService = TBusyService.instance();
      busyService.setBusy(
        true,
        minBusyDuration: minBusyDuration,
      );
      _busyListener = () {
        if (!busyService.isBusy) {
          busyService.isBusyListenable.removeListener(_busyListener!);
          _busyListener = null;
          Future.delayed(widget.contentFadeDuration, () {
            _viewModel.setInitialised(true);
          });
        }
      };
      busyService.isBusyListenable.addListener(_busyListener!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _viewModel.initialise(doSetInitialised: !showLoadingIndicator);
      if (showLoadingIndicator) {
        TBusyService.instance().setBusy(false);
      }
    });
    super.initState();
  }

  /// Disposes the [TBaseViewModel] and its given methods.
  @override
  void dispose() {
    if (_busyListener != null) {
      TBusyService.instance().isBusyListenable.removeListener(_busyListener!);
      _busyListener = null;
    }
    widget.onDispose?.call(_viewModel);
    if (widget.shouldDispose) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: _viewModel.isInitialised,
    child: widget.child,
    builder: (context, isInitialised, child) {
      if (widget.isReactive) {
        return ChangeNotifierProvider<T>.value(
          value: _viewModel,
          child: Consumer<T>(
            child: child,
            builder: (context, value, child) {
              return widget._builder(
                context,
                value,
                isInitialised,
                child,
              );
            },
          ),
        );
      }
      return ChangeNotifierProvider<T>.value(
        value: _viewModel,
        child: child,
        builder: (context, child) => widget._builder(
          context,
          _viewModel,
          isInitialised,
          child,
        ),
      );
    },
  );
}
