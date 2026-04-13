import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/theme/t_sizes.dart';
import 'package:turbo_widgets/src/widgets/states/t_empty_placeholder/t_empty_placeholder.dart';

/// Viewport-centered placeholder for entity-not-found (404-like) states.
class TNotFoundPlaceholder extends StatelessWidget {
  const TNotFoundPlaceholder({
    super.key,
    required this.title,
    this.subtitle,
    required this.iconData,
  });

  final String title;
  final String? subtitle;
  final IconData iconData;

  static const _verticalPadding = 64.0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TSizes.appPadding,
          vertical: _verticalPadding,
        ),
        child: TEmptyPlaceholder(
          title: title,
          subtitle: subtitle,
          iconData: iconData,
        ),
      ),
    );
  }
}
