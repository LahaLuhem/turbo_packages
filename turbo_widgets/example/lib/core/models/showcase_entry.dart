import 'package:flutter/widgets.dart';

import '../enums/showcase_route.dart';

/// Metadata for a single widget product in the Turbo Widgets Shop.
///
/// Each entry maps a turbo_widgets export to its aisle, display info,
/// and the route that opens its product detail page.
class ShowcaseEntry {
  const ShowcaseEntry({
    required this.widgetName,
    required this.aisleKey,
    required this.tagline,
    required this.route,
    required this.icon,
  });

  /// Display name of the widget (e.g. 'TBentoGrid').
  final String widgetName;

  /// Key of the aisle this widget belongs to (e.g. 'collections').
  final String aisleKey;

  /// One-line description shown on product cards and detail headers.
  final String tagline;

  /// Route that opens this widget's product detail page.
  final ShowcaseRoute route;

  /// Icon displayed on product cards for this widget.
  final IconData icon;
}
