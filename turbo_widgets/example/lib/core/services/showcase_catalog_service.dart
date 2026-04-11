import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../enums/showcase_route.dart';
import '../models/showcase_entry.dart';

/// Lists every public turbo_widgets widget as a [ShowcaseEntry], grouped by
/// aisle. Supports lookup by route and by aisle key.
class ShowcaseCatalogService {
  ShowcaseCatalogService();

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static ShowcaseCatalogService get locate => GetIt.I<ShowcaseCatalogService>();

  static void registerLazySingleton() {
    GetIt.I.registerLazySingleton<ShowcaseCatalogService>(
      () => ShowcaseCatalogService(),
    );
  }

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\
  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\

  /// Every product in the shop, in display order.
  final List<ShowcaseEntry> entries = [
    // -- Navigation --
    ShowcaseEntry(
      widgetName: 'TContextualAppBar',
      aisleKey: 'navigation',
      tagline: 'Contextual app bar driven by route-specific button configs',
      route: ShowcaseRoute.tContextualAppBar,
      icon: LucideIcons.panelTop,
    ),
    ShowcaseEntry(
      widgetName: 'TContextualBottomNavigation',
      aisleKey: 'navigation',
      tagline: 'Bottom navigation bar that swaps content per route',
      route: ShowcaseRoute.tContextualBottomNavigation,
      icon: LucideIcons.panelBottom,
    ),
    ShowcaseEntry(
      widgetName: 'TContextualSideNavigation',
      aisleKey: 'navigation',
      tagline: 'Side rail navigation for tablet and desktop layouts',
      route: ShowcaseRoute.tContextualSideNavigation,
      icon: LucideIcons.panelLeft,
    ),
    ShowcaseEntry(
      widgetName: 'TContextualNavButton',
      aisleKey: 'navigation',
      tagline: 'Individual navigation button used inside contextual bars',
      route: ShowcaseRoute.tContextualNavButton,
      icon: LucideIcons.squareMenu,
    ),
    ShowcaseEntry(
      widgetName: 'TSideNavBar',
      aisleKey: 'navigation',
      tagline: 'Standalone side navigation bar with expand/collapse',
      route: ShowcaseRoute.tSideNavBar,
      icon: LucideIcons.panelLeftOpen,
    ),
    ShowcaseEntry(
      widgetName: 'TContextualButtons',
      aisleKey: 'navigation',
      tagline: 'Overlay that renders contextual buttons at configured positions',
      route: ShowcaseRoute.tContextualButtons,
      icon: LucideIcons.layers,
    ),
    ShowcaseEntry(
      widgetName: 'ContextualButtonsProvider',
      aisleKey: 'navigation',
      tagline: 'InheritedWidget that maps routes to contextual button configs',
      route: ShowcaseRoute.contextualButtonsProvider,
      icon: LucideIcons.share2,
    ),

    // -- Collections --
    ShowcaseEntry(
      widgetName: 'TFeatureCard',
      aisleKey: 'collections',
      tagline: 'Highlighted card for featuring a single item prominently',
      route: ShowcaseRoute.tFeatureCard,
      icon: LucideIcons.star,
    ),
    ShowcaseEntry(
      widgetName: 'TCategoryCard',
      aisleKey: 'collections',
      tagline: 'Compact card representing a browsable category',
      route: ShowcaseRoute.tCategoryCard,
      icon: LucideIcons.tag,
    ),
    ShowcaseEntry(
      widgetName: 'TCategoryHeader',
      aisleKey: 'collections',
      tagline: 'Banner header displayed above a category section',
      route: ShowcaseRoute.tCategoryHeader,
      icon: LucideIcons.heading,
    ),
    ShowcaseEntry(
      widgetName: 'TCategorySection',
      aisleKey: 'collections',
      tagline: 'Horizontal or grid section of category cards with show-all toggle',
      route: ShowcaseRoute.tCategorySection,
      icon: LucideIcons.layoutGrid,
    ),
    ShowcaseEntry(
      widgetName: 'TCollectionCard',
      aisleKey: 'collections',
      tagline: 'Standard card for items inside a collection section',
      route: ShowcaseRoute.tCollectionCard,
      icon: LucideIcons.squareStack,
    ),
    ShowcaseEntry(
      widgetName: 'TCollectionHeader',
      aisleKey: 'collections',
      tagline: 'Hero banner at the top of a collection listing',
      route: ShowcaseRoute.tCollectionHeader,
      icon: LucideIcons.image,
    ),
    ShowcaseEntry(
      widgetName: 'TCollectionListItem',
      aisleKey: 'collections',
      tagline: 'List-style row for collection sections in list layout',
      route: ShowcaseRoute.tCollectionListItem,
      icon: LucideIcons.list,
    ),
    ShowcaseEntry(
      widgetName: 'TCollectionSection',
      aisleKey: 'collections',
      tagline: 'Multi-layout section: bento, list, or grid with toolbar support',
      route: ShowcaseRoute.tCollectionSection,
      icon: LucideIcons.galleryVertical,
    ),
    ShowcaseEntry(
      widgetName: 'TCollectionToolbar',
      aisleKey: 'collections',
      tagline: 'Search, sort, filter, and layout toolbar for collection sections',
      route: ShowcaseRoute.tCollectionToolbar,
      icon: LucideIcons.slidersHorizontal,
    ),
    ShowcaseEntry(
      widgetName: 'TBentoGrid',
      aisleKey: 'collections',
      tagline: 'Animated bento-style grid with configurable item sizes',
      route: ShowcaseRoute.tBentoGrid,
      icon: LucideIcons.layoutDashboard,
    ),

    // -- Detail & Forms --
    ShowcaseEntry(
      widgetName: 'TDetailHeader',
      aisleKey: 'detail_and_forms',
      tagline: 'Header section for detail pages with title and actions',
      route: ShowcaseRoute.tDetailHeader,
      icon: LucideIcons.fileText,
    ),
    ShowcaseEntry(
      widgetName: 'TKeyValueField',
      aisleKey: 'detail_and_forms',
      tagline: 'Read-only label-value row for displaying metadata',
      route: ShowcaseRoute.tKeyValueField,
      icon: LucideIcons.rows3,
    ),
    ShowcaseEntry(
      widgetName: 'TFormSection',
      aisleKey: 'detail_and_forms',
      tagline: 'Grouped form section with title, driven by config or children',
      route: ShowcaseRoute.tFormSection,
      icon: LucideIcons.clipboardList,
    ),
    ShowcaseEntry(
      widgetName: 'TInteractiveForm',
      aisleKey: 'detail_and_forms',
      tagline: 'Multi-step interactive form with text, card selection, and calendar steps',
      route: ShowcaseRoute.tInteractiveForm,
      icon: LucideIcons.listChecks,
    ),

    // -- Layout & Motion --
    ShowcaseEntry(
      widgetName: 'TCalculatedHeight',
      aisleKey: 'layout_and_motion',
      tagline: 'Wrapper that calculates its height from child item count',
      route: ShowcaseRoute.tCalculatedHeight,
      icon: LucideIcons.ruler,
    ),
    ShowcaseEntry(
      widgetName: 'TVerticalShrink',
      aisleKey: 'layout_and_motion',
      tagline: 'Animated vertical show/hide with fade and size transitions',
      route: ShowcaseRoute.tVerticalShrink,
      icon: LucideIcons.unfoldVertical,
    ),
    ShowcaseEntry(
      widgetName: 'THorizontalShrink',
      aisleKey: 'layout_and_motion',
      tagline: 'Animated horizontal show/hide with fade and size transitions',
      route: ShowcaseRoute.tHorizontalShrink,
      icon: LucideIcons.unfoldHorizontal,
    ),
    ShowcaseEntry(
      widgetName: 'TCollapsibleSection',
      aisleKey: 'layout_and_motion',
      tagline: 'Expandable section with header tap to reveal content',
      route: ShowcaseRoute.tCollapsibleSection,
      icon: LucideIcons.chevronDown,
    ),

    // -- Utilities --
    ShowcaseEntry(
      widgetName: 'TViewBuilder',
      aisleKey: 'utilities',
      tagline: 'MVVM host that couples view models with contextual buttons',
      route: ShowcaseRoute.tViewBuilder,
      icon: LucideIcons.blocks,
    ),
    ShowcaseEntry(
      widgetName: 'TResponsiveBuilder',
      aisleKey: 'utilities',
      tagline: 'Layout builder that exposes device type, orientation, and scaling tools',
      route: ShowcaseRoute.tResponsiveBuilder,
      icon: LucideIcons.monitor,
    ),
    ShowcaseEntry(
      widgetName: 'TMarkdownFileItem',
      aisleKey: 'utilities',
      tagline: 'Renders inline markdown content with an open action',
      route: ShowcaseRoute.tMarkdownFileItem,
      icon: LucideIcons.fileCode,
    ),
  ];

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// All known aisle keys in display order.
  static const List<String> aisleKeys = [
    'navigation',
    'collections',
    'detail_and_forms',
    'layout_and_motion',
    'utilities',
  ];

  /// Human-readable label for an aisle key.
  static String aisleLabel(String key) {
    return switch (key) {
      'navigation' => 'Navigation',
      'collections' => 'Collections',
      'detail_and_forms' => 'Detail & Forms',
      'layout_and_motion' => 'Layout & Motion',
      'utilities' => 'Utilities',
      _ => key,
    };
  }

  /// Short tagline for an aisle key.
  static String aisleTagline(String key) {
    return switch (key) {
      'navigation' =>
        'App shells, tab bars, side rails, and the contextual button system',
      'collections' =>
        'Cards, lists, bento grids, and everything that turns a list of stuff into a browsable shelf',
      'detail_and_forms' => 'Detail pages, forms, and multi-step flows',
      'layout_and_motion' =>
        'Shrinks, calculated heights, and the little helpers that make UIs feel alive',
      'utilities' =>
        'Building blocks: view builders, responsive helpers, markdown previews',
      _ => '',
    };
  }

  /// Returns all entries belonging to [aisleKey].
  List<ShowcaseEntry> byAisle(String aisleKey) {
    return entries.where((e) => e.aisleKey == aisleKey).toList();
  }

  /// Returns the entry matching [route], or `null` if not found.
  ShowcaseEntry? byRoute(ShowcaseRoute route) {
    for (final entry in entries) {
      if (entry.route == route) return entry;
    }
    return null;
  }
}
