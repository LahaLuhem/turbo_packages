## ADDED Requirements

### Requirement: Update pubspec dependency from pew_pew_cli to turbo_plx_cli

The system SHALL replace pew_pew_cli with turbo_plx_cli in each consumer's pubspec.yaml.

#### Scenario: Path dependency for sibling repos

- **WHEN** consumer is a sibling repo under Repos (e.g. plaza)
- **THEN** dependency uses `path: ../turbo_packages/turbo_plx_cli`

#### Scenario: Git dependency for non-siblings

- **WHEN** consumer is not a sibling of turbo_packages
- **THEN** dependency uses git URL and path per turbo_plx_cli pubspec.yaml

### Requirement: Update Dart imports from pew_pew_cli to turbo_plx_cli

The system SHALL replace `package:pew_pew_cli` with `package:turbo_plx_cli` in all .dart files of each consumer.

#### Scenario: Import replacement

- **WHEN** migrating a consumer
- **THEN** every occurrence of `package:pew_pew_cli` is replaced with `package:turbo_plx_cli`

### Requirement: Verify each migrated consumer

The system SHALL run dart pub get, dart analyze, and tests for each consumer after migration.

#### Scenario: Consumer passes verification

- **WHEN** migration is applied to a consumer
- **THEN** dart pub get (or flutter pub get), dart analyze, and tests pass
