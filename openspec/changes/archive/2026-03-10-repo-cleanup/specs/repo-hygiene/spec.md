## ADDED Requirements

### Requirement: All unpushed commits are pushed to origin
All commits on `main` that are ahead of `origin/main` SHALL be pushed to the remote.

#### Scenario: No unpushed commits remain
- **WHEN** running `git log --oneline origin/main..main` after push
- **THEN** the output is empty

### Requirement: turbo_packages symlink is gitignored
The `.gitignore` file SHALL contain an entry for `turbo_packages` to prevent a circular symlink from being accidentally committed.

#### Scenario: Gitignore contains turbo_packages entry
- **WHEN** inspecting `.gitignore`
- **THEN** a `turbo_packages` entry exists

### Requirement: All packages pass analysis
Every package in the monorepo SHALL pass `dart analyze --fatal-infos` with zero warnings and zero errors.

#### Scenario: Clean analysis across all packages
- **WHEN** running analysis on all packages
- **THEN** zero issues are reported

### Requirement: All packages pass formatting check
Every Dart source file in the monorepo SHALL comply with `dart format`.

#### Scenario: No formatting changes needed
- **WHEN** running format check on all packages
- **THEN** zero files require changes

### Requirement: All package tests pass
Every package with a `test/` directory SHALL have all tests passing.

#### Scenario: Test suites pass
- **WHEN** running tests on all testable packages
- **THEN** all tests pass with zero failures

### Requirement: Git working tree is clean
After all commits and pushes, `git status` SHALL report a clean working tree with nothing to commit.

#### Scenario: Clean git status
- **WHEN** running `git status` after all work is complete
- **THEN** output shows "nothing to commit, working tree clean"
