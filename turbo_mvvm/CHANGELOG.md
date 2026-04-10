# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-04-09

### Changed
- Reorganised internal file layout under `lib/data/abstracts/` (e.g. `t_base_view_model.dart`). No public API changes, but consumers that imported internal `src/` paths should migrate to the public barrel `package:turbo_mvvm/turbo_mvvm.dart`.

## [1.1.0] - 2026-01-20

### Added
- `TurboMvvmDefaults` class centralizing all default constants (isReactive, shouldDispose, timeout, minBusy)

### Changed
- **BREAKING**: Renamed `BaseViewModel<A>` → `TurboViewModel<A>` for consistency with package naming
- **BREAKING**: Renamed `ViewModelBuilder<T>` → `TurboViewModelBuilder<T>` for consistency with package naming
- **BREAKING**: Renamed `ViewModelBuilderState<T>` → `TurboViewModelBuilderState<T>` for consistency with package naming
- Updated all documentation, examples, and tests to use new class names
- `TViewModelBuilder` now uses `TurboMvvmDefaults` for default parameter values
- `TBusyService` and `TBusyServiceManagement` now use `TurboMvvmDefaults` for timeout and minBusy defaults

### Removed
- `TMvvmDurations` class (consolidated into `TurboMvvmDefaults`)

### Migration Guide
To migrate from v1.0.0 to v1.1.0:
- Replace `BaseViewModel` with `TurboViewModel` in all class declarations
- Replace `ViewModelBuilder` with `TurboViewModelBuilder` in all widget usage
- Update imports if using direct file imports (barrel imports remain the same)

## [1.0.0] - 2025-01-06

### Added
- `TurboViewModel` (formerly `BaseViewModel`) for MVVM pattern implementation
- `TurboViewModelBuilder` (formerly `ViewModelBuilder`) widget for reactive UI updates
- Automatic lifecycle management (`initialise` and `dispose`)
- `BusyManagement` mixin for local busy states
- `ErrorManagement` mixin for error handling
- `ViewModelHelpers` mixin for utility methods
- `BusyServiceManagement` mixin for global busy state
- `BusyService` singleton for application-wide busy indicators
- `BusyModel` with support for title, message, type, and payload
- `BusyType` enum for different busy indicator styles
- Timeout functionality for busy states
- `AkeBaseViewModel` and `AkeViewModelBuilder` for automatic keep-alive
- Safe `BuildContext` access via `context` getter
- `isMounted` check for widget tree presence
- Argument passing to ViewModels
- `isInitialised` notifier for initialization tracking
- Reactive and non-reactive ViewModel support
- Custom dispose callbacks
- All features from previous versions (0.0.1 - 0.0.15)

### Changed
- Package renamed from `veto` to `turbo_mvvm`
- Updated import paths to use `package:turbo_mvvm/turbo_mvvm.dart`
- Integrated Provider package for efficient state propagation
- Made `TurboViewModel` (formerly `BaseViewModel`) a `ChangeNotifier`
- Enhanced busy state management with timeouts
- Improved error handling
- Better context access safety
- Enhanced documentation and examples
- Generic arguments of payload changed to dynamic
- `isBusy` renamed to `isBusyListenable`, new `isBusy` bool getter added

### Fixed
- Fixed non-reactive ViewModel disposal
- Fixed `Ake` classes naming and functionality
- Fixed missing payload in BusyServiceManagement
- Fixed duration bugs
- Fixed reactive ViewModel rebuild issues
- Fixed argument nullability

### Removed
- Various deprecated APIs from previous versions
