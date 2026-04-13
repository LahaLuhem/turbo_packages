# Changelog

All notable changes to the turbo_packages monorepo will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.0.0] - 2026-02-01

First official pub.dev release of all publishable packages at 160/160 pana score.

### Published

- turbo_response 1.1.0
- turbo_serializable 0.3.0
- turbo_notifiers 1.1.0
- turbolytics 1.1.0
- turbo_mvvm 1.1.0
- turbo_forms 1.0.1
- turbo_firestore_api 0.9.0
- turbo_promptable 0.0.1 (first release)

### Changed

- Workspace sibling dependencies now use `^version` constraints instead of blank constraints for pub.dev compatibility
- Updated shadcn_ui to ^0.45.1 across turbo_forms
- Added equatable ^2.0.5 constraint to turbo_forms
- Added dartdoc comments to turbo_forms public API
- Added turbo_forms example file

### Infrastructure

- Added root and per-package Makefiles with analyze, format, test, fix, pub-check targets
- Added test coverage script (tool/test_with_coverage.sh)
- Added pub-check validation script for pana 160/160 scoring
- Enhanced analysis options across packages
- Added CLAUDE.md project instructions
- Added PROGRESS.md release tracking protocol
