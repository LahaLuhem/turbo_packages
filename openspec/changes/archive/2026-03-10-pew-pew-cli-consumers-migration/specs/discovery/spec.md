## ADDED Requirements

### Requirement: Discover pew_pew_cli consumers in pubspec files

The system SHALL search for projects that list `pew_pew_cli` as a dependency in pubspec.yaml files under the discovery root.

#### Scenario: Find pubspec consumers

- **WHEN** running `rg "pew_pew_cli" --glob pubspec.yaml -l "$DISCOVERY_ROOT"`
- **THEN** the command returns paths to all pubspec.yaml files containing pew_pew_cli

### Requirement: Discover pew_pew_cli imports in Dart files

The system SHALL search for Dart files that import `package:pew_pew_cli` under the discovery root.

#### Scenario: Find dart import consumers

- **WHEN** running `rg "package:pew_pew_cli" --type dart -l "$DISCOVERY_ROOT"`
- **THEN** the command returns paths to all .dart files importing pew_pew_cli

### Requirement: Exclude known non-consumers from migration list

The system SHALL exclude turbo_packages and pew_pew_plx from the consumer list.

#### Scenario: Filter out turbo_packages

- **WHEN** processing discovery results
- **THEN** any path under turbo_packages is excluded from the migration list

#### Scenario: Filter out pew_pew_plx

- **WHEN** processing discovery results
- **THEN** any path under pew_pew_plx is excluded from the migration list

### Requirement: Record discovery results in migration log

The system SHALL write a migration log with project path, pubspec paths, dart files, and status for each consumer.

#### Scenario: Migration log created

- **WHEN** discovery completes
- **THEN** migration_log.md exists at openspec/changes/pew-pew-cli-consumers-migration/ with entries for each consumer
