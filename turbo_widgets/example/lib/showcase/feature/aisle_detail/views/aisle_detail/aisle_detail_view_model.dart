import 'package:flutter/foundation.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';
import 'package:turbo_widgets/turbo_widgets.dart';

import '../../../../../core/enums/showcase_route.dart';
import '../../../../../core/models/showcase_entry.dart';
import '../../../../../core/services/showcase_catalog_service.dart';

/// Drives a single aisle's detail screen — the listing of every product
/// inside one aisle with a working toolbar for search, sort, and layout.
///
/// One instance serves one aisle. The [aisleKey] is final and cannot change
/// after construction. Navigating to a different aisle means constructing a
/// new instance.
class AisleDetailViewModel extends TBaseViewModel<void> {
  AisleDetailViewModel({
    required this.aisleKey,
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
    _layout.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  /// The aisle this view model is scoped to. Immutable after construction.
  final String aisleKey;

  final TNotifier<String> _searchQuery = TNotifier<String>('');

  final TNotifier<String?> _sortValue = TNotifier<String?>(null);

  final TNotifier<TCollectionSectionLayout> _layout =
      TNotifier<TCollectionSectionLayout>(TCollectionSectionLayout.bento);

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// Sort option constants matching what [TCollectionToolbar.sortOptions] expects.
  static const String sortByNameAsc = 'Name A–Z';
  static const String sortByNameDesc = 'Name Z–A';
  static const List<String> sortOptions = [sortByNameAsc, sortByNameDesc];

  /// The current search query, observable by views.
  ValueListenable<String> get searchQuery => _searchQuery;

  /// The current sort mode, or `null` for default catalog order.
  ValueListenable<String?> get sortValue => _sortValue;

  /// The active layout for the collection section.
  ValueListenable<TCollectionSectionLayout> get layout => _layout;

  /// Human-readable label for this aisle.
  String get aisleLabel => ShowcaseCatalogService.aisleLabel(aisleKey);

  /// Short tagline for this aisle.
  String get aisleTagline => ShowcaseCatalogService.aisleTagline(aisleKey);

  /// Derives the visible product list from the current search, sort, and
  /// catalog state, scoped to [aisleKey].
  ///
  /// Called inside a [MultiListenableBuilder] that listens to [searchQuery],
  /// [sortValue], and [layout], so it recomputes exactly once per frame when
  /// any cell changes.
  List<ShowcaseEntry> get products {
    var results = _showcaseCatalogService.byAisle(aisleKey);

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
      case sortByNameAsc:
        results.sort((a, b) => a.widgetName.compareTo(b.widgetName));
      case sortByNameDesc:
        results.sort((a, b) => b.widgetName.compareTo(a.widgetName));
    }

    return results;
  }

  /// Whether the current search produces no results.
  bool get isProductsEmpty => products.isEmpty;

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  /// Updates the search query. Triggers a recomputation of [products].
  void updateSearchQuery(String value) => _searchQuery.value = value;

  /// Updates the sort mode. Pass `null` to restore default catalog order.
  void updateSortValue(String? value) => _sortValue.value = value;

  /// Switches the collection section layout.
  void updateLayout(TCollectionSectionLayout value) => _layout.value = value;

  /// Signals that the visitor selected a product. Delegates to the
  /// [onProductSelected] callback provided by the shell.
  void selectProduct(ShowcaseRoute route) {
    onProductSelected?.call(route);
  }
}
