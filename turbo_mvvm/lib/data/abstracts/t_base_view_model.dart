import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turbo_mvvm/data/constants/turbo_mvvm_defaults.dart';
import 'package:turbo_mvvm/services/t_busy_service.dart';

part '../../widgets/t_view_model_builder.dart';

/// Base view model class.
abstract class TBaseViewModel<A> extends ChangeNotifier {
  /// Holds arguments of type [A] provided by the [TViewModelBuilder._argumentBuilder].
  late final A arguments;

  /// Callback that is used by [isMounted] to check whether the parent [TViewModelBuilder] is mounted.
  late bool Function()? _mounted;

  /// Whether the parent [TViewModelBuilder] is mounted.
  bool get isMounted => _mounted?.call() ?? false;

  /// Provides non-leaking access to the [context].
  late DisposableBuildContext? disposableBuildContext;

  /// Sets whether the [TBaseViewModel] has been initialised.
  void setInitialised(bool value) => _isInitialised.value = value;

  /// Underlying notifier that sets whether the [TBaseViewModel] has been initialised.
  final ValueNotifier<bool> _isInitialised = ValueNotifier(false);

  /// Listenable that listens to whether the [TBaseViewModel] has been initialised.
  ValueListenable<bool> get isInitialised => _isInitialised;

  /// Used to perform any initialising logic for the [TBaseViewModel].
  @mustCallSuper
  FutureOr<void> initialise({bool doSetInitialised = true}) {
    _isInitialised.value = doSetInitialised;
  }

  /// Used to perform any disposing logic for the [TBaseViewModel].
  ///
  /// This method is called in the [TViewModelBuilderState.initState] method.
  @override
  void dispose() {
    disposableBuildContext!.dispose();
    disposableBuildContext = null;
    _mounted = null;
    super.dispose();
  }

  /// Used to rebuild the widgets inside the parent [TViewModelBuilder].
  void rebuild() => notifyListeners();

  /// Provides the current [TViewModelBuilderState]'s [BuildContext].
  BuildContext? get context => disposableBuildContext?.context;
}
