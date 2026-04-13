import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/constants/t_durations.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/theme/t_sizes.dart';

class TCtaBarActionCard extends StatefulWidget {
  const TCtaBarActionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.minTouchTarget,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final double minTouchTarget;
  final VoidCallback onPressed;

  @override
  State<TCtaBarActionCard> createState() => _TCtaBarActionCardState();
}

class _TCtaBarActionCardState extends State<TCtaBarActionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: TDurations.hover,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHoverChanged(bool hovering) {
    if (hovering) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = colors.colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _onHoverChanged(true),
      onExit: (_) => _onHoverChanged(false),
      child: Semantics(
        button: true,
        label: widget.label,
        child: ExcludeSemantics(
          child: AnimatedBuilder(
            animation: _hoverController,
            builder: (context, child) {
              final t = _hoverController.value;
              final bgColor = Color.lerp(
                colors.card,
                colors.secondary,
                t,
              )!;
              final iconColor = Color.lerp(
                scheme.mutedForeground,
                colors.primaryText,
                t,
              )!;
              final textColor = Color.lerp(
                scheme.mutedForeground,
                colors.primaryText,
                t,
              )!;
              final borderColor = Color.lerp(
                colors.border,
                colors.primary.withValues(alpha: 0.4),
                t,
              )!;

              return ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: widget.minTouchTarget,
                  minHeight: widget.minTouchTarget,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onPressed,
                    splashColor: colors.primary.withValues(alpha: 0.12),
                    highlightColor: colors.primary.withValues(alpha: 0.08),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: bgColor,
                        border: Border.all(
                          width: TSizes.borderWidth,
                          color: borderColor,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: TSizes.elementGap,
                          vertical: TSizes.textGap,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: TSizes.iconGap,
                            children: [
                              Icon(
                                widget.icon,
                                size: TSizes.iconSize,
                                color: iconColor,
                              ),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: math.min(
                                    TSizes.ctaBarLabelMaxWidth,
                                    MediaQuery.sizeOf(context).width * 0.5,
                                  ),
                                ),
                                child: Text(
                                  widget.label,
                                  style: context.texts.h4.copyWith(
                                    color: textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
