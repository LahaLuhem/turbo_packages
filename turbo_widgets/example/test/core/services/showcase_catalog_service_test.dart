import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_widgets_example/core/enums/showcase_route.dart';
import 'package:turbo_widgets_example/core/services/showcase_catalog_service.dart';

void main() {
  late ShowcaseCatalogService sut;

  setUp(() {
    sut = ShowcaseCatalogService();
  });

  group('GIVEN a ShowcaseCatalogService', () {
    group('WHEN accessing entries', () {
      test('THEN it contains at least one entry', () {
        expect(sut.entries, isNotEmpty);
      });

      test('THEN every entry has a non-empty widget name', () {
        for (final entry in sut.entries) {
          expect(entry.widgetName, isNotEmpty);
        }
      });

      test('THEN every entry has a non-empty aisle key', () {
        for (final entry in sut.entries) {
          expect(entry.aisleKey, isNotEmpty);
        }
      });

      test('THEN every entry has a non-empty tagline', () {
        for (final entry in sut.entries) {
          expect(entry.tagline, isNotEmpty);
        }
      });
    });

    group('WHEN calling byAisle', () {
      test('THEN navigation returns 7 entries', () {
        final results = sut.byAisle('navigation');
        expect(results.length, 7);
      });

      test('THEN collections returns 10 entries', () {
        final results = sut.byAisle('collections');
        expect(results.length, 10);
      });

      test('THEN detail_and_forms returns 4 entries', () {
        final results = sut.byAisle('detail_and_forms');
        expect(results.length, 4);
      });

      test('THEN layout_and_motion returns 4 entries', () {
        final results = sut.byAisle('layout_and_motion');
        expect(results.length, 4);
      });

      test('THEN utilities returns 3 entries', () {
        final results = sut.byAisle('utilities');
        expect(results.length, 3);
      });

      test('THEN an unknown aisle returns an empty list', () {
        final results = sut.byAisle('nonexistent');
        expect(results, isEmpty);
      });

      test('THEN every entry belongs to a known aisle', () {
        for (final entry in sut.entries) {
          expect(
            ShowcaseCatalogService.aisleKeys,
            contains(entry.aisleKey),
          );
        }
      });
    });

    group('WHEN calling byRoute', () {
      test('THEN a known product route returns the matching entry', () {
        final entry = sut.byRoute(ShowcaseRoute.tBentoGrid);
        expect(entry, isNotNull);
        expect(entry!.widgetName, 'TBentoGrid');
        expect(entry.aisleKey, 'collections');
      });

      test('THEN shopHome returns null (not a product)', () {
        final entry = sut.byRoute(ShowcaseRoute.shopHome);
        expect(entry, isNull);
      });

      test('THEN aisleDetail returns null (not a product)', () {
        final entry = sut.byRoute(ShowcaseRoute.aisleDetail);
        expect(entry, isNull);
      });

      test('THEN every product route has a matching entry', () {
        final productRoutes = ShowcaseRoute.values.where(
          (r) => r != ShowcaseRoute.shopHome && r != ShowcaseRoute.aisleDetail,
        );
        for (final route in productRoutes) {
          expect(sut.byRoute(route), isNotNull, reason: 'Missing: $route');
        }
      });
    });

    group('WHEN checking aisle metadata', () {
      test('THEN aisleLabel returns non-empty for all known keys', () {
        for (final key in ShowcaseCatalogService.aisleKeys) {
          expect(ShowcaseCatalogService.aisleLabel(key), isNotEmpty);
        }
      });

      test('THEN aisleTagline returns non-empty for all known keys', () {
        for (final key in ShowcaseCatalogService.aisleKeys) {
          expect(ShowcaseCatalogService.aisleTagline(key), isNotEmpty);
        }
      });
    });
  });
}
