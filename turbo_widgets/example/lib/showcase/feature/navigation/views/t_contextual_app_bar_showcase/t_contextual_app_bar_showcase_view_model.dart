import 'package:flutter/foundation.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';

/// Drives the product detail page for [TContextualAppBar].
///
/// Exposes tunable cells for the app bar's visible parameters: title text,
/// whether labels are shown on action buttons, and a "last callback fired"
/// observable so the view can toast when an action is tapped.
class TContextualAppBarShowcaseViewModel extends TBaseViewModel<void> {
  TContextualAppBarShowcaseViewModel();

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  @override
  void dispose() {
    _title.dispose();
    _showLabels.dispose();
    _lastCallbackFired.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final TNotifier<String> _title = TNotifier<String>('App Bar Title');

  final TNotifier<bool> _showLabels = TNotifier<bool>(true);

  final TNotifier<String?> _lastCallbackFired = TNotifier<String?>(null);

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// The title text displayed in the app bar.
  ValueListenable<String> get title => _title;

  /// Whether action buttons show their labels alongside icons.
  ValueListenable<bool> get showLabels => _showLabels;

  /// The name of the last action button callback that fired, or `null`.
  ValueListenable<String?> get lastCallbackFired => _lastCallbackFired;

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void updateTitle(String value) => _title.value = value;

  void toggleShowLabels() => _showLabels.value = !_showLabels.value;

  /// Called when a leading or action button is tapped. Sets the
  /// [lastCallbackFired] cell so the view can display a toast.
  void onButtonPressed(String buttonName) =>
      _lastCallbackFired.value = buttonName;
}
