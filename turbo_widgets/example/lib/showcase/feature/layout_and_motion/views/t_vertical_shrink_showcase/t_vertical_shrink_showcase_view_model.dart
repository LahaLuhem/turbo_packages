import 'package:flutter/foundation.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';

/// Drives the product detail page for [TVerticalShrink].
///
/// Exposes a single boolean cell that controls the shrink widget's
/// visibility. The visitor toggles it to observe the vertical
/// collapse/expand animation.
class TVerticalShrinkShowcaseViewModel extends TBaseViewModel<void> {
  TVerticalShrinkShowcaseViewModel();

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  @override
  void dispose() {
    _isVisible.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final TNotifier<bool> _isVisible = TNotifier<bool>(true);

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// Whether the shrink widget's child is currently visible.
  ValueListenable<bool> get isVisible => _isVisible;

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  /// Flips the visibility state, triggering the vertical shrink animation.
  void toggleVisibility() => _isVisible.value = !_isVisible.value;
}
