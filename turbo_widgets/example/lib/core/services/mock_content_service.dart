import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:turbo_widgets/turbo_widgets.dart';

/// Provides neutral placeholder content for showcase views.
///
/// All mock data lives here — views and view models never hardcode content.
class MockContentService {
  MockContentService();

  // 📍 LOCATOR ------------------------------------------------------------------------------- \\

  static MockContentService get locate => GetIt.I<MockContentService>();

  static void registerLazySingleton() {
    GetIt.I.registerLazySingleton<MockContentService>(
      () => MockContentService(),
    );
  }

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\
  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\
  // 🎩 STATE --------------------------------------------------------------------------------- \\

  /// Sample category items for category section demos.
  final List<({String title, String subtitle, IconData icon})> categories =
      const [
        (
          title: 'Category A',
          subtitle: 'First sample category',
          icon: LucideIcons.folder,
        ),
        (
          title: 'Category B',
          subtitle: 'Second sample category',
          icon: LucideIcons.folderOpen,
        ),
        (
          title: 'Category C',
          subtitle: 'Third sample category',
          icon: LucideIcons.folderTree,
        ),
        (
          title: 'Category D',
          subtitle: 'Fourth sample category',
          icon: LucideIcons.folderClosed,
        ),
      ];

  /// Sample collection items for collection section demos.
  final List<({String title, String description, IconData icon})>
  collectionItems = const [
    (
      title: 'Item Alpha',
      description: 'A sample item for demonstrating collection layouts',
      icon: LucideIcons.box,
    ),
    (
      title: 'Item Beta',
      description: 'Another sample item with a different icon',
      icon: LucideIcons.package2,
    ),
    (
      title: 'Item Gamma',
      description: 'Third sample item for grid and list views',
      icon: LucideIcons.archive,
    ),
    (
      title: 'Item Delta',
      description: 'Fourth sample item for bento layout demos',
      icon: LucideIcons.inbox,
    ),
    (
      title: 'Item Epsilon',
      description: 'Fifth sample item for toolbar filtering demos',
      icon: LucideIcons.packageOpen,
    ),
    (
      title: 'Item Zeta',
      description: 'Sixth sample item for search and sort demos',
      icon: LucideIcons.gift,
    ),
  ];

  /// Sample card options for the interactive form card selection step.
  final List<TCardOption> plans = [
    TCardOption(
      title: 'Plan A',
      icon: LucideIcons.zap,
      onTap: () {},
      isSelected: () => false,
    ),
    TCardOption(
      title: 'Plan B',
      icon: LucideIcons.flame,
      onTap: () {},
      isSelected: () => false,
    ),
    TCardOption(
      title: 'Plan C',
      icon: LucideIcons.rocket,
      onTap: () {},
      isSelected: () => false,
    ),
  ];

  /// Sample metadata rows for detail header and key-value field demos.
  final List<({String label, String value})> metadataFields = const [
    (label: 'Version', value: '1.2.0'),
    (label: 'Author', value: 'turbo_widgets'),
    (label: 'License', value: 'MIT'),
    (label: 'Platform', value: 'Flutter'),
  ];

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// Returns a markdown snippet for demo purposes.
  String markdownContent(String fileName) {
    return switch (fileName) {
      'usage' => '''
## Usage

```dart
Widget build(BuildContext context) {
  return TFeatureCard(
    title: 'Sample',
    subtitle: 'A sample feature card',
    icon: LucideIcons.star,
    onTap: () {},
  );
}
```
''',
      'overview' => '''
## Overview

This widget is part of the **turbo_widgets** package.
It provides a reusable, customisable component
for building Flutter applications.
''',
      _ => '''
## $fileName

Sample markdown content for **$fileName**.
''',
    };
  }
}
