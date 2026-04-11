import 'package:flutter/foundation.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';
import 'package:turbo_widgets/turbo_widgets.dart';

/// Drives the product detail page for [TBentoGrid].
///
/// This is the richest Collections view model. It exposes tunable cells
/// for item sizes (a mutable list), animation type, spacing, and a toggle
/// for add/remove controls. The sizes list can be mutated to add items,
/// remove items, or resize individual items — all of which trigger a
/// layout recalculation in the live preview.
class TBentoGridShowcaseViewModel extends TBaseViewModel<void> {
  TBentoGridShowcaseViewModel();

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  @override
  void dispose() {
    _sizes.dispose();
    _animation.dispose();
    _spacing.dispose();
    _showAddRemoveControls.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final TNotifier<List<double>> _sizes =
      TNotifier<List<double>>([4.0, 2.0, 2.0, 1.0, 1.0]);

  final TNotifier<TBentoGridAnimation> _animation =
      TNotifier<TBentoGridAnimation>(TBentoGridAnimation.fade);

  final TNotifier<double> _spacing = TNotifier<double>(8.0);

  final TNotifier<bool> _showAddRemoveControls = TNotifier<bool>(true);

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// The current item sizes. Each value is the relative area weight.
  ValueListenable<List<double>> get sizes => _sizes;

  /// The animation type for layout transitions.
  ValueListenable<TBentoGridAnimation> get animation => _animation;

  /// Spacing between grid items.
  ValueListenable<double> get spacing => _spacing;

  /// Whether the UI should display add/remove item controls.
  ValueListenable<bool> get showAddRemoveControls => _showAddRemoveControls;

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void updateAnimation(TBentoGridAnimation value) =>
      _animation.value = value;

  void updateSpacing(double value) => _spacing.value = value;

  void toggleShowAddRemoveControls() =>
      _showAddRemoveControls.value = !_showAddRemoveControls.value;

  /// Adds a new item with the given [size] weight to the end of the list.
  void addItem(double size) {
    final updated = List<double>.from(_sizes.value)..add(size);
    _sizes.value = updated;
  }

  /// Removes the last item from the list. No-op if the list has one or
  /// fewer items (prevents an empty grid).
  void removeLastItem() {
    if (_sizes.value.length <= 1) return;
    final updated = List<double>.from(_sizes.value)..removeLast();
    _sizes.value = updated;
  }

  /// Updates the size weight of the item at [index]. No-op if [index] is
  /// out of bounds.
  void updateItemSize(int index, double size) {
    if (index < 0 || index >= _sizes.value.length) return;
    final updated = List<double>.from(_sizes.value);
    updated[index] = size;
    _sizes.value = updated;
  }
}
