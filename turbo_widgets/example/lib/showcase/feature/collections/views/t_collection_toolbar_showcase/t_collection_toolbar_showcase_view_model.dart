import 'package:flutter/foundation.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';
import 'package:turbo_widgets/turbo_widgets.dart';

/// Drives the product detail page for [TCollectionToolbar].
///
/// Exposes the four reactive cells that the toolbar binds to: search
/// query, sort value, filter value, and layout. This is the toolbar
/// demonstrated in isolation — not connected to a catalog.
///
/// A "last callback fired" observable shows which toolbar callback
/// was triggered.
class TCollectionToolbarShowcaseViewModel extends TBaseViewModel<void> {
  TCollectionToolbarShowcaseViewModel();

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  @override
  void dispose() {
    _searchQuery.dispose();
    _sortValue.dispose();
    _filterValue.dispose();
    _layout.dispose();
    _lastCallbackFired.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final TNotifier<String> _searchQuery = TNotifier<String>('');

  final TNotifier<String?> _sortValue = TNotifier<String?>(null);

  final TNotifier<String?> _filterValue = TNotifier<String?>(null);

  final TNotifier<TCollectionSectionLayout> _layout =
      TNotifier<TCollectionSectionLayout>(TCollectionSectionLayout.bento);

  final TNotifier<String?> _lastCallbackFired = TNotifier<String?>(null);

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// Sort option constants for the toolbar demo.
  static const String sortByName = 'Name';
  static const String sortByDate = 'Date';
  static const List<String> sortOptions = [sortByName, sortByDate];

  /// Filter option constants for the toolbar demo.
  static const String filterAll = 'All';
  static const String filterActive = 'Active';
  static const String filterArchived = 'Archived';
  static const List<String> filterOptions = [
    filterAll,
    filterActive,
    filterArchived,
  ];

  /// The current search query text.
  ValueListenable<String> get searchQuery => _searchQuery;

  /// The current sort mode, or `null` for default order.
  ValueListenable<String?> get sortValue => _sortValue;

  /// The current filter value, or `null` for no filter.
  ValueListenable<String?> get filterValue => _filterValue;

  /// The active layout for the toolbar's layout toggle.
  ValueListenable<TCollectionSectionLayout> get layout => _layout;

  /// Description of the last toolbar callback that fired, or `null`.
  ValueListenable<String?> get lastCallbackFired => _lastCallbackFired;

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void updateSearchQuery(String value) {
    _searchQuery.value = value;
    _lastCallbackFired.value = 'Search changed: "$value"';
  }

  void updateSortValue(String? value) {
    _sortValue.value = value;
    _lastCallbackFired.value = 'Sort changed: $value';
  }

  void updateFilterValue(String? value) {
    _filterValue.value = value;
    _lastCallbackFired.value = 'Filter changed: $value';
  }

  void updateLayout(TCollectionSectionLayout value) {
    _layout.value = value;
    _lastCallbackFired.value = 'Layout changed: ${value.name}';
  }
}
