import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/theme/t_sizes.dart';

class TBreadcrumbsBar extends StatelessWidget {
  const TBreadcrumbsBar({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.deviceType.isMobile;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0x3318181B),
            border: Border(
              bottom: BorderSide(
                width: TSizes.borderWidth,
                color: Color(0x0DFFFFFF),
              ),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1600),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: isMobile ? 8 : 12,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
