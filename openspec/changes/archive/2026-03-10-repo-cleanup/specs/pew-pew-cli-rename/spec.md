## ADDED Requirements

### Requirement: Package rename from turbo_plx_cli to pew_pew_cli is fully committed
The git history SHALL reflect the complete removal of `turbo_plx_cli/` and addition of `pew_pew_cli/` in a single commit. All documentation files (`ARCHITECTURE.md`, `CLAUDE.md`, `pubspec.yaml`) SHALL reference `pew_pew_cli` instead of `turbo_plx_cli`.

#### Scenario: Old package files are removed from git
- **WHEN** the rename commit is applied
- **THEN** no files under `turbo_plx_cli/` exist in the git index

#### Scenario: New package files are tracked by git
- **WHEN** the rename commit is applied
- **THEN** all source files under `pew_pew_cli/` (excluding build artifacts) are tracked in git

#### Scenario: No stale references remain in Dart or YAML files
- **WHEN** searching all `.dart` and `.yaml` files for `turbo_plx_cli`
- **THEN** zero matches are found (except `pew_pew_cli/CHANGELOG.md` which documents the rename history)

#### Scenario: Workspace includes pew_pew_cli
- **WHEN** inspecting the root `pubspec.yaml` workspace list
- **THEN** `pew_pew_cli` is listed and `turbo_plx_cli` is not
