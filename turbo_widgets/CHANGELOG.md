# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-04-10

### Removed
- Component Playground (TPlayground) and its enums, constants, models, and widgets
- `device_frame_plus`, `flutter_animate`, and `gap` dependencies

### Changed
- Reorganised widgets under `lib/src/widgets/` into `contextual/` and `misc/` subfolders
- Renamed `contextual_buttons_provider.dart` to `t_contextual_buttons_provider.dart`
- Updated `shadcn_ui` dependency from `^0.45.1` to `^0.53.5`
- Updated `turbo_forms` dependency from `^1.0.1` to `^1.0.2`

## [1.1.0] - 2026-01-20

### Added
- TContextualButtons widget for contextual overlay buttons with position and variation support
- TContextualButtonsService and TContextualButtonsConfig for flexible button configuration
- TContextualAllowFilter for position filtering (top, bottom, left, right, all)
- TContextualVariation for primary/secondary button variations
- TBottomNavigation, TTopNavigation, TSideNavigation components with TButtonConfig model
- TPlayground device frame preview mode with device selection
- TPlayground dynamic parameter system with TPlaygroundParameterModel
- TCollapsibleSection widget for expandable content sections
- TViewBuilder widget combining TContextualButtons and TViewModelBuilder for views with contextual actions
- turbo_mvvm dependency for TViewModelBuilder integration

### Changed
- TPlayground layout restructured with improved padding and component organization
- Parameter handling streamlined in playground components

### Fixed
- Playground expansion state handling
- Dark mode button text and hover colors

## [1.0.0] - 2025-01-06

### Added
- Common reusable UI widgets, extensions, and animation utilities for Flutter
- Widget library for Flutter applications
- Animation utilities using `flutter_animate`
- Layout utilities using `gap` package
- Reusable components for consistent UI
