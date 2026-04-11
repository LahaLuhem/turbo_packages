import 'package:flutter/foundation.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';

/// Drives the product detail page for [THorizontalShrink].
///
/// Exposes a single boolean cell that controls the shrink widget's
/// visibility. The visitor toggles it to observe the horizontal
/// collapse/expand animation.
class THorizontalShrinkShowcaseViewModel extends TBaseViewModel<void> {
  THorizontalShrinkShowcaseViewModel();

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

  /// Flips the visibility state, triggering the horizontal shrink animation.
  void toggleVisibility() => _isVisible.value = !_isVisible.value;
}
