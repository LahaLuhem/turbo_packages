## Why

The repo accumulated uncommitted work across multiple concerns after a period of inactivity: a half-done package rename (`turbo_plx_cli` → `pew_pew_cli`), an uncommitted bug fix in `TBentoGrid`, unpushed commits, and a stale symlink risk. The repo needs to be cleaned up, all changes committed, and all packages verified healthy before any new work or publishing.

## What Changes

- Complete the `turbo_plx_cli` → `pew_pew_cli` package rename (stage deletions, stage new package, commit)
- Commit the `TBentoGrid` bug fix (animation controller init moved from build to initState) and formatting improvements
- Push all unpushed commits on `main` to `origin/main`
- Add `turbo_packages` to `.gitignore` to prevent circular symlink from being committed
- Bootstrap, analyze, format-check, and test all packages to verify repo health

## Capabilities

### New Capabilities

- `pew-pew-cli-rename`: Completing the package rename from `turbo_plx_cli` to `pew_pew_cli` including git staging, doc updates, and workspace config
- `bento-grid-fix`: Bug fix moving fade/scale animation controller initialization from build method to initState in `TBentoGrid`
- `repo-hygiene`: Gitignore update for circular symlink prevention, pushing unpushed commits, full repo health verification

### Modified Capabilities

## Impact

- `turbo_plx_cli/` directory removed from git tracking, replaced by `pew_pew_cli/`
- `ARCHITECTURE.md`, `CLAUDE.md`, `pubspec.yaml` updated with new package name
- `turbo_widgets/lib/src/widgets/layout/t_bento_grid.dart` bug fix committed
- `.gitignore` updated with `turbo_packages` entry
- All packages must pass `dart analyze --fatal-infos`, `dart format`, and tests
