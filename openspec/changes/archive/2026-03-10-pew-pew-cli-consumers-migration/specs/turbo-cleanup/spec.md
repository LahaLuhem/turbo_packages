## ADDED Requirements

### Requirement: Archive obsolete repo-cleanup change

The system SHALL archive the repo-cleanup OpenSpec change without syncing delta specs (they describe the wrong rename direction).

#### Scenario: repo-cleanup archived

- **WHEN** openspec archive is executed for repo-cleanup
- **THEN** the change is archived and no longer appears as active

### Requirement: Rename legacy test file

The system SHALL rename turbo_plx_cli/test/pew_pew_cli_test.dart to turbo_plx_cli_test.dart.

#### Scenario: Test file renamed

- **WHEN** turbo cleanup runs
- **THEN** turbo_plx_cli/test/turbo_plx_cli_test.dart exists and pew_pew_cli_test.dart does not

### Requirement: Verify turbo_plx_cli health

The system SHALL run dart pub get, melos bootstrap, make analyze, and make test for turbo_plx_cli.

#### Scenario: turbo_plx_cli passes verification

- **WHEN** turbo cleanup completes
- **THEN** make analyze package=turbo_plx_cli and make test package=turbo_plx_cli pass
