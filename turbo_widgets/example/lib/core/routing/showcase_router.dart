import 'package:flutter/material.dart';

import '../enums/showcase_route.dart';

/// Resolves a [ShowcaseRoute] to its corresponding view widget.
///
/// For now, every route returns a placeholder. Later tasks will replace
/// each placeholder with the real showcase view.
class ShowcaseRouter {
  const ShowcaseRouter._();

  /// Returns the widget for the given [route].
  ///
  /// [aisleKey] is only used when [route] is [ShowcaseRoute.aisleDetail].
  static Widget resolve(ShowcaseRoute route, {String? aisleKey}) {
    return switch (route) {
      ShowcaseRoute.shopHome => const _Placeholder(label: 'Shop Home'),
      ShowcaseRoute.aisleDetail => _Placeholder(
        label: 'Aisle: ${aisleKey ?? 'unknown'}',
      ),
      _ => _Placeholder(label: route.name),
    };
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}
