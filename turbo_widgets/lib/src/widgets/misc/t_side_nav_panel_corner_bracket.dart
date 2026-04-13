import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/theme/t_colors.dart';
import 'package:turbo_widgets/src/theme/t_sizes.dart';

/// Outer corner accents for side panels (shell rail), matching [TSideNavBar].
class TSideNavPanelCornerBracket extends StatelessWidget {
  const TSideNavPanelCornerBracket({
    super.key,
    this.top = false,
    this.bottom = false,
    this.left = false,
  });

  final bool top;
  final bool bottom;
  final bool left;

  @override
  Widget build(BuildContext context) {
    final color = TColors.primaryDark.withValues(alpha: 0.3);

    return Positioned(
      top: top ? 0 : null,
      bottom: bottom ? 0 : null,
      left: left ? 0 : null,
      child: SizedBox(
        width: 12,
        height: 12,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: top
                  ? BorderSide(
                      width: TSizes.borderWidth,
                      color: color,
                    )
                  : BorderSide.none,
              bottom: bottom
                  ? BorderSide(width: TSizes.borderWidth, color: color)
                  : BorderSide.none,
              left: left
                  ? BorderSide(
                      width: TSizes.borderWidth,
                      color: color,
                    )
                  : BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
