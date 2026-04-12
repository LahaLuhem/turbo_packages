# Turbo Widgets Shop — Example App

The example app is an interactive showcase built around a **shop metaphor**.
Every public widget in `turbo_widgets` is a "product" displayed on a detail
page. Products are grouped into **aisles** (Navigation, Collections,
Detail & Forms, Layout & Motion, Utilities). The storefront landing page links
to each aisle, and each aisle lists its products.

## Folder Layout

```
example/lib/
├── core/
│   ├── enums/          # ShowcaseRoute enum
│   ├── globals/        # GetIt composition root
│   ├── models/         # ShowcaseEntry data class
│   ├── routing/        # ShowcaseRouter (route → view resolver)
│   └── services/       # ShowcaseCatalogService, MockContentService, ThemeService
├── shell/
│   └── views/          # Top-level shell (app bar, side nav, bottom nav)
└── showcase/
    ├── shared/         # ProductDetailPage skeleton reused by every product view
    └── feature/
        ├── shop_home/
        ├── aisle_detail/
        ├── navigation/
        ├── collections/
        ├── detail_and_forms/
        ├── layout_and_motion/
        └── utilities/
            └── views/
                └── {widget_snake_case}_showcase/
                    ├── {widget_snake_case}_showcase_view.dart
                    └── {widget_snake_case}_showcase_view_model.dart
```

Each aisle folder under `showcase/feature/` follows the same structure: a
`views/` directory containing one subfolder per product. Every product
subfolder holds exactly two files — a view and a view model.

## Adding a New Widget to the Shop

When you add a new public widget to `turbo_widgets`, follow these four steps
to make it appear in the showcase.

### Step 1 — Add a route enum value

**File:** `example/lib/core/enums/showcase_route.dart`

Add a new value to the `ShowcaseRoute` enum under the comment block for the
widget's aisle:

```dart
enum ShowcaseRoute {
  // ...

  // -- Utilities aisle products --
  tViewBuilder,
  tResponsiveBuilder,
  tMarkdownFileItem,
  tMyNewWidget,           // ← add here
}
```

### Step 2 — Register the catalog entry

**File:** `example/lib/core/services/showcase_catalog_service.dart`

Append a `ShowcaseEntry` to the `entries` list inside the aisle's section.
Every field is required:

```dart
ShowcaseEntry(
  widgetName: 'TMyNewWidget',
  aisleKey: 'utilities',                       // must match an aisleKeys value
  tagline: 'One-line description of the widget',
  route: ShowcaseRoute.tMyNewWidget,
  icon: LucideIcons.sparkles,                  // pick a Lucide icon
),
```

### Step 3 — Create the product view and view model

**Folder:** `example/lib/showcase/feature/{aisle}/views/t_my_new_widget_showcase/`

Create two files:

1. **`t_my_new_widget_showcase_view_model.dart`** — a `TBaseViewModel<void>`
   subclass exposing reactive `TNotifier` cells for every knob the visitor
   can tweak in the debug controls.

2. **`t_my_new_widget_showcase_view.dart`** — a `StatelessWidget` that wraps
   `TViewBuilder<TMyNewWidgetShowcaseViewModel>` and returns a
   `ProductDetailPage` (from `showcase/shared/product_detail_page.dart`).

The `ProductDetailPage` skeleton expects:

| Parameter         | What to provide                                           |
|-------------------|-----------------------------------------------------------|
| `title`           | Widget display name (e.g. `'TMyNewWidget'`)               |
| `description`     | One-line tagline                                          |
| `metadata`        | List of `TKeyValueField`s (Aisle, Source path, Type)      |
| `preview`         | Live preview widget bound to the view model's cells       |
| `debugControls`   | List of input/toggle widgets that mutate the view model   |
| `usageSnippet`    | Markdown string with a canonical usage example            |

Optional: `advancedControls` (rendered inside a collapsible section).

Use existing showcase views as reference — the simplest is
`detail_and_forms/views/t_key_value_field_showcase/`, the most complex is
`collections/views/t_bento_grid_showcase/`.

### Step 4 — Wire the route in the router

**File:** `example/lib/core/routing/showcase_router.dart`

Add a case to the `switch` inside `ShowcaseRouter.resolve()`:

```dart
ShowcaseRoute.tMyNewWidget =>
  const TMyNewWidgetShowcaseView(),
```

The switch is exhaustive — the Dart compiler will flag a missing case at
build time, but adding it explicitly keeps the file tidy.

## After You're Done

Update the route count assertion in the router test so CI stays green:

**File:** `example/test/core/routing/showcase_router_test.dart`

```dart
expect(ShowcaseRoute.values.length, 29); // was 28
```

Run verification:

```bash
cd turbo_widgets/example
flutter analyze --no-pub   # must report 0 issues
flutter test               # router test must pass
```
