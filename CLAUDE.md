# CLAUDE.md

<Memory>
@PROGRESS.md
@MEMORY.md
</Memory>

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Dart/Flutter monorepo managed by Melos containing 11 published packages and 1 production Flutter template app (`turbo_template`). All packages are published to pub.dev except `turbo_template`.

## Commands

### Setup
```bash
dart pub get && melos bootstrap
```

### All Packages (via root Makefile or Melos)
```bash
make analyze                          # dart analyze --fatal-infos (warnings are errors)
make fix                              # dart fix --apply
make format                           # dart format .
make test                             # tests with coverage via tool/test_with_coverage.sh
make build                            # build_runner code generation
make all                              # clean, get, fix, format, analyze, test
make pub-check                        # validate 160/160 pub.dev points with pana
```

### Single Package
```bash
make analyze package=turbo_response   # analyze one package
make test package=turbo_response      # test one package
make build package=turbo_mvvm         # build_runner for one package
```

Each package also has its own Makefile with `help`, `build`, `clean`, `test`, `format`, `analyze`, `fix`, `watch`, `get` targets. Pure Dart packages use `dart` commands; Flutter packages use `flutter` commands.

### Running a Single Test File
```bash
cd turbo_response && dart test test/turbo_response_test.dart
cd turbo_notifiers && flutter test test/t_notifier_test.dart
```

## Package Dependency Hierarchy

```
turbo_response          (foundation, no dependencies)
  └─► turbo_serializable  (adds YAML/Markdown/XML serialization)
turbo_notifiers         (standalone, Flutter only)
turbolytics             (standalone, GetIt service locator + logging)
turbo_mvvm              (standalone, Provider-based MVVM)
turbo_firestore_api     (turbo_response + turbo_serializable + turbo_notifiers + turbolytics)
turbo_forms             (turbo_notifiers + turbolytics + shadcn_ui)
turbo_widgets           (turbo_mvvm + turbo_forms + shadcn_ui)
turbo_promptable        (turbo_serializable + turbo_response)
turbo_plx_cli             (turbo_response)
turbo_template          (all turbo packages + Firebase)
```

## Architecture Patterns

**Result Type**: All fallible operations return `TurboResponse<T>` (sealed: `Success<T>` / `Fail<T>`). Pattern match with `when()`, `fold()`, `mapSuccess()`, `andThen()`. Never throw exceptions in business logic.

**MVVM**: `TBaseViewModel<A>` extends `ChangeNotifier`, provided via `TViewModelBuilder` (Provider). Compose mixins: `TBusyManagement`, `TErrorManagement`, `TViewModelHelpers`.

**Reactive State**: `TNotifier<T>` extends `ValueNotifier` with `forceUpdate` for collection types, `silentUpdate()`, and `updateCurrent()`. Multi-value listening via `ValueListenableBuilderX2`–`X6` and `MultiListenableBuilder`.

**Firestore Services**: `TFirestoreApi<T>` for type-safe CRUD. `TCollectionService` for collection state with optimistic local updates. `TDocumentService` for single-document state. `TAuthSyncService` syncs with Firebase Auth. Sync variants: `AfSync`, `BeSync`, `BeAfSync`.

**Serialization**: `TWriteable` (toJson + validate) → `TWriteableId` (adds String id for Firestore). `TSerializable` adds multi-format output (YAML, Markdown, XML) via builder pattern.

**DI**: GetIt via turbolytics for service location. Provider for widget-tree scoped view models.

## Key Conventions

- **Workspace dependencies**: Sibling workspace packages use `^version` constraints matching their current published version (e.g., `turbo_response: ^1.1.0`). Inside the workspace, the local version is used (but must satisfy the constraint). Outside the workspace (e.g. pub.dev consumers, pana), the constraint resolves from pub.dev — blank constraints resolve to `any` which pulls the oldest published version, breaking builds and pana's downgrade test.
- **Naming**: ViewModels end with `ViewModel`, Services with `Service`, APIs with `Api`, DTOs with `Dto`. Turbo types prefixed with `T` (e.g., `TNotifier`, `TFormField`).
- **Analysis**: Strict — `dart analyze --fatal-infos`. Trailing commas required. Single quotes preferred. Const constructors enforced.
- **Generated files excluded**: `*.g.dart`, `*.freezed.dart`, `*.mocks.dart` excluded from analysis, formatting, and coverage.
- **Test frameworks**: `test` for pure Dart, `flutter_test` for Flutter, `gherkin_unit_test` for BDD (turbo_mvvm), `mockito` for mocking.
- **Publishing**: Must pass `make pub-check` (160/160 pana score) before publishing. Scripts in `tool/`.
- **UI framework**: ShadCN UI (`shadcn_ui`) for forms and widgets packages.
