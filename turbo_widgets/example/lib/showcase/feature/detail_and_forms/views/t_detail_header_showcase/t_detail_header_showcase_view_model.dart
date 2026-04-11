import 'package:flutter/foundation.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';

/// Drives the product detail page for [TDetailHeader].
///
/// Exposes reactive cells for title, subtitle, save button visibility,
/// and a "last save fired" observable for callback demonstration.
class TDetailHeaderShowcaseViewModel extends TBaseViewModel<void> {
  TDetailHeaderShowcaseViewModel();

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  @override
  void dispose() {
    _title.dispose();
    _subtitle.dispose();
    _showSave.dispose();
    _lastSaveFired.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final TNotifier<String> _title = TNotifier<String>('Widget Detail');

  final TNotifier<String> _subtitle =
      TNotifier<String>('A reusable component for building Flutter apps.');

  final TNotifier<bool> _showSave = TNotifier<bool>(true);

  final TNotifier<String?> _lastSaveFired = TNotifier<String?>(null);

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// The header title text.
  ValueListenable<String> get title => _title;

  /// The header subtitle / description text.
  ValueListenable<String> get subtitle => _subtitle;

  /// Whether the save button is visible.
  ValueListenable<bool> get showSave => _showSave;

  /// Description of the last save callback that fired, or `null`.
  ValueListenable<String?> get lastSaveFired => _lastSaveFired;

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void updateTitle(String title) {
    _title.value = title;
  }

  void updateSubtitle(String subtitle) {
    _subtitle.value = subtitle;
  }

  void toggleShowSave() {
    _showSave.value = !_showSave.value;
  }

  void onSave() {
    _lastSaveFired.value =
        'Save tapped at ${DateTime.now().toIso8601String()}';
  }
}
