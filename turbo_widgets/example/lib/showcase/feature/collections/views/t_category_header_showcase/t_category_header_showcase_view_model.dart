import 'package:flutter/foundation.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';

/// Drives the product detail page for [TCategoryHeader].
///
/// Exposes tunable cells for the header's title and description text.
/// This is a pure display widget with no callbacks.
class TCategoryHeaderShowcaseViewModel extends TBaseViewModel<void> {
  TCategoryHeaderShowcaseViewModel();

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final TNotifier<String> _title = TNotifier<String>('Category Header');

  final TNotifier<String> _description =
      TNotifier<String>('Banner header displayed above a category section');

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// The title text displayed on the category header.
  ValueListenable<String> get title => _title;

  /// The description text below the title.
  ValueListenable<String> get description => _description;

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void updateTitle(String value) => _title.value = value;

  void updateDescription(String value) => _description.value = value;
}
