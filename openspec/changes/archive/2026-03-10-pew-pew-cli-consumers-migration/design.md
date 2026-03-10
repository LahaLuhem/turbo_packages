## Context

`pew_pew_cli` was renamed to `turbo_plx_cli` and moved into the turbo_packages monorepo. The old package name no longer exists. External projects (e.g. plaza) that depended on `pew_pew_cli` via path or git will fail to resolve. Discovery root is `/Users/codaveto/Repos`; sibling repos assumed there. The obsolete `repo-cleanup` OpenSpec change describes the wrong rename direction and must be archived.

## Goals / Non-Goals

**Goals:**

- Archive obsolete repo-cleanup change
- Discover all pew_pew_cli consumers via rg
- Clean up turbo_plx_cli (rename legacy test file)
- Migrate each external consumer to turbo_plx_cli
- Verify zero pew_pew_cli references outside history

**Non-Goals:**

- pew_pew_plx repo (already migrated)
- turbo_packages monorepo internals (package already turbo_plx_cli)

## Decisions

1. **Discovery tool**: Use ripgrep (`rg`) for pubspec.yaml and dart imports. Simple, fast, no extra deps.
2. **Discovery root**: `DISCOVERY_ROOT=/Users/codaveto/Repos` by default; override via env if needed.
3. **Exclusions**: Exclude turbo_packages and pew_pew_plx from consumer list.
4. **Migration log**: Write to `openspec/changes/pew-pew-cli-consumers-migration/migration_log.md` with project path, pubspec paths, dart files, status.
5. **Consumer dependency**: Path `../turbo_packages/turbo_plx_cli` for sibling repos; git+path for non-siblings per turbo_plx_cli pubspec.
6. **Archive repo-cleanup**: User confirms archive without sync (delta specs describe wrong direction).

## Risks / Trade-offs

- **Discovery misses nested repos**: Mitigation — rg from Repos root with recursive search.
- **Path vs git dependency**: Mitigation — document both; path for siblings, git for others.
- **repo-cleanup archive loses artifacts**: Mitigation — archive without sync; delta specs are wrong anyway.

## Migration Plan

1. Archive repo-cleanup (openspec archive, no sync)
2. Run discovery (rg pew_pew_cli, rg package:pew_pew_cli)
3. Turbo cleanup (rename test file, analyze, test)
4. For each consumer: update pubspec, update imports, pub get, analyze, test
5. Final verification: rg pew_pew_cli returns zero (except CHANGELOG/history)
