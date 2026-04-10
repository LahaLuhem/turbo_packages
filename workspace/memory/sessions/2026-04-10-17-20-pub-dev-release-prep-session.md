---
conversation-id: 274727a1-1236-4645-99af-0fa0650051d1
---

# Session: 2026-04-10

**Started:** ~4pm
**Last Updated:** 5:20pm
**Project:** turbo_packages (Dart/Flutter monorepo)
**Topic:** Preparing all 10 pub.dev packages for release — version bumps, pana 160/160, CHANGELOGs, formatting, analysis fixes

---

## What We Are Building

Full pub.dev release preparation across the entire turbo_packages monorepo (10 publishable packages). The goal was to get every package to 160/160 pana score with accurate CHANGELOGs, correct version numbers, clean analysis, and proper formatting.

Four packages had unpublished changes requiring new versions:
- **turbo_serializable 0.3.1** — widened `TMdFrontmatter` typedef from `Map<String, String>` to `Map<String, dynamic>`
- **turbo_forms 1.0.2** — updated `shadcn_ui` dependency from `^0.45.1` to `^0.53.5`
- **turbo_widgets 1.2.0** — removed Component Playground, reorganized widgets, updated shadcn_ui + turbo_forms deps
- **turbo_promptable 0.1.0** — massive workspace model system restructure, added barrel file, dartdocs, example

---

## What WORKED (with evidence)

- **turbo_serializable 0.3.1 — 160/160 pana** — confirmed by: `dart pub global run pana .` returned `Points: 160/160`
- **turbo_forms 1.0.2 — 160/160 pana** — confirmed by: `dart pub global run pana .` returned `Points: 160/160`
- **shadcn_ui ^0.53.5 upgrade causes zero breakage** — confirmed by: `dart analyze .` returned "No issues found!" for turbo_widgets, turbo_forms, and turbo_widgets/example
- **All 6 unchanged packages remain at 160/160 pana** — confirmed by: ran pana on each (turbo_response, turbo_notifiers, turbolytics, turbo_mvvm, turbo_firestore_api, turbo_plx_cli)
- **Zero analysis issues across all 10 publishable packages** — confirmed by: ran `dart analyze .` in each package directory
- **Zero formatting issues** — confirmed by: `dart format --output=none --set-exit-if-changed .` reported "0 changed"
- **turbo_widgets tests pass** — confirmed by: `flutter test` → "22 tests passed"
- **Commit and push succeeded** — confirmed by: commit `4080f13`, pushed to `main`

---

## What Did NOT Work (and why)

- **`dart pub upgrade --tighten` from turbo_promptable** — tightened constraints across the ENTIRE workspace, including packages we weren't releasing. This changed `turbo_serializable` constraint to `^0.3.1` in turbo_firestore_api (which isn't published yet), causing turbo_firestore_api pana to drop from 160/160 to 50/160. Fixed by reverting non-target package pubspec changes via `git checkout`.
- **turbo_promptable pana scoring** — can't reach 160/160 until `turbo_serializable 0.3.1` is published on pub.dev. Pana resolves deps from pub.dev and `^0.3.1` doesn't exist there yet. Same cascading issue for turbo_widgets needing `turbo_forms: ^1.0.2`.

---

## What Has NOT Been Tried Yet

- **Actually publishing the packages to pub.dev** — the commit is pushed but no `dart pub publish` has been run
- **Running pana on turbo_widgets and turbo_promptable after their deps are published** — expected to be 160/160 but not confirmed
- **turbo_promptable README review** — the README was not audited for accuracy against the new 0.1.0 API

---

## Current State of Files

All changes are committed (`4080f13`) and pushed to `main`. Working tree is clean.

| File | Status | Notes |
| --- | --- | --- |
| `pubspec.yaml` (root) | ✅ Complete | Removed nonexistent `turbo_widgets/widgetbook` from workspace |
| `turbo_serializable/pubspec.yaml` | ✅ Complete | Version 0.3.1, tightened dep constraints |
| `turbo_serializable/CHANGELOG.md` | ✅ Complete | Added 0.3.1 entry |
| `turbo_serializable/lib/abstracts/t_serializable.dart` | ✅ Complete | Fixed `if` without braces (pana lint) |
| `turbo_serializable/lib/extensions/*.dart` | ✅ Complete | Formatting fixes |
| `turbo_forms/pubspec.yaml` | ✅ Complete | Version 1.0.2, shadcn_ui ^0.53.5 |
| `turbo_forms/CHANGELOG.md` | ✅ Complete | Added 1.0.2 entry |
| `turbo_widgets/pubspec.yaml` | ✅ Complete | Version 1.2.0, shadcn_ui ^0.53.5, turbo_forms ^1.0.2 |
| `turbo_widgets/CHANGELOG.md` | ✅ Complete | Changed [Unreleased] to [1.2.0] |
| `turbo_widgets/example/pubspec.yaml` | ✅ Complete | Reverted tighten changes |
| `turbo_promptable/pubspec.yaml` | ✅ Complete | Version 0.1.0, turbo_serializable ^0.3.1, tightened deps |
| `turbo_promptable/CHANGELOG.md` | ✅ Complete | Full rewrite with 0.0.2 and 0.1.0 entries |
| `turbo_promptable/lib/turbo_promptable.dart` | ✅ Complete | New barrel file exporting all public API |
| `turbo_promptable/example/turbo_promptable_example.dart` | ✅ Complete | New example demonstrating Agent/Role/Workflow creation |
| `turbo_promptable/lib/**/*.dart` (17 files) | ✅ Complete | Added dartdoc comments (~28% coverage) |
| `turbo_firestore_api/test/t_collection_service_ready_on_error_test.dart` | ✅ Complete | Removed unnecessary `cloud_firestore` import |
| `turbo_plx_cli/lib/**/*.dart` (4 files) | ✅ Complete | Formatting fixes |
| `turbo_template/flutter-app/pubspec.yaml` | ✅ Complete | Updated shadcn_ui to ^0.53.5 |

---

## Decisions Made

- **turbo_widgets 1.2.0 (not 2.0.0)** — reason: user chose 1.2.0; playground removal is not a breaking change to the stable public API
- **turbo_promptable 0.1.0** — reason: user chose this; massive restructure warrants minor bump on pre-1.0 package
- **shadcn_ui updated to ^0.53.5 everywhere** — reason: user explicitly requested update; zero breakage confirmed
- **turbo_forms bumped to 1.0.2** — reason: necessary because turbo_widgets depends on turbo_forms and pana resolves from pub.dev — turbo_forms needed the shadcn_ui constraint published first
- **Reverted `dart pub upgrade --tighten` on non-target packages** — reason: tighten changed turbo_serializable constraint to ^0.3.1 in packages we weren't releasing, breaking their pana scores since 0.3.1 isn't on pub.dev

---

## Blockers & Open Questions

- **Publish order is strict and sequential:**
  1. `turbo_serializable 0.3.1` (no blockers)
  2. `turbo_forms 1.0.2` (no blockers)
  3. `turbo_widgets 1.2.0` (blocked until turbo_forms 1.0.2 is on pub.dev)
  4. `turbo_promptable 0.1.0` (blocked until turbo_serializable 0.3.1 is on pub.dev)
- **turbo_promptable README** has not been reviewed against the 0.1.0 API — may need updating

---

## Recommended Tools

**Skills to load** (via Skill tool):
- `prepare-flutter-package` — if individual packages need further prep after publishing deps

**MCP tools to use**:
- None specific

**CLI tools**:
- `dart pub publish` — the actual publishing command needed next
- `dart pub global run pana .` — verify 160/160 after each publish

---

## Relevant Files to Read

- `turbo_promptable/CHANGELOG.md` — full changelog for the 0.1.0 release
- `turbo_widgets/CHANGELOG.md` — changelog for the 1.2.0 release
- `turbo_serializable/CHANGELOG.md` — changelog for the 0.3.1 release
- `turbo_forms/CHANGELOG.md` — changelog for the 1.0.2 release

---

## Exact Next Step

Publish packages in order. Run these commands one at a time, waiting for each to appear on pub.dev before proceeding:

```bash
cd turbo_serializable && dart pub publish
cd ../turbo_forms && dart pub publish
# Wait ~1-2 minutes for pub.dev to index, then:
cd ../turbo_widgets && dart pub global run pana . && dart pub publish
cd ../turbo_promptable && dart pub global run pana . && dart pub publish
```

After turbo_widgets and turbo_promptable are published, run `pana` on each to confirm 160/160.
