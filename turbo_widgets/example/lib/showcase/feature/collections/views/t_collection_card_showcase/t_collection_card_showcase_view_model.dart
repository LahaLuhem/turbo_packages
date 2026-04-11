import 'package:flutter/foundation.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';

/// Drives the product detail page for [TCollectionCard].
///
/// Exposes tunable cells for the card's text fields and a "last tap
/// fired" observable for callback demonstration.
class TCollectionCardShowcaseViewModel extends TBaseViewModel<void> {
  TCollectionCardShowcaseViewModel();

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  @override
  void dispose() {
    _title.dispose();
    _subtitle.dispose();
    _meta.dispose();
    _lastTapFired.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final TNotifier<String> _title = TNotifier<String>('Collection Card');

  final TNotifier<String?> _subtitle =
      TNotifier<String?>('A standard item in a collection section');

  final TNotifier<String?> _meta = TNotifier<String?>('v1.2.0');

  final TNotifier<String?> _lastTapFired = TNotifier<String?>(null);

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// The title text displayed on the collection card.
  ValueListenable<String> get title => _title;

  /// The subtitle text below the title, or `null`.
  ValueListenable<String?> get subtitle => _subtitle;

  /// The metadata text, or `null`.
  ValueListenable<String?> get meta => _meta;

  /// The last tap event description, or `null`.
  ValueListenable<String?> get lastTapFired => _lastTapFired;

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void updateTitle(String value) => _title.value = value;

  void updateSubtitle(String? value) => _subtitle.value = value;

  void updateMeta(String? value) => _meta.value = value;

  /// Called when the card is tapped.
  void onTap() => _lastTapFired.value = 'Card tapped';
}
