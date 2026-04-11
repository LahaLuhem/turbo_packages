import 'package:flutter/foundation.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';

/// Drives the product detail page for [ContextualButtonsProvider].
///
/// ContextualButtonsProvider is a structural InheritedWidget — it maps
/// route enum values to contextual button configs. It has no visual
/// parameters of its own. This view model exposes a minimal "last lookup"
/// observable so the view can demonstrate the provider's lookup behaviour
/// and toast the result.
class ContextualButtonsProviderShowcaseViewModel extends TBaseViewModel<void> {
  ContextualButtonsProviderShowcaseViewModel();

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  @override
  void dispose() {
    _lastLookupResult.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final TNotifier<String?> _lastLookupResult = TNotifier<String?>(null);

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// Description of the last provider lookup, for toast display.
  ValueListenable<String?> get lastLookupResult => _lastLookupResult;

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  /// Called when the demo triggers a provider lookup to show the result.
  void onLookupPerformed(String result) =>
      _lastLookupResult.value = result;
}
