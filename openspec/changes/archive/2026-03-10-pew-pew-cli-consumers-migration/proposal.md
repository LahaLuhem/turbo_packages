## Why

`pew_pew_cli` was renamed to `turbo_plx_cli` to match the `turbo_`* naming used by other packages. The package has been moved into the turbo_packages monorepo. Any project still depending on `pew_pew_cli` will fail to resolve or build. Consumers must be discovered and migrated to `turbo_plx_cli`.

## What Changes

- Archive the obsolete `repo-cleanup` OpenSpec change (its delta specs describe the wrong rename direction)
- Discover all projects that reference or depend on `pew_pew_cli` (pubspec.yaml and dart imports)
- Clean up turbo_packages: rename legacy test file `pew_pew_cli_test.dart` to `turbo_plx_cli_test.dart`
- Migrate each external consumer: update pubspec dependency and dart imports from `pew_pew_cli` to `turbo_plx_cli`
- Final verification: zero references to `pew_pew_cli` outside CHANGELOG/history

## Capabilities

### New Capabilities

- `discovery`: Commands and process to find all projects depending on `pew_pew_cli` (pubspec.yaml and dart imports), excluding turbo_packages and pew_pew_plx
- `migration`: Steps to update each consumer's pubspec and dart imports, with verification
- `turbo-cleanup`: Archive repo-cleanup change, rename test file, verify turbo_plx_cli health

### Modified Capabilities

## Impact

- External consumers (e.g. plaza) must update dependencies and imports
- `openspec/changes/repo-cleanup/` archived
- `turbo_plx_cli/test/pew_pew_cli_test.dart` renamed to `turbo_plx_cli_test.dart`
- Migration log documents all consumers and status
