/// Every navigable route in the Turbo Widgets Shop.
///
/// [shopHome] is the storefront landing page.
/// [aisleDetail] is the listing for a single aisle (parameterised by aisle key).
/// The remaining values are product detail routes — one per public widget.
enum ShowcaseRoute {
  // -- Top-level routes --
  shopHome,
  aisleDetail,

  // -- Navigation aisle products --
  tContextualAppBar,
  tContextualBottomNavigation,
  tContextualSideNavigation,
  tContextualNavButton,
  tSideNavBar,
  tContextualButtons,
  contextualButtonsProvider,

  // -- Collections aisle products --
  tFeatureCard,
  tCategoryCard,
  tCategoryHeader,
  tCategorySection,
  tCollectionCard,
  tCollectionHeader,
  tCollectionListItem,
  tCollectionSection,
  tCollectionToolbar,
  tBentoGrid,

  // -- Detail & Forms aisle products --
  tDetailHeader,
  tKeyValueField,
  tFormSection,
  tInteractiveForm,

  // -- Layout & Motion aisle products --
  tCalculatedHeight,
  tVerticalShrink,
  tHorizontalShrink,
  tCollapsibleSection,

  // -- Utilities aisle products --
  tViewBuilder,
  tResponsiveBuilder,
  tMarkdownFileItem,
}
