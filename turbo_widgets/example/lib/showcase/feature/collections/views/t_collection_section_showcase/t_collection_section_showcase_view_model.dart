import 'package:flutter/foundation.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';
import 'package:turbo_widgets/turbo_widgets.dart';

/// Drives the product detail page for [TCollectionSection].
///
/// Exposes tunable cells for the section's layout mode and bento animation
/// type (the animation enum only takes effect when layout is bento).
/// A "last tap fired" observable demonstrates item tap callbacks.
class TCollectionSectionShowcaseViewModel extends TBaseViewModel<void> {
  TCollectionSectionShowcaseViewModel();

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  @override
  void dispose() {
    _layout.dispose();
    _bentoAnimation.dispose();
    _lastTapFired.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final TNotifier<TCollectionSectionLayout> _layout =
      TNotifier<TCollectionSectionLayout>(TCollectionSectionLayout.bento);

  final TNotifier<TBentoGridAnimation> _bentoAnimation =
      TNotifier<TBentoGridAnimation>(TBentoGridAnimation.fade);

  final TNotifier<String?> _lastTapFired = TNotifier<String?>(null);

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// The active layout for the collection section.
  ValueListenable<TCollectionSectionLayout> get layout => _layout;

  /// The animation type used when [layout] is [TCollectionSectionLayout.bento].
  ValueListenable<TBentoGridAnimation> get bentoAnimation => _bentoAnimation;

  /// The last item tap event description, or `null`.
  ValueListenable<String?> get lastTapFired => _lastTapFired;

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void updateLayout(TCollectionSectionLayout value) => _layout.value = value;

  void updateBentoAnimation(TBentoGridAnimation value) =>
      _bentoAnimation.value = value;

  /// Called when a collection item is tapped.
  void onItemTap(int index) =>
      _lastTapFired.value = 'Item $index tapped';
}
