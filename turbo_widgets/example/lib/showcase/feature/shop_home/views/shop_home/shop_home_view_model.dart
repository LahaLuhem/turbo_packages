import 'package:flutter/foundation.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';
import 'package:turbo_widgets/turbo_widgets.dart';

import '../../../../../core/enums/showcase_route.dart';
import '../../../../../core/models/showcase_entry.dart';
import '../../../../../core/services/showcase_catalog_service.dart';

/// Drives the shop home screen — the storefront landing page.
///
/// Owns reactive cells for search, sort, filter, and layout that feed the
/// featured products list. The visible list is derived (never stored) from
/// these four cells plus the catalog service.
class ShopHomeViewModel extends TBaseViewModel<void> {
  ShopHomeViewModel({
    required ShowcaseCatalogService showcaseCatalogService,
    this.onProductSelected,
  }) : _showcaseCatalogService = showcaseCatalogService;

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  final ShowcaseCatalogService _showcaseCatalogService;

  /// Called when the visitor taps a product card. The shell wires this to its
  /// own [ShowcaseShellViewModel.openProduct] so routing stays out of this
  /// view model.
  final void Function(ShowcaseRoute route)? onProductSelected;

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
    _featuredLayout.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final TNotifier<String> _searchQuery = TNotifier<String>('');

  final TNotifier<String?> _sortValue = TNotifier<String?>(null);

  final TNotifier<String?> _filterValue = TNotifier<String?>(null);

  final TNotifier<TCollectionSectionLayout> _featuredLayout =
      TNotifier<TCollectionSectionLayout>(TCollectionSectionLayout.bento);

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// Sort option constants matching what [TCollectionToolbar.sortOptions] expects.
  static const String sortByName = 'Name';
  static const String sortByAisle = 'Aisle';
  static const List<String> sortOptions = [sortByName, sortByAisle];

  /// The current search query, observable by views.
  ValueListenable<String> get searchQuery => _searchQuery;

  /// The current sort mode ('Name' or 'Aisle'), or `null` for default order.
  ValueListenable<String?> get sortValue => _sortValue;

  /// The current aisle key filter, or `null` for all aisles.
  ValueListenable<String?> get filterValue => _filterValue;

  /// The active layout for the featured collection section.
  ValueListenable<TCollectionSectionLayout> get featuredLayout =>
      _featuredLayout;

  /// Derives the visible featured list from the current search, sort, filter,
  /// and catalog state.
  ///
  /// This getter is called inside a [MultiListenableBuilder] that listens to
  /// [searchQuery], [sortValue], [filterValue], and [featuredLayout], so it
  /// recomputes exactly once per frame when any cell changes.
  List<ShowcaseEntry> get featuredEntries {
    var results = _showcaseCatalogService.entries.toList();

    // Filter by aisle.
    final filter = _filterValue.value;
    if (filter != null) {
      results = results.where((e) => e.aisleKey == filter).toList();
    }

    // Search by name or tagline (case-insensitive substring).
    final query = _searchQuery.value.toLowerCase();
    if (query.isNotEmpty) {
      results = results
          .where(
            (e) =>
                e.widgetName.toLowerCase().contains(query) ||
                e.tagline.toLowerCase().contains(query),
          )
          .toList();
    }

    // Sort.
    final sort = _sortValue.value;
    switch (sort) {
      case sortByName:
        results.sort((a, b) => a.widgetName.compareTo(b.widgetName));
      case sortByAisle:
        results.sort((a, b) {
          final c = a.aisleKey.compareTo(b.aisleKey);
          return c != 0 ? c : a.widgetName.compareTo(b.widgetName);
        });
    }

    return results;
  }

  /// Whether the current filter/search combination produces no results.
  bool get isFeaturedEmpty => featuredEntries.isEmpty;

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  /// Updates the search query. Triggers a recomputation of [featuredEntries].
  void updateSearchQuery(String value) => _searchQuery.value = value;

  /// Updates the sort mode. Pass `null` to restore default catalog order.
  void updateSortValue(String? value) => _sortValue.value = value;

  /// Updates the aisle filter. Pass `null` to show all aisles.
  void updateFilterValue(String? value) => _filterValue.value = value;

  /// Switches the collection section layout.
  void updateLayout(TCollectionSectionLayout value) =>
      _featuredLayout.value = value;

  /// Signals that the visitor selected a product. Delegates to the
  /// [onProductSelected] callback provided by the shell.
  void selectProduct(ShowcaseRoute route) {
    onProductSelected?.call(route);
  }
}
