import 'package:flutter/foundation.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';

/// Drives the product detail page for [TContextualNavButton].
///
/// Exposes tunable cells for the nav button's visible parameters:
/// whether the label is shown and a "last pressed" observable so the
/// view can toast when the button's callback fires.
class TContextualNavButtonShowcaseViewModel extends TBaseViewModel<void> {
  TContextualNavButtonShowcaseViewModel();

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  @override
  void dispose() {
    _showLabel.dispose();
    _lastPressed.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final TNotifier<bool> _showLabel = TNotifier<bool>(true);

  final TNotifier<String?> _lastPressed = TNotifier<String?>(null);

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// Whether the button shows its label alongside the icon.
  ValueListenable<bool> get showLabel => _showLabel;

  /// The last button press event description, or `null`.
  ValueListenable<String?> get lastPressed => _lastPressed;

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void toggleShowLabel() => _showLabel.value = !_showLabel.value;

  /// Called when the nav button is tapped.
  void onPressed() => _lastPressed.value = 'Button pressed';
}
