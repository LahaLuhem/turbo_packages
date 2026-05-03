# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-05-03

### Changed
- **BREAKING**: `TurboResponse.result` getter now returns `T?` instead of `T`. On `Fail` states it returns `null` instead of throwing `TurboException`. Use `unwrap()` for the throwing behavior.
- `Fail<T>` now has an explicit `result` override returning `null`
- Code formatting aligned to Dart 3.10 style

## [1.1.0] - 2026-01-17

### Changed
* Converted package from Flutter to pure Dart
* Removed `flutter_test` from dev_dependencies
* Updated Makefile to use `dart` commands instead of `flutter` commands
* Converted example application from Flutter app to pure Dart CLI script
* Removed all Flutter platform-specific files (android, ios, linux, macos, windows, web)

### Platform
* Package now requires only Dart SDK, no Flutter SDK needed
* All tooling updated to use pure Dart commands

## [1.0.1] - 2026-01-01

### Changed
* Updated GitHub repository URLs to appboypov organization.

## [1.0.0] - 2025-01-01

### Changed
* Version update to match pub.dev published version.

## [0.2.6] - 2025-01-01

### Changed
* Renamed internal classes for better code organization
* Updated method names for better clarity and consistency

### Documentation
* Enhanced documentation with clearer descriptions

## [0.2.5] - 2025-01-01

### Added
* Added title and message support for empty responses

### Changed
* Enhanced empty response handling with more descriptive information
* Renamed internal classes for better code organization
* Updated method names for better clarity and consistency

## [0.2.4] - 2025-01-01

### Changed
* Moved Flutter to dev_dependencies - now works with pure Dart projects with zero Flutter dependencies

### Documentation
* Enhanced documentation to highlight Dart compatibility

### Platform
* Added platform-agnostic support with improved package structure

### Chore
* Updated package metadata and topics

## [0.2.3] - 2025-01-01

### Added
* Added static `throwFail` method for creating and throwing failures in one step

## [0.2.2] - 2025-01-01

### Changed
* Renamed `throwFail` to `throwWhenFail` for better clarity

## [0.2.1] - 2025-01-01

### Changed
* Updated package description to be more concise

### Documentation
* Enhanced documentation with emojis and better formatting

## [0.2.0] - 2025-01-01

### Added
* Added support for async operations in `mapSuccess` and `andThen` methods

### Changed
* Updated function parameter names to be more descriptive in IDE tooltips

### Documentation
* Improved documentation with better examples and parameter names

## [0.1.0] - 2025-01-01

### Added
* Initial release with core functionality
* Added support for success and failure states
* Added pattern matching with `when` and `maybeWhen`
* Added transformation methods like `mapSuccess`, `mapFail`, and `andThen`
* Added utility methods like `unwrap`, `unwrapOr`, and `ensure`
* Added static utility methods `traverse` and `sequence`
