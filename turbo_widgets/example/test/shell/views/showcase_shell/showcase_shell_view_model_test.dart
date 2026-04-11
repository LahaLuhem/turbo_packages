import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turbo_widgets_example/core/enums/showcase_route.dart';
import 'package:turbo_widgets_example/core/services/showcase_catalog_service.dart';
import 'package:turbo_widgets_example/core/services/theme_service.dart';
import 'package:turbo_widgets_example/shell/views/showcase_shell/showcase_shell_view_model.dart';

void main() {
  late ShowcaseCatalogService catalogService;
  late ThemeService themeService;
  late ShowcaseShellViewModel sut;

  setUp(() {
    catalogService = ShowcaseCatalogService();
    themeService = ThemeService();
    sut = ShowcaseShellViewModel(
      showcaseCatalogService: catalogService,
      themeService: themeService,
    );
  });

  group('GIVEN a freshly created ShowcaseShellViewModel', () {
    test('THEN currentRoute defaults to shopHome', () {
      expect(sut.currentRoute.value, ShowcaseRoute.shopHome);
    });

    test('THEN selectedAisleKey defaults to null', () {
      expect(sut.selectedAisleKey.value, isNull);
    });

    test('THEN selectedProductKey defaults to null', () {
      expect(sut.selectedProductKey.value, isNull);
    });
  });

  group('GIVEN the shell is on shop home', () {
    group('WHEN navigateToAisle is called', () {
      setUp(() {
        sut.navigateToAisle('collections');
      });

      test('THEN currentRoute becomes aisleDetail', () {
        expect(sut.currentRoute.value, ShowcaseRoute.aisleDetail);
      });

      test('THEN selectedAisleKey becomes the given key', () {
        expect(sut.selectedAisleKey.value, 'collections');
      });

      test('THEN selectedProductKey remains null', () {
        expect(sut.selectedProductKey.value, isNull);
      });
    });

    group('WHEN openProduct is called with a known route', () {
      setUp(() {
        sut.openProduct(ShowcaseRoute.tBentoGrid);
      });

      test('THEN currentRoute becomes the product route', () {
        expect(sut.currentRoute.value, ShowcaseRoute.tBentoGrid);
      });

      test('THEN selectedAisleKey becomes the product aisle', () {
        expect(sut.selectedAisleKey.value, 'collections');
      });

      test('THEN selectedProductKey becomes the widget name', () {
        expect(sut.selectedProductKey.value, 'TBentoGrid');
      });
    });

    group('WHEN goBack is called', () {
      test('THEN it is a no-op (stays on shop home)', () {
        sut.goBack();
        expect(sut.currentRoute.value, ShowcaseRoute.shopHome);
        expect(sut.selectedAisleKey.value, isNull);
        expect(sut.selectedProductKey.value, isNull);
      });
    });
  });

  group('GIVEN the shell is on an aisle detail', () {
    setUp(() {
      sut.navigateToAisle('navigation');
    });

    group('WHEN openProduct is called', () {
      setUp(() {
        sut.openProduct(ShowcaseRoute.tContextualAppBar);
      });

      test('THEN currentRoute becomes the product route', () {
        expect(sut.currentRoute.value, ShowcaseRoute.tContextualAppBar);
      });

      test('THEN selectedAisleKey matches the product aisle', () {
        expect(sut.selectedAisleKey.value, 'navigation');
      });

      test('THEN selectedProductKey is the widget name', () {
        expect(sut.selectedProductKey.value, 'TContextualAppBar');
      });
    });

    group('WHEN goBack is called', () {
      test('THEN it returns to shop home', () {
        sut.goBack();
        expect(sut.currentRoute.value, ShowcaseRoute.shopHome);
        expect(sut.selectedAisleKey.value, isNull);
        expect(sut.selectedProductKey.value, isNull);
      });
    });

    group('WHEN navigateToShopHome is called', () {
      test('THEN it clears aisle and product selections', () {
        sut.navigateToShopHome();
        expect(sut.currentRoute.value, ShowcaseRoute.shopHome);
        expect(sut.selectedAisleKey.value, isNull);
        expect(sut.selectedProductKey.value, isNull);
      });
    });
  });

  group('GIVEN the shell is on a product detail', () {
    setUp(() {
      sut.navigateToAisle('layout_and_motion');
      sut.openProduct(ShowcaseRoute.tVerticalShrink);
    });

    group('WHEN goBack is called', () {
      setUp(() {
        sut.goBack();
      });

      test('THEN currentRoute returns to aisleDetail', () {
        expect(sut.currentRoute.value, ShowcaseRoute.aisleDetail);
      });

      test('THEN selectedAisleKey is preserved', () {
        expect(sut.selectedAisleKey.value, 'layout_and_motion');
      });

      test('THEN selectedProductKey is cleared', () {
        expect(sut.selectedProductKey.value, isNull);
      });
    });

    group('WHEN goBack is called twice', () {
      test('THEN it returns to shop home', () {
        sut.goBack(); // product → aisle
        sut.goBack(); // aisle → home
        expect(sut.currentRoute.value, ShowcaseRoute.shopHome);
        expect(sut.selectedAisleKey.value, isNull);
        expect(sut.selectedProductKey.value, isNull);
      });
    });

    group('WHEN navigateToAisle is called directly', () {
      test('THEN it jumps to that aisle and clears product', () {
        sut.navigateToAisle('utilities');
        expect(sut.currentRoute.value, ShowcaseRoute.aisleDetail);
        expect(sut.selectedAisleKey.value, 'utilities');
        expect(sut.selectedProductKey.value, isNull);
      });
    });
  });

  group('GIVEN openProduct is called with an unknown route', () {
    test('THEN it is a no-op', () {
      sut.openProduct(ShowcaseRoute.shopHome);
      expect(sut.currentRoute.value, ShowcaseRoute.shopHome);
      expect(sut.selectedAisleKey.value, isNull);
      expect(sut.selectedProductKey.value, isNull);
    });
  });

  group('GIVEN toggleTheme is called', () {
    test('THEN it delegates to ThemeService', () {
      expect(themeService.brightness.value, Brightness.light);
      sut.toggleTheme();
      expect(themeService.brightness.value, Brightness.dark);
    });
  });

  group('GIVEN reactive notifications', () {
    test('WHEN navigateToAisle is called THEN currentRoute notifies', () {
      var notified = false;
      sut.currentRoute.addListener(() => notified = true);
      sut.navigateToAisle('collections');
      expect(notified, isTrue);
    });

    test('WHEN openProduct is called THEN selectedProductKey notifies', () {
      var notified = false;
      sut.selectedProductKey.addListener(() => notified = true);
      sut.openProduct(ShowcaseRoute.tBentoGrid);
      expect(notified, isTrue);
    });
  });
}
