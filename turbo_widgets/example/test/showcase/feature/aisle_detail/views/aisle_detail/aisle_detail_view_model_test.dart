import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_widgets/turbo_widgets.dart';

import 'package:turbo_widgets_example/core/enums/showcase_route.dart';
import 'package:turbo_widgets_example/core/services/showcase_catalog_service.dart';
import 'package:turbo_widgets_example/showcase/feature/aisle_detail/views/aisle_detail/aisle_detail_view_model.dart';

void main() {
  late ShowcaseCatalogService catalogService;
  late AisleDetailViewModel sut;
  late List<ShowcaseRoute> selectedProducts;

  setUp(() {
    catalogService = ShowcaseCatalogService();
    selectedProducts = [];
    sut = AisleDetailViewModel(
      aisleKey: 'navigation',
      showcaseCatalogService: catalogService,
      onProductSelected: (route) => selectedProducts.add(route),
    );
  });

  group('GIVEN a freshly created AisleDetailViewModel for navigation', () {
    test('THEN aisleKey is navigation', () {
      expect(sut.aisleKey, 'navigation');
    });

    test('THEN aisleLabel returns the human-readable label', () {
      expect(sut.aisleLabel, 'Navigation');
    });

    test('THEN aisleTagline returns a non-empty tagline', () {
      expect(sut.aisleTagline, isNotEmpty);
    });

    test('THEN searchQuery defaults to empty', () {
      expect(sut.searchQuery.value, isEmpty);
    });

    test('THEN sortValue defaults to null', () {
      expect(sut.sortValue.value, isNull);
    });

    test('THEN layout defaults to bento', () {
      expect(sut.layout.value, TCollectionSectionLayout.bento);
    });

    test('THEN products returns all navigation aisle entries', () {
      expect(
        sut.products.length,
        catalogService.byAisle('navigation').length,
      );
    });

    test('THEN every product belongs to the navigation aisle', () {
      for (final entry in sut.products) {
        expect(entry.aisleKey, 'navigation');
      }
    });

    test('THEN isProductsEmpty is false', () {
      expect(sut.isProductsEmpty, isFalse);
    });
  });

  group('GIVEN a search query matching a known widget name', () {
    setUp(() {
      sut.updateSearchQuery('TContextualAppBar');
    });

    test('THEN products contains only that widget', () {
      final results = sut.products;
      expect(results.length, 1);
      expect(results.first.widgetName, 'TContextualAppBar');
    });
  });

  group('GIVEN a search query matching part of a tagline', () {
    setUp(() {
      sut.updateSearchQuery('side rail');
    });

    test('THEN products includes widgets whose tagline contains the term', () {
      final results = sut.products;
      expect(results, isNotEmpty);
      for (final entry in results) {
        final matchesName =
            entry.widgetName.toLowerCase().contains('side rail');
        final matchesTagline =
            entry.tagline.toLowerCase().contains('side rail');
        expect(matchesName || matchesTagline, isTrue);
      }
    });
  });

  group('GIVEN search is case-insensitive', () {
    test('THEN uppercase query matches lowercase content', () {
      sut.updateSearchQuery('TCONTEXTUALAPPBAR');
      expect(sut.products.length, 1);
    });

    test('THEN mixed-case query matches', () {
      sut.updateSearchQuery('tCoNtExTuAlApPbAr');
      expect(sut.products.length, 1);
    });
  });

  group('GIVEN the search query is cleared', () {
    setUp(() {
      sut.updateSearchQuery('TContextualAppBar');
      sut.updateSearchQuery('');
    });

    test('THEN products returns all aisle entries', () {
      expect(
        sut.products.length,
        catalogService.byAisle('navigation').length,
      );
    });
  });

  group('GIVEN a search query that matches nothing', () {
    setUp(() {
      sut.updateSearchQuery('zzzznonexistent');
    });

    test('THEN products is empty', () {
      expect(sut.products, isEmpty);
    });

    test('THEN isProductsEmpty is true', () {
      expect(sut.isProductsEmpty, isTrue);
    });
  });

  group('GIVEN sort is set to Name A–Z', () {
    setUp(() {
      sut.updateSortValue(AisleDetailViewModel.sortByNameAsc);
    });

    test('THEN products are alphabetically ordered by widgetName', () {
      final names = sut.products.map((e) => e.widgetName).toList();
      final sorted = List<String>.from(names)..sort();
      expect(names, sorted);
    });
  });

  group('GIVEN sort is set to Name Z–A', () {
    setUp(() {
      sut.updateSortValue(AisleDetailViewModel.sortByNameDesc);
    });

    test('THEN products are reverse-alphabetically ordered by widgetName', () {
      final names = sut.products.map((e) => e.widgetName).toList();
      final sorted = List<String>.from(names)
        ..sort((a, b) => b.compareTo(a));
      expect(names, sorted);
    });
  });

  group('GIVEN sort is cleared after being set', () {
    setUp(() {
      sut.updateSortValue(AisleDetailViewModel.sortByNameAsc);
      sut.updateSortValue(null);
    });

    test('THEN products returns catalog order', () {
      final expected =
          catalogService.byAisle('navigation').map((e) => e.widgetName).toList();
      final actual = sut.products.map((e) => e.widgetName).toList();
      expect(actual, expected);
    });
  });

  group('GIVEN layout is updated', () {
    test('THEN layout reflects the new value', () {
      sut.updateLayout(TCollectionSectionLayout.list);
      expect(sut.layout.value, TCollectionSectionLayout.list);

      sut.updateLayout(TCollectionSectionLayout.grid);
      expect(sut.layout.value, TCollectionSectionLayout.grid);

      sut.updateLayout(TCollectionSectionLayout.bento);
      expect(sut.layout.value, TCollectionSectionLayout.bento);
    });

    test('THEN updating layout does not affect products count', () {
      final countBefore = sut.products.length;
      sut.updateLayout(TCollectionSectionLayout.list);
      expect(sut.products.length, countBefore);
    });
  });

  group('GIVEN search and sort are combined', () {
    setUp(() {
      sut.updateSearchQuery('contextual');
      sut.updateSortValue(AisleDetailViewModel.sortByNameAsc);
    });

    test('THEN results satisfy both constraints', () {
      final results = sut.products;
      expect(results, isNotEmpty);

      // All match search.
      for (final entry in results) {
        final matchesName =
            entry.widgetName.toLowerCase().contains('contextual');
        final matchesTagline =
            entry.tagline.toLowerCase().contains('contextual');
        expect(matchesName || matchesTagline, isTrue);
      }

      // Alphabetically sorted.
      final names = results.map((e) => e.widgetName).toList();
      final sorted = List<String>.from(names)..sort();
      expect(names, sorted);
    });
  });

  group('GIVEN selectProduct is called', () {
    test('THEN the onProductSelected callback fires with the route', () {
      sut.selectProduct(ShowcaseRoute.tContextualAppBar);
      expect(selectedProducts, [ShowcaseRoute.tContextualAppBar]);
    });

    test('THEN multiple calls accumulate', () {
      sut.selectProduct(ShowcaseRoute.tContextualAppBar);
      sut.selectProduct(ShowcaseRoute.tSideNavBar);
      expect(
        selectedProducts,
        [ShowcaseRoute.tContextualAppBar, ShowcaseRoute.tSideNavBar],
      );
    });
  });

  group('GIVEN reactive notifications', () {
    test('WHEN updateSearchQuery is called THEN searchQuery notifies', () {
      var notified = false;
      sut.searchQuery.addListener(() => notified = true);
      sut.updateSearchQuery('test');
      expect(notified, isTrue);
    });

    test('WHEN updateSortValue is called THEN sortValue notifies', () {
      var notified = false;
      sut.sortValue.addListener(() => notified = true);
      sut.updateSortValue(AisleDetailViewModel.sortByNameAsc);
      expect(notified, isTrue);
    });

    test('WHEN updateLayout is called THEN layout notifies', () {
      var notified = false;
      sut.layout.addListener(() => notified = true);
      sut.updateLayout(TCollectionSectionLayout.list);
      expect(notified, isTrue);
    });
  });

  group('GIVEN two instances for different aisles', () {
    late AisleDetailViewModel collectionsVm;

    setUp(() {
      collectionsVm = AisleDetailViewModel(
        aisleKey: 'collections',
        showcaseCatalogService: catalogService,
      );
    });

    test('THEN each returns only its own aisle products', () {
      expect(
        sut.products.length,
        catalogService.byAisle('navigation').length,
      );
      expect(
        collectionsVm.products.length,
        catalogService.byAisle('collections').length,
      );
    });

    test('THEN mutating one does not affect the other', () {
      sut.updateSearchQuery('zzzznonexistent');
      expect(sut.isProductsEmpty, isTrue);
      expect(collectionsVm.isProductsEmpty, isFalse);
    });

    test('THEN each has independent state', () {
      sut.updateLayout(TCollectionSectionLayout.list);
      expect(sut.layout.value, TCollectionSectionLayout.list);
      expect(collectionsVm.layout.value, TCollectionSectionLayout.bento);
    });
  });
}
