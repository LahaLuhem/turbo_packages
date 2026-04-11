import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_widgets/turbo_widgets.dart';

import 'package:turbo_widgets_example/core/enums/showcase_route.dart';
import 'package:turbo_widgets_example/core/services/showcase_catalog_service.dart';
import 'package:turbo_widgets_example/showcase/feature/shop_home/views/shop_home/shop_home_view_model.dart';

void main() {
  late ShowcaseCatalogService catalogService;
  late ShopHomeViewModel sut;
  late List<ShowcaseRoute> selectedProducts;

  setUp(() {
    catalogService = ShowcaseCatalogService();
    selectedProducts = [];
    sut = ShopHomeViewModel(
      showcaseCatalogService: catalogService,
      onProductSelected: (route) => selectedProducts.add(route),
    );
  });

  group('GIVEN a freshly created ShopHomeViewModel', () {
    test('THEN searchQuery defaults to empty', () {
      expect(sut.searchQuery.value, isEmpty);
    });

    test('THEN sortValue defaults to null', () {
      expect(sut.sortValue.value, isNull);
    });

    test('THEN filterValue defaults to null', () {
      expect(sut.filterValue.value, isNull);
    });

    test('THEN featuredLayout defaults to bento', () {
      expect(sut.featuredLayout.value, TCollectionSectionLayout.bento);
    });

    test('THEN featuredEntries returns all catalog entries', () {
      expect(sut.featuredEntries.length, catalogService.entries.length);
    });

    test('THEN isFeaturedEmpty is false', () {
      expect(sut.isFeaturedEmpty, isFalse);
    });
  });

  group('GIVEN the search query is set to a known widget name', () {
    setUp(() {
      sut.updateSearchQuery('TBentoGrid');
    });

    test('THEN featuredEntries contains only that widget', () {
      final results = sut.featuredEntries;
      expect(results.length, 1);
      expect(results.first.widgetName, 'TBentoGrid');
    });
  });

  group('GIVEN the search query matches part of a tagline', () {
    setUp(() {
      sut.updateSearchQuery('bento');
    });

    test('THEN featuredEntries includes widgets whose tagline contains the term', () {
      final results = sut.featuredEntries;
      expect(results, isNotEmpty);
      for (final entry in results) {
        final matchesName =
            entry.widgetName.toLowerCase().contains('bento');
        final matchesTagline =
            entry.tagline.toLowerCase().contains('bento');
        expect(matchesName || matchesTagline, isTrue);
      }
    });
  });

  group('GIVEN the search is case-insensitive', () {
    test('THEN uppercase query matches lowercase content', () {
      sut.updateSearchQuery('TBENTOGRID');
      expect(sut.featuredEntries.length, 1);
    });

    test('THEN mixed-case query matches', () {
      sut.updateSearchQuery('tBenToGrId');
      expect(sut.featuredEntries.length, 1);
    });
  });

  group('GIVEN the search query is cleared', () {
    setUp(() {
      sut.updateSearchQuery('TBentoGrid');
      sut.updateSearchQuery('');
    });

    test('THEN featuredEntries returns all entries', () {
      expect(sut.featuredEntries.length, catalogService.entries.length);
    });
  });

  group('GIVEN a search query that matches nothing', () {
    setUp(() {
      sut.updateSearchQuery('zzzznonexistent');
    });

    test('THEN featuredEntries is empty', () {
      expect(sut.featuredEntries, isEmpty);
    });

    test('THEN isFeaturedEmpty is true', () {
      expect(sut.isFeaturedEmpty, isTrue);
    });
  });

  group('GIVEN sort is set to Name', () {
    setUp(() {
      sut.updateSortValue(ShopHomeViewModel.sortByName);
    });

    test('THEN featuredEntries are alphabetically ordered by widgetName', () {
      final names = sut.featuredEntries.map((e) => e.widgetName).toList();
      final sorted = List<String>.from(names)..sort();
      expect(names, sorted);
    });
  });

  group('GIVEN sort is set to Aisle', () {
    setUp(() {
      sut.updateSortValue(ShopHomeViewModel.sortByAisle);
    });

    test('THEN featuredEntries are grouped by aisleKey then by widgetName', () {
      final results = sut.featuredEntries;
      for (var i = 1; i < results.length; i++) {
        final prev = results[i - 1];
        final curr = results[i];
        final aisleCompare = prev.aisleKey.compareTo(curr.aisleKey);
        if (aisleCompare == 0) {
          expect(
            prev.widgetName.compareTo(curr.widgetName) <= 0,
            isTrue,
            reason:
                '${prev.widgetName} should come before ${curr.widgetName} within aisle ${curr.aisleKey}',
          );
        } else {
          expect(
            aisleCompare < 0,
            isTrue,
            reason:
                'Aisle ${prev.aisleKey} should come before ${curr.aisleKey}',
          );
        }
      }
    });
  });

  group('GIVEN filter is set to a specific aisle', () {
    setUp(() {
      sut.updateFilterValue('navigation');
    });

    test('THEN featuredEntries contains only navigation widgets', () {
      final results = sut.featuredEntries;
      expect(results, isNotEmpty);
      for (final entry in results) {
        expect(entry.aisleKey, 'navigation');
      }
    });

    test('THEN the count matches the catalog byAisle count', () {
      expect(
        sut.featuredEntries.length,
        catalogService.byAisle('navigation').length,
      );
    });
  });

  group('GIVEN filter is cleared after being set', () {
    setUp(() {
      sut.updateFilterValue('navigation');
      sut.updateFilterValue(null);
    });

    test('THEN featuredEntries returns all entries', () {
      expect(sut.featuredEntries.length, catalogService.entries.length);
    });
  });

  group('GIVEN layout is updated', () {
    test('THEN featuredLayout reflects the new value', () {
      sut.updateLayout(TCollectionSectionLayout.list);
      expect(sut.featuredLayout.value, TCollectionSectionLayout.list);

      sut.updateLayout(TCollectionSectionLayout.grid);
      expect(sut.featuredLayout.value, TCollectionSectionLayout.grid);

      sut.updateLayout(TCollectionSectionLayout.bento);
      expect(sut.featuredLayout.value, TCollectionSectionLayout.bento);
    });

    test('THEN updating layout does not affect featuredEntries count', () {
      final countBefore = sut.featuredEntries.length;
      sut.updateLayout(TCollectionSectionLayout.list);
      expect(sut.featuredEntries.length, countBefore);
    });
  });

  group('GIVEN search and filter are combined', () {
    setUp(() {
      sut.updateFilterValue('collections');
      sut.updateSearchQuery('bento');
    });

    test('THEN featuredEntries satisfies both constraints', () {
      final results = sut.featuredEntries;
      expect(results, isNotEmpty);
      for (final entry in results) {
        expect(entry.aisleKey, 'collections');
        final matchesName =
            entry.widgetName.toLowerCase().contains('bento');
        final matchesTagline =
            entry.tagline.toLowerCase().contains('bento');
        expect(matchesName || matchesTagline, isTrue);
      }
    });
  });

  group('GIVEN search, filter, and sort are all active', () {
    setUp(() {
      sut.updateFilterValue('collections');
      sut.updateSearchQuery('t');
      sut.updateSortValue(ShopHomeViewModel.sortByName);
    });

    test('THEN results are filtered, searched, and sorted', () {
      final results = sut.featuredEntries;
      expect(results, isNotEmpty);

      // All in collections aisle.
      for (final entry in results) {
        expect(entry.aisleKey, 'collections');
      }

      // All match search.
      for (final entry in results) {
        final matchesName =
            entry.widgetName.toLowerCase().contains('t');
        final matchesTagline =
            entry.tagline.toLowerCase().contains('t');
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
      sut.selectProduct(ShowcaseRoute.tBentoGrid);
      expect(selectedProducts, [ShowcaseRoute.tBentoGrid]);
    });

    test('THEN multiple calls accumulate', () {
      sut.selectProduct(ShowcaseRoute.tBentoGrid);
      sut.selectProduct(ShowcaseRoute.tFeatureCard);
      expect(
        selectedProducts,
        [ShowcaseRoute.tBentoGrid, ShowcaseRoute.tFeatureCard],
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
      sut.updateSortValue(ShopHomeViewModel.sortByName);
      expect(notified, isTrue);
    });

    test('WHEN updateFilterValue is called THEN filterValue notifies', () {
      var notified = false;
      sut.filterValue.addListener(() => notified = true);
      sut.updateFilterValue('collections');
      expect(notified, isTrue);
    });

    test('WHEN updateLayout is called THEN featuredLayout notifies', () {
      var notified = false;
      sut.featuredLayout.addListener(() => notified = true);
      sut.updateLayout(TCollectionSectionLayout.list);
      expect(notified, isTrue);
    });
  });
}
