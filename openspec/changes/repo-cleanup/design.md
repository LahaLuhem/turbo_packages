## Context

The `turbo_packages` monorepo has accumulated uncommitted work across multiple concerns. The `turbo_plx_cli` package was renamed to `pew_pew_cli` but only partially staged — old files are deleted (unstaged), new files are untracked. A `TBentoGrid` bug fix and formatting changes are unstaged. 10 commits on `main` are not pushed to `origin/main`. A circular symlink `turbo_packages` was removed from the filesystem but is not gitignored.

## Goals / Non-Goals

**Goals:**
- Push all unpushed commits to `origin/main`
- Complete the `turbo_plx_cli` → `pew_pew_cli` rename with a clean commit
- Commit the `TBentoGrid` animation controller bug fix
- Add `turbo_packages` to `.gitignore`
- Verify all packages analyze, format, and test clean
- Achieve a clean `git status` with all changes pushed

**Non-Goals:**
- Publishing new package versions to pub.dev
- Squashing or rewriting the 10 existing commits
- Removing the stash or stale branches
- Upgrading dependencies

## Decisions

1. **Push existing commits as-is**: The 10 commits have poor messages ("fix: fix") but the user explicitly chose not to squash them. Push them before making new commits to avoid rebase complications.

2. **Commit order**: Rename commit first (largest change), then BentoGrid fix (scoped to one file), then gitignore (trivial). This groups related changes logically and makes each commit self-contained.

3. **Rely on root `.gitignore` for `pew_pew_cli/` staging**: The root `.gitignore` already excludes `.dart_tool/`, `.idea/`, `coverage/`, and `.DS_Store`, so `git add pew_pew_cli/` will automatically exclude build artifacts without needing additional gitignore entries.

4. **Use `dart-mcp` for all Dart operations**: Per project conventions, use `analyze_files`, `dart_format`, and `run_tests` MCP tools instead of bash commands for Dart/Flutter operations.

## Risks / Trade-offs

- **[Risk] Pushing "fix: fix" commits permanently pollutes git history** → Accepted by user. The commits contain valid code changes (BentoGrid rename, dependency updates) despite poor messages.
- **[Risk] `pew_pew_cli` tests may fail if dependencies aren't resolved** → Mitigated by running `dart pub get` and `melos bootstrap` before testing.
- **[Risk] Analysis warnings in packages unrelated to current changes** → Per project policy, all warnings must be fixed or raised to user regardless of relevance to current task.
