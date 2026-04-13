import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/constants/t_durations.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/theme/t_colors.dart';
import 'package:turbo_widgets/src/theme/t_font_families.dart';
import 'package:turbo_widgets/src/theme/t_sizes.dart';
import 'package:turbo_widgets/src/widgets/decorative/t_beam_divider.dart';
import 'package:turbo_widgets/src/widgets/misc/t_side_nav_panel_corner_bracket.dart';

class TSideNavBar extends StatelessWidget {
  const TSideNavBar({
    super.key,
    required this.children,
    this.headerTitle = 'Pew Pew Plaza',
    this.width = 240,
  });

  final List<Widget> children;
  final String headerTitle;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.card,
          border: Border(
            right: BorderSide(
              color: colors.border,
              width: TSizes.borderWidth,
            ),
          ),
        ),
        child: ClipRect(
          child: Stack(
            children: [
              Positioned(
                top: -40,
                right: -40,
                child: IgnorePointer(
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: ColoredBox(
                        color: TColors.primaryDark.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SideNavHeader(title: headerTitle),
                  const TBeamDivider(),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children,
                      ),
                    ),
                  ),
                ],
              ),
              const TSideNavPanelCornerBracket(top: true, left: true),
              const TSideNavPanelCornerBracket(bottom: true, left: true),
            ],
          ),
        ),
      ),
    );
  }
}

class TSideNavGroup extends StatefulWidget {
  const TSideNavGroup({
    super.key,
    required this.label,
    required this.children,
    this.initiallyExpanded = true,
  });

  final String label;
  final List<Widget> children;
  final bool initiallyExpanded;

  @override
  State<TSideNavGroup> createState() => _TSideNavGroupState();
}

class _TSideNavGroupState extends State<TSideNavGroup> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      _TSideNavGroupHeader(
        label: widget.label,
        isExpanded: _isExpanded,
        onTap: _toggleExpanded,
      ),
      if (_isExpanded) ...[
        const SizedBox(height: 4),
        ...widget.children,
      ],
    ],
  );
}

class _TSideNavGroupHeader extends StatefulWidget {
  const _TSideNavGroupHeader({
    required this.label,
    required this.isExpanded,
    required this.onTap,
  });

  final String label;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  State<_TSideNavGroupHeader> createState() => _TSideNavGroupHeaderState();
}

class _TSideNavGroupHeaderState extends State<_TSideNavGroupHeader>
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
      _hoverController.value = 1;
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
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: 28,
            child: AnimatedBuilder(
              animation: _hoverController,
              builder: (context, _) {
                final hoverT = _hoverController.value;
                final color = Color.lerp(
                  scheme.mutedForeground,
                  colors.primaryText,
                  hoverT,
                )!;

                return Row(
                  children: [
                    Transform.rotate(
                      angle: widget.isExpanded ? 1.5707963 : 0.0,
                      child: Icon(
                        Icons.chevron_right,
                        size: 14,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          fontFamily: TFontFamilies.jetBrainsMono,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          letterSpacing: 0.8,
                          color: color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SideNavHeader extends StatelessWidget {
  const _SideNavHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TSizes.appPadding,
        24,
        TSizes.appPadding,
        16,
      ),
      child: Row(
        spacing: 8,
        children: [
          Icon(
            Icons.grid_view_rounded,
            size: 20,
            color: colors.primary,
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: TFontFamilies.jetBrainsMono,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 1.5,
                color: colors.colorScheme.foreground,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class TSideNavItem extends StatefulWidget {
  const TSideNavItem({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  State<TSideNavItem> createState() => _TSideNavItemState();
}

class _TSideNavItemState extends State<TSideNavItem>
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
  void didUpdateWidget(TSideNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      _hoverController.reset();
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHoverChanged(bool hovering) {
    if (widget.isActive) return;
    if (hovering) {
      _hoverController.value = 1;
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scheme = colors.colorScheme;

    return MouseRegion(
      cursor: widget.isActive
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => _onHoverChanged(true),
      onExit: (_) => _onHoverChanged(false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            final t = _hoverController.value;

            final Color bgColor;
            final Color iconColor;
            final Color textColor;

            if (widget.isActive) {
              bgColor = scheme.accent;
              iconColor = colors.primary;
              textColor = scheme.foreground;
            } else {
              bgColor = Color.lerp(
                Colors.transparent,
                colors.secondary,
                t,
              )!;
              iconColor = Color.lerp(
                scheme.mutedForeground,
                colors.primaryText,
                t,
              )!;
              textColor = Color.lerp(
                scheme.mutedForeground,
                colors.primaryText,
                t,
              )!;
            }

            final effectiveT = widget.isActive ? 1.0 : t;
            final borderColor = Color.lerp(
              Colors.white.withValues(alpha: 0.1),
              TColors.primaryDark.withValues(alpha: 0.4),
              effectiveT,
            )!;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: bgColor,
                    border: Border.all(
                      width: TSizes.borderWidth,
                      color: borderColor,
                    ),
                  ),
                  child: SizedBox(
                    height: TSizes.minButtonHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        spacing: TSizes.itemGap,
                        children: [
                          Icon(
                            widget.icon,
                            size: 20,
                            color: iconColor,
                          ),
                          Expanded(
                            child: Text(
                              widget.label,
                              style: TextStyle(
                                fontFamily: TFontFamilies.jetBrainsMono,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                letterSpacing: 0.5,
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
                _SideNavItemCornerBracket(
                  t: effectiveT,
                  top: true,
                  left: true,
                ),
                _SideNavItemCornerBracket(
                  t: effectiveT,
                  bottom: true,
                  left: true,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SideNavItemCornerBracket extends StatelessWidget {
  const _SideNavItemCornerBracket({
    required this.t,
    this.top = false,
    this.bottom = false,
    this.left = false,
  });

  final double t;
  final bool top;
  final bool bottom;
  final bool left;

  @override
  Widget build(BuildContext context) {
    final color = Color.lerp(
      Colors.white.withValues(alpha: 0.05),
      TColors.primaryDark.withValues(alpha: 0.5),
      t,
    )!;

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
                  ? BorderSide(width: TSizes.borderWidth, color: color)
                  : BorderSide.none,
              bottom: bottom
                  ? BorderSide(width: TSizes.borderWidth, color: color)
                  : BorderSide.none,
              left: left
                  ? BorderSide(width: TSizes.borderWidth, color: color)
                  : BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}

