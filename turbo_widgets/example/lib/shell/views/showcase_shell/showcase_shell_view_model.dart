import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';

import '../../../core/enums/showcase_route.dart';
import '../../../core/services/showcase_catalog_service.dart';
import '../../../core/services/theme_service.dart';

/// Drives the top-level shell of the Turbo Widgets Shop.
///
/// Owns the current route, selected aisle, and selected product as reactive
/// cells. Every piece of navigation state lives here — the view is a
/// stateless delegator.
class ShowcaseShellViewModel extends TBaseViewModel<void> {
  ShowcaseShellViewModel({
    required ShowcaseCatalogService showcaseCatalogService,
    required ThemeService themeService,
  })  : _showcaseCatalogService = showcaseCatalogService,
        _themeService = themeService;

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static ShowcaseShellViewModel get locate => GetIt.I.get();

  static void registerFactory() => GetIt.I.registerFactory(
        () => ShowcaseShellViewModel(
          showcaseCatalogService: ShowcaseCatalogService.locate,
          themeService: ThemeService.locate,
        ),
      );

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  final ShowcaseCatalogService _showcaseCatalogService;
  final ThemeService _themeService;

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  @override
  void dispose() {
    _currentRoute.dispose();
    _selectedAisleKey.dispose();
    _selectedProductKey.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final TNotifier<ShowcaseRoute> _currentRoute =
      TNotifier<ShowcaseRoute>(ShowcaseRoute.shopHome);

  final TNotifier<String?> _selectedAisleKey = TNotifier<String?>(null);

  final TNotifier<String?> _selectedProductKey = TNotifier<String?>(null);

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// The route currently being displayed.
  ValueListenable<ShowcaseRoute> get currentRoute => _currentRoute;

  /// The aisle key highlighted in the nav chrome, or `null` on shop home.
  ValueListenable<String?> get selectedAisleKey => _selectedAisleKey;

  /// The widget name of the currently-opened product, or `null` when not on
  /// a product detail route.
  ValueListenable<String?> get selectedProductKey => _selectedProductKey;

  /// The app-wide brightness mode, owned by [ThemeService].
  ValueListenable<Brightness> get brightness => _themeService.brightness;

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  /// Navigates to the shop home, clearing aisle and product selections.
  void navigateToShopHome() {
    _currentRoute.value = ShowcaseRoute.shopHome;
    _selectedAisleKey.value = null;
    _selectedProductKey.value = null;
  }

  /// Navigates to the listing for [aisleKey], clearing any open product.
  void navigateToAisle(String aisleKey) {
    _currentRoute.value = ShowcaseRoute.aisleDetail;
    _selectedAisleKey.value = aisleKey;
    _selectedProductKey.value = null;
  }

  /// Opens the product detail page for [route].
  ///
  /// Looks up the entry in the catalog to determine the aisle. If [route]
  /// does not match a known product, this is a no-op.
  void openProduct(ShowcaseRoute route) {
    final entry = _showcaseCatalogService.byRoute(route);
    if (entry == null) return;
    _currentRoute.value = route;
    _selectedAisleKey.value = entry.aisleKey;
    _selectedProductKey.value = entry.widgetName;
  }

  /// Pops one level of navigation depth.
  ///
  /// Product detail → aisle detail → shop home. No-op when already on shop
  /// home.
  void goBack() {
    if (_selectedProductKey.value != null) {
      // From product detail → aisle detail (keep the aisle selected).
      _currentRoute.value = ShowcaseRoute.aisleDetail;
      _selectedProductKey.value = null;
      return;
    }
    if (_selectedAisleKey.value != null) {
      // From aisle detail → shop home.
      navigateToShopHome();
      return;
    }
    // Already on shop home — no-op.
  }

  /// Delegates to [ThemeService] to flip between light and dark mode.
  void toggleTheme() => _themeService.toggleBrightness();
}
