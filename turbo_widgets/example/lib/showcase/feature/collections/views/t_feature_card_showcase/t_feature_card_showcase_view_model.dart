import 'package:flutter/foundation.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';

/// Drives the product detail page for [TFeatureCard].
///
/// Exposes tunable cells for the card's visible parameters: title text,
/// description text, and a "last tap fired" observable for callback
/// demonstration.
class TFeatureCardShowcaseViewModel extends TBaseViewModel<void> {
  TFeatureCardShowcaseViewModel();

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _lastTapFired.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final TNotifier<String> _title = TNotifier<String>('Feature Card');

  final TNotifier<String> _description =
      TNotifier<String>('A highlighted card for featuring a single item');

  final TNotifier<String?> _lastTapFired = TNotifier<String?>(null);

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// The title text displayed on the feature card.
  ValueListenable<String> get title => _title;

  /// The description text below the title.
  ValueListenable<String> get description => _description;

  /// The last tap event description, or `null`.
  ValueListenable<String?> get lastTapFired => _lastTapFired;

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void updateTitle(String value) => _title.value = value;

  void updateDescription(String value) => _description.value = value;

  /// Called when the card is tapped.
  void onTap() => _lastTapFired.value = 'Card tapped';
}
