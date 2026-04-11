import 'package:flutter/foundation.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';

import '../../../../../../core/services/mock_content_service.dart';

/// Drives the product detail page for [TCollapsibleSection].
///
/// Exposes cells for the section's [title] (sourced from
/// [MockContentService]) and [isExpanded] toggle. The visitor taps
/// the header to collapse/expand the section.
class TCollapsibleSectionShowcaseViewModel extends TBaseViewModel<void> {
  TCollapsibleSectionShowcaseViewModel({
    required MockContentService mockContentService,
  }) : _mockContentService = mockContentService;

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  final MockContentService _mockContentService;

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    _title.value = _mockContentService.categories.first.title;
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  @override
  void dispose() {
    _isExpanded.dispose();
    _title.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final TNotifier<bool> _isExpanded = TNotifier<bool>(true);

  final TNotifier<String> _title = TNotifier<String>('Collapsible Section');

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// Whether the collapsible section is currently expanded.
  ValueListenable<bool> get isExpanded => _isExpanded;

  /// The title text displayed on the collapsible header.
  ValueListenable<String> get title => _title;

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  /// Flips the expanded/collapsed state.
  void toggleExpanded() => _isExpanded.value = !_isExpanded.value;

  /// Updates the title text.
  void updateTitle(String value) => _title.value = value;
}
