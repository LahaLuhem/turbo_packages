import 'package:flutter/foundation.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';

/// Drives the product detail page for [TCalculatedHeight].
///
/// Exposes cells for every parameter of the widget: [count],
/// [baseHeight], [multiplierThreshold], [minHeight], and [maxHeight].
/// The visitor adds and removes items via [addItem] / [removeItem] to
/// watch the calculated height rescale in the live preview.
class TCalculatedHeightShowcaseViewModel extends TBaseViewModel<void> {
  TCalculatedHeightShowcaseViewModel();

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  @override
  void dispose() {
    _count.dispose();
    _baseHeight.dispose();
    _multiplierThreshold.dispose();
    _minHeight.dispose();
    _maxHeight.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final TNotifier<int> _count = TNotifier<int>(5);

  final TNotifier<double> _baseHeight = TNotifier<double>(200.0);

  final TNotifier<double> _multiplierThreshold = TNotifier<double>(10.0);

  final TNotifier<double?> _minHeight = TNotifier<double?>(null);

  final TNotifier<double?> _maxHeight = TNotifier<double?>(null);

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// The current item count driving the height calculation.
  ValueListenable<int> get count => _count;

  /// The base height used in the calculation formula.
  ValueListenable<double> get baseHeight => _baseHeight;

  /// The threshold divisor for the multiplier.
  ValueListenable<double> get multiplierThreshold => _multiplierThreshold;

  /// Optional minimum height clamp.
  ValueListenable<double?> get minHeight => _minHeight;

  /// Optional maximum height clamp.
  ValueListenable<double?> get maxHeight => _maxHeight;

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  /// Increments [count] by one.
  void addItem() => _count.value = _count.value + 1;

  /// Decrements [count] by one. No-op when count is already 0.
  void removeItem() {
    if (_count.value <= 0) return;
    _count.value = _count.value - 1;
  }

  /// Directly sets [count]. Values below 0 are clamped to 0.
  void updateCount(int value) => _count.value = value < 0 ? 0 : value;

  void updateBaseHeight(double value) => _baseHeight.value = value;

  void updateMultiplierThreshold(double value) =>
      _multiplierThreshold.value = value;

  void updateMinHeight(double? value) => _minHeight.value = value;

  void updateMaxHeight(double? value) => _maxHeight.value = value;
}
