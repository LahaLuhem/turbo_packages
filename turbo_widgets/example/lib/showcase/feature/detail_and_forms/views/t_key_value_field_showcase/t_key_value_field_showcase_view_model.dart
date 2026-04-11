import 'package:flutter/foundation.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';

/// Drives the product detail page for [TKeyValueField].
///
/// Exposes reactive cells for the label and value strings.
class TKeyValueFieldShowcaseViewModel extends TBaseViewModel<void> {
  TKeyValueFieldShowcaseViewModel();

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  @override
  void dispose() {
    _label.dispose();
    _value.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final TNotifier<String> _label = TNotifier<String>('Version');

  final TNotifier<String> _value = TNotifier<String>('1.2.0');

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// The key-value field label.
  ValueListenable<String> get label => _label;

  /// The key-value field value.
  ValueListenable<String> get value => _value;

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void updateLabel(String label) {
    _label.value = label;
  }

  void updateValue(String value) {
    _value.value = value;
  }
}
