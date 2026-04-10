# 🎨 Turbo Widgets

[![Pub Version](https://img.shields.io/pub/v/turbo_widgets?logo=dart&label=turbo_widgets)](https://pub.dev/packages/turbo_widgets)
[![License: BSD-3-Clause](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![GitHub Stars](https://img.shields.io/github/stars/appboypov/turbo_packages?style=social)](https://github.com/appboypov/turbo_packages)

**Turbo Widgets** is a collection of common reusable UI widgets, extensions, and animation utilities for Flutter applications. It provides convenient widgets and extensions to speed up Flutter development.

## Features

- **Convenient Widgets**: Pre-built widgets like `TRow`, `TColumn`, `TPadding`, `TMargin`, `TDivider`, and more
- **Animation Utilities**: Widgets like `TAnimatedSize` and `TSlideShrink` for smooth animations
- **Extensions**: Helpful extensions for numbers, strings, durations, and more
- **Badge & Chip Widgets**: Ready-to-use badge and chip widgets for UI elements
- **Contextual Buttons**: `TContextualButtons` for overlay buttons with position and variation support
- **Navigation Components**: `TBottomNavigation`, `TTopNavigation`, `TSideNavigation` for flexible navigation bars
- **View Builder**: `TViewBuilder` for combining `TContextualButtons` and `TViewModelBuilder` in a single widget

## Installation

Add `turbo_widgets` to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  turbo_widgets: ^1.1.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Widgets

```dart
import 'package:turbo_widgets/turbo_widgets.dart';

// Convenient padding
TPadding.app() // Standard app padding (16.0)
TPadding.button() // Button padding (16.0 horizontal, 0 vertical)
TPadding.card() // Card padding (12.0)

// Layout widgets
TRow(
  children: [
    // Your widgets
  ],
)

TColumn(
  children: [
    // Your widgets
  ],
)

// Divider
TDivider(
  height: 1.0,
  color: Colors.grey,
)
```

### Extensions

```dart
// Number extensions
5.0.scale(0.5) // Scale a number

// String extensions
'hello'.capitalize() // Capitalize first letter

// Duration extensions
Duration(seconds: 5).format() // Format duration
```

### Contextual Buttons

```dart
// Create a service with button configuration
final service = TContextualButtonsService(
  TContextualButtonsConfig(
    bottom: TContextualButtonsSlotConfig(
      primary: [MyBottomBar()],
    ),
    left: TContextualButtonsSlotConfig(
      primary: [MySideNavigation()],
    ),
  ),
);

// Wrap your content
TContextualButtons(
  service: service,
  child: YourMainContent(),
)
```

### Navigation Components

```dart
// Bottom navigation
TBottomNavigation(
  buttons: {
    'home': TButtonConfig(icon: Icons.home, label: 'Home', onPressed: () {}),
    'search': TButtonConfig(icon: Icons.search, label: 'Search', onPressed: () {}),
  },
  selectedKey: 'home',
)

// Side navigation
TSideNavigation(
  buttons: buttonMap,
  selectedKey: 'home',
  direction: Axis.vertical,
)

// Top navigation
TTopNavigation(
  buttons: buttonMap,
  selectedKey: 'home',
)
```

### TViewBuilder

`TViewBuilder` is a convenience widget that combines `TContextualButtons` and `TViewModelBuilder` for views that need both contextual actions and view model management.

```dart
// Basic usage
TViewBuilder<MyViewModel>(
  viewModelBuilder: () => MyViewModel(),
  builder: (context, viewModel, isInitialised, child) {
    return MyViewContent(viewModel: viewModel);
  },
)

// With custom contextual buttons service
final service = TContextualButtonsService(
  TContextualButtonsConfig(
    bottom: TContextualButtonsSlotConfig(
      primary: [MyBottomBar()],
    ),
  ),
);

TViewBuilder<MyViewModel>(
  service: service,
  viewModelBuilder: () => MyViewModel(),
  builder: (context, viewModel, isInitialised, child) {
    return MyViewContent(viewModel: viewModel);
  },
)
```

## Example

Check the `/example` directory for a complete Flutter application demonstrating Turbo Widgets features.

## Contributing

Contributions are welcome! Please open issues or pull requests on our [GitHub repository](https://github.com/appboypov/turbo_packages).

## License

This package is licensed under the BSD 3-Clause License. See the [LICENSE](LICENSE) file for details.
