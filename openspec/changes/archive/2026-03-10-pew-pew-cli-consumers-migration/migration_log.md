# pew_pew_cli → turbo_plx_cli Migration Log

## Discovery Summary

**Discovery root:** /Users/codaveto/Repos
**Excluded:** turbo_packages, pew_pew_plx, archived/pew_pew_cli.old (old package, not consumer)

## Consumers

| Project Path | Pubspec | Dart Files | Status |
|--------------|---------|------------|--------|
| /Users/codaveto/Repos/pew_pew_plaza/flutter-app | pubspec.yaml | 15 files | migrated |

### pew_pew_plaza/flutter-app

- **Pubspec:** /Users/codaveto/Repos/pew_pew_plaza/flutter-app/pubspec.yaml
- **Dart files:**
  - lib/folders/widgets/expandable_file_row.dart
  - lib/folders/widgets/file_item_card.dart
  - lib/folders/services/folders_service.dart
  - lib/folders/views/folder_detail/folder_detail_view.dart
  - lib/folders/views/folder_detail/folder_detail_view_model.dart
  - lib/folders/utils/folder_file_utils.dart
  - lib/core/plx/services/file_content_enricher.dart
  - lib/core/plx/services/plx_service.dart
  - lib/core/plx/abstracts/plx_file_reader.dart
  - lib/types/services/type_matching_service.dart
  - test/folders/services/folders_service_test.dart
  - test/folders/views/folder_detail/folder_detail_view_model_file_editor_test.dart
  - test/core/plx/services/plx_service_test.dart
  - test/core/plx/services/file_content_enricher_test.dart
  - test/types/services/type_matching_service_test.dart

## Excluded (not consumers)

| Path | Reason |
|------|--------|
| /Users/codaveto/Repos/archived/pew_pew_cli.old | Old package source, not a consumer |
