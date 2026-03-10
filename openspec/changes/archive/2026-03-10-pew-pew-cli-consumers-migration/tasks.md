## 1. Archive Obsolete repo-cleanup Change

- [x] 1.1 Run openspec list, confirm repo-cleanup exists
- [x] 1.2 Execute openspec-archive-change for repo-cleanup (user confirms archive without sync; delta specs describe wrong direction)

## 2. Discovery of pew_pew_cli Consumers

- [x] 2.1 Set DISCOVERY_ROOT=/Users/codaveto/Repos (or override from env)
- [x] 2.2 Run: rg "pew_pew_cli" --glob pubspec.yaml -l "$DISCOVERY_ROOT"
- [x] 2.3 Run: rg "package:pew_pew_cli" --type dart -l "$DISCOVERY_ROOT"
- [x] 2.4 Exclude turbo_packages and pew_pew_plx from results
- [x] 2.5 Write migration log to openspec/changes/pew-pew-cli-consumers-migration/migration_log.md with: project path, pubspec paths, dart files, status

## 3. Turbo Packages Cleanup

- [x] 3.1 Rename turbo_plx_cli/test/pew_pew_cli_test.dart to turbo_plx_cli/test/turbo_plx_cli_test.dart
- [x] 3.2 Run dart pub get && melos bootstrap at turbo_packages root
- [x] 3.3 Run make analyze package=turbo_plx_cli
- [x] 3.4 Run make test package=turbo_plx_cli
- [x] 3.5 Fix any failures; commit changes

## 4. Migrate Each External Consumer

- [x] 4.0 For each project in migration_log.md, repeat 4.1–4.5
- [x] 4.1 In pubspec.yaml: replace pew_pew_cli with turbo_plx_cli; use path dependency to ../turbo_packages/turbo_plx_cli if sibling, or git+path per turbo_plx_cli/pubspec.yaml
- [x] 4.2 In all .dart files: replace "package:pew_pew_cli" with "package:turbo_plx_cli"
- [x] 4.3 Run dart pub get (or flutter pub get)
- [x] 4.4 Run dart analyze
- [x] 4.5 Run tests; fix failures; update migration_log.md status

## 5. Final Verification

- [x] 5.1 Re-run discovery (rg pew_pew_cli) — must return zero results outside CHANGELOG/history
- [x] 5.2 Confirm migration_log.md lists all consumers with status "migrated"
