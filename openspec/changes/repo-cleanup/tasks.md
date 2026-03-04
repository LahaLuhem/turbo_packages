## 1. Push Existing Unpushed Commits

- [ ] 1.1 Push all unpushed commits on main to origin/main with `git push origin main`
- [ ] 1.2 Verify `git log --oneline origin/main..main` returns empty

## 2. Complete turbo_plx_cli to pew_pew_cli Rename

- [ ] 2.1 Stage deleted turbo_plx_cli files with `git add turbo_plx_cli/`
- [ ] 2.2 Stage new pew_pew_cli directory with `git add pew_pew_cli/` (root .gitignore excludes build artifacts)
- [ ] 2.3 Stage updated docs with `git add ARCHITECTURE.md CLAUDE.md pubspec.yaml`
- [ ] 2.4 Commit with message `chore: rename turbo_plx_cli to pew_pew_cli`

## 3. Commit TBentoGrid Bug Fix

- [ ] 3.1 Stage `turbo_widgets/lib/src/widgets/layout/t_bento_grid.dart`
- [ ] 3.2 Commit with message `fix(turbo_widgets): move fade/scale animation init to initState in TBentoGrid`

## 4. Add turbo_packages to .gitignore

- [ ] 4.1 Add `turbo_packages` entry under a `# Symlinks` section at end of `.gitignore`
- [ ] 4.2 Stage and commit with message `chore: add turbo_packages symlink to gitignore`

## 5. Bootstrap and Verify All Packages

- [ ] 5.1 Run `dart pub get` at root to resolve workspace dependencies
- [ ] 5.2 Run `melos bootstrap` to bootstrap all packages
- [ ] 5.3 Run analysis on all packages — must be zero warnings/errors
- [ ] 5.4 Run format check on all packages — must be no formatting changes needed
- [ ] 5.5 Run tests on all testable packages — must be all passing
- [ ] 5.6 Fix any issues found and commit fixes if needed

## 6. Push All New Commits

- [ ] 6.1 Push all new commits to origin/main with `git push origin main`
- [ ] 6.2 Verify `git status` shows clean working tree
- [ ] 6.3 Verify `git log --oneline origin/main..main` returns empty
