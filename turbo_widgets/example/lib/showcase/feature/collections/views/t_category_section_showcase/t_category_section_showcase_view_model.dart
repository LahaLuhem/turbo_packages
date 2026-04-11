import 'package:flutter/foundation.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';
import 'package:turbo_widgets/turbo_widgets.dart';

/// Drives the product detail page for [TCategorySection].
///
/// Exposes tunable cells for the section's layout mode, max items (to
/// exercise show-all behaviour), and a "last show-all fired" observable.
class TCategorySectionShowcaseViewModel extends TBaseViewModel<void> {
  TCategorySectionShowcaseViewModel();

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  @override
  void dispose() {
    _layout.dispose();
    _maxItems.dispose();
    _lastShowAllFired.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final TNotifier<TCategorySectionLayout> _layout =
      TNotifier<TCategorySectionLayout>(TCategorySectionLayout.horizontal);

  final TNotifier<int?> _maxItems = TNotifier<int?>(3);

  final TNotifier<String?> _lastShowAllFired = TNotifier<String?>(null);

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// The layout mode: horizontal scroll or grid.
  ValueListenable<TCategorySectionLayout> get layout => _layout;

  /// Maximum items before the show-all action appears.
  /// When `null`, all items are shown without truncation.
  ValueListenable<int?> get maxItems => _maxItems;

  /// Description of the last show-all callback, or `null`.
  ValueListenable<String?> get lastShowAllFired => _lastShowAllFired;

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void updateLayout(TCategorySectionLayout value) => _layout.value = value;

  void updateMaxItems(int? value) => _maxItems.value = value;

  /// Called when the show-all action is triggered.
  void onShowAll() => _lastShowAllFired.value = 'Show all triggered';
}
