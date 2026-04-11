import 'package:flutter/foundation.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';

/// Drives the product detail page for [TCategoryCard].
///
/// Exposes tunable cells for the card's title and a "last tap fired"
/// observable for callback demonstration.
class TCategoryCardShowcaseViewModel extends TBaseViewModel<void> {
  TCategoryCardShowcaseViewModel();

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  @override
  void dispose() {
    _title.dispose();
    _lastTapFired.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final TNotifier<String> _title = TNotifier<String>('Category A');

  final TNotifier<String?> _lastTapFired = TNotifier<String?>(null);

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// The title displayed on the category card.
  ValueListenable<String> get title => _title;

  /// The last tap event description, or `null`.
  ValueListenable<String?> get lastTapFired => _lastTapFired;

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void updateTitle(String value) => _title.value = value;

  /// Called when the category card is pressed.
  void onPressed() => _lastTapFired.value = 'Card pressed';
}
