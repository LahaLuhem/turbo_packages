import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/constants/t_durations.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/theme/t_colors.dart';
import 'package:turbo_widgets/src/theme/t_font_families.dart';
import 'package:turbo_widgets/src/theme/t_sizes.dart';
import 'package:turbo_widgets/src/widgets/buttons/hover_icon_button.dart';
import 'package:turbo_widgets/src/widgets/misc/cursor_preview.dart';
import 'package:turbo_widgets/src/widgets/misc/t_emoji_picker_popover.dart';

class TEntityCard extends StatefulWidget {
  const TEntityCard({
    super.key,
    this.emoji,
    this.title = '',
    this.subtitle = '',
    this.typeLabel = '',
    this.propertiesCount = 0,
    this.iconData,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onEmojiChanged,
    this.showPreview = false,
    this.previewBuilder,
    this.previewContent,
  });

  final String? emoji;
  final String title;
  final String subtitle;
  final String typeLabel;
  final int propertiesCount;
  final IconData? iconData;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<String>? onEmojiChanged;
  final bool showPreview;
  final WidgetBuilder? previewBuilder;
  final String? previewContent;

  @override
  State<TEntityCard> createState() => _TEntityCardState();
}

class _TEntityCardState extends State<TEntityCard>
    with TickerProviderStateMixin {
  late final AnimationController _spotlightController;
  late final CurvedAnimation _spotlightOpacity;
  final ValueNotifier<Offset> _mousePosition = ValueNotifier(Offset.zero);
  bool _isHovered = false;
  bool _isPressed = false;

  AnimationController? _previewOpacityController;
  OverlayPortalController? _overlayController;
  ValueNotifier<Offset>? _globalMousePosition;

  bool get _hasPreview => widget.previewBuilder != null || widget.showPreview;

  @override
  void initState() {
    super.initState();
    _spotlightController = AnimationController(
      duration: TDurations.animationX2,
      reverseDuration: TDurations.animation,
      vsync: this,
    );
    _spotlightOpacity = CurvedAnimation(
      parent: _spotlightController,
      curve: Curves.ease,
    );
    if (_hasPreview) {
      _initPreview();
    }
  }

  @override
  void didUpdateWidget(TEntityCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hadPreview =
        oldWidget.previewBuilder != null || oldWidget.showPreview;
    if (!hadPreview && _hasPreview) {
      _initPreview();
    } else if (hadPreview && !_hasPreview) {
      _disposePreview();
    }
  }

  void _initPreview() {
    _previewOpacityController = AnimationController(
      duration: TDurations.animation,
      vsync: this,
    );
    _overlayController = OverlayPortalController();
    _globalMousePosition = ValueNotifier(Offset.zero);
  }

  void _disposePreview() {
    _previewOpacityController?.dispose();
    _previewOpacityController = null;
    _globalMousePosition?.dispose();
    _globalMousePosition = null;
    _overlayController = null;
  }

  @override
  void dispose() {
    _spotlightOpacity.dispose();
    _spotlightController.dispose();
    _mousePosition.dispose();
    _disposePreview();
    super.dispose();
  }

  void _onEnter(PointerEvent event) {
    _mousePosition.value = event.localPosition;
    setState(() => _isHovered = true);
    _spotlightController.forward();
    if (_hasPreview) {
      _globalMousePosition!.value = event.position;
      _overlayController!.show();
      _previewOpacityController!.forward();
    }
  }

  void _onHover(PointerEvent event) {
    _mousePosition.value = event.localPosition;
    if (_hasPreview) {
      _globalMousePosition!.value = event.position;
    }
  }

  void _onExit(PointerEvent _) {
    setState(() {
      _isHovered = false;
      _isPressed = false;
    });
    _spotlightController.reverse();
    if (_hasPreview) {
      _previewOpacityController!.reverse().then((_) {
        if (!_isHovered && mounted) {
          _overlayController?.hide();
        }
      });
    }
  }

  void _onTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    Widget card = _SpotlightCardShell(
      mousePosition: _mousePosition,
      spotlightOpacity: _spotlightOpacity,
      isHovered: _isHovered,
      isPressed: _isPressed,
      onTap: widget.onTap,
      onEnter: _onEnter,
      onHover: _onHover,
      onExit: _onExit,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      footer: _TEntityCardPropertiesFooter(
        propertiesCount: widget.propertiesCount,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TEntityCardHeader(
            emoji: widget.emoji,
            iconData: widget.iconData,
            isHovered: _isHovered,
            onEmojiChanged: widget.onEmojiChanged,
            onEdit: widget.onEdit,
            onDelete: widget.onDelete,
          ),
          const SizedBox(height: 20),
          _TEntityCardTypeLabel(typeLabel: widget.typeLabel),
          _TEntityCardTitle(
            title: widget.title,
            isHovered: _isHovered,
          ),
          const SizedBox(height: 8),
          _TEntityCardSubtitle(
            subtitle: widget.subtitle,
            isHovered: _isHovered,
          ),
        ],
      ),
    );

    if (_hasPreview) {
      card = OverlayPortal(
        controller: _overlayController!,
        overlayChildBuilder: (context) => _EntityCardPreviewOverlay(
          globalMousePosition: _globalMousePosition!,
          previewOpacity: _previewOpacityController!,
          previewBuilder: widget.previewBuilder,
          typeLabel: widget.typeLabel,
          emoji: widget.emoji,
          title: widget.title,
          previewContent: widget.previewContent,
        ),
        child: card,
      );
    }

    return card;
  }
}

// ---------------------------------------------------------------------------
// Preview overlay
// ---------------------------------------------------------------------------

class _EntityCardPreviewOverlay extends StatelessWidget {
  const _EntityCardPreviewOverlay({
    required this.globalMousePosition,
    required this.previewOpacity,
    this.previewBuilder,
    required this.typeLabel,
    this.emoji,
    required this.title,
    this.previewContent,
  });

  final ValueNotifier<Offset> globalMousePosition;
  final Animation<double> previewOpacity;
  final WidgetBuilder? previewBuilder;
  final String typeLabel;
  final String? emoji;
  final String title;
  final String? previewContent;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Offset>(
      valueListenable: globalMousePosition,
      builder: (context, position, child) {
        return Positioned(
          left: position.dx + 20,
          top: position.dy + 20,
          child: child!,
        );
      },
      child: IgnorePointer(
        child: FadeTransition(
          opacity: previewOpacity,
          child: previewBuilder != null
              ? previewBuilder!(context)
              : CursorPreview(
                  labelId: typeLabel,
                  emoji: emoji,
                  name: title,
                  content: previewContent,
                ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Spotlight card shell (reusable card with grid, spotlight, corner brackets)
// ---------------------------------------------------------------------------

class _SpotlightCardShell extends StatelessWidget {
  const _SpotlightCardShell({
    required this.mousePosition,
    required this.spotlightOpacity,
    required this.isHovered,
    required this.isPressed,
    this.onTap,
    required this.onEnter,
    required this.onHover,
    required this.onExit,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTapCancel,
    required this.child,
    this.footer,
  });

  final ValueNotifier<Offset> mousePosition;
  final Animation<double> spotlightOpacity;
  final bool isHovered;
  final bool isPressed;
  final VoidCallback? onTap;
  final void Function(PointerEvent) onEnter;
  final void Function(PointerEvent) onHover;
  final void Function(PointerEvent) onExit;
  final void Function(TapDownDetails) onTapDown;
  final void Function(TapUpDetails) onTapUp;
  final VoidCallback onTapCancel;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final cardColor = context.colors.card;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: onEnter,
      onHover: onHover,
      onExit: onExit,
      child: GestureDetector(
        onTap: onTap,
        onTapDown: onTapDown,
        onTapUp: onTapUp,
        onTapCancel: onTapCancel,
        child: AnimatedBuilder(
          animation: spotlightOpacity,
          builder: (context, content) {
            final t = spotlightOpacity.value;
            final borderAlpha = isPressed ? 0.3 : ui.lerpDouble(0.1, 0.2, t)!;

            return ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 256),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: cardColor,
                  border: Border.all(
                    width: TSizes.borderWidth,
                    color: Colors.white.withValues(alpha: borderAlpha),
                  ),
                  boxShadow: t > 0
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF065F71,
                            ).withValues(alpha: 0.1 * t),
                            blurRadius: 25,
                          ),
                        ]
                      : null,
                ),
                child: ClipRect(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _GridPatternPainter(),
                        ),
                      ),
                      Positioned.fill(
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: _SpotlightPainter(
                              mousePosition: mousePosition,
                              opacity: spotlightOpacity,
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: RepaintBoundary(
                            child: CustomPaint(
                              painter: _CornerGlowPainter(
                                alpha: ui.lerpDouble(0.05, 0.10, t)!,
                              ),
                            ),
                          ),
                        ),
                      ),
                      _CornerBracket(t: t, top: true, left: true),
                      _CornerBracket(t: t, bottom: true, right: true),
                      if (footer != null)
                        Positioned(
                          left: TSizes.cardPadding,
                          right: TSizes.cardPadding,
                          bottom: TSizes.cardPadding,
                          child: footer!,
                        ),
                      if (content != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            TSizes.cardPadding,
                            TSizes.cardPadding,
                            TSizes.cardPadding,
                            TSizes.cardPadding + TSizes.appPadding,
                          ),
                          child: content,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
          child: child,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _TEntityCardHeader extends StatelessWidget {
  const _TEntityCardHeader({
    required this.emoji,
    required this.iconData,
    required this.isHovered,
    required this.onEmojiChanged,
    required this.onEdit,
    required this.onDelete,
  });

  final String? emoji;
  final IconData? iconData;
  final bool isHovered;
  final ValueChanged<String>? onEmojiChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TEntityCardIconContainer(
          emoji: emoji,
          iconData: iconData,
          isHovered: isHovered,
          onEmojiChanged: onEmojiChanged,
        ),
        _TEntityCardActions(
          isHovered: isHovered,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Icon Container
// ---------------------------------------------------------------------------

class _TEntityCardIconContainer extends StatefulWidget {
  const _TEntityCardIconContainer({
    required this.emoji,
    required this.iconData,
    required this.isHovered,
    required this.onEmojiChanged,
  });

  final String? emoji;
  final IconData? iconData;
  final bool isHovered;
  final ValueChanged<String>? onEmojiChanged;

  @override
  State<_TEntityCardIconContainer> createState() =>
      _TEntityCardIconContainerState();
}

class _TEntityCardIconContainerState extends State<_TEntityCardIconContainer>
    with TickerProviderStateMixin {
  late final AnimationController _hoverController;
  late final CurvedAnimation _hoverCurved;
  late final AnimationController _pressController;
  late final CurvedAnimation _pressCurved;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: TDurations.sheetAnimation,
      vsync: this,
      value: widget.isHovered ? 1.0 : 0.0,
    );
    _hoverCurved = CurvedAnimation(
      parent: _hoverController,
      curve: Curves.ease,
    );
    _pressController = AnimationController(
      duration: TDurations.sheetAnimation,
      vsync: this,
    );
    _pressCurved = CurvedAnimation(
      parent: _pressController,
      curve: Curves.ease,
    );
  }

  @override
  void didUpdateWidget(_TEntityCardIconContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHovered != oldWidget.isHovered) {
      widget.isHovered
          ? _hoverController.forward()
          : _hoverController.reverse();
    }
  }

  @override
  void dispose() {
    _hoverCurved.dispose();
    _hoverController.dispose();
    _pressCurved.dispose();
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasEmoji = widget.emoji != null && widget.emoji!.isNotEmpty;

    Widget iconBox = AnimatedBuilder(
      animation: Listenable.merge([_hoverCurved, _pressCurved]),
      builder: (context, _) {
        final hT = _hoverCurved.value;
        final pT = _pressCurved.value;
        final scale = ui.lerpDouble(1.0, 0.95, pT)!;
        final borderColor = Color.lerp(
          Colors.white.withValues(alpha: 0.1),
          TColors.primaryDark.withValues(alpha: 0.3),
          hT,
        )!;

        return Transform.scale(
          scale: scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0x8018181B),
              border: Border.all(
                width: TSizes.borderWidth,
                color: borderColor,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: hasEmoji
                    ? Text(
                        widget.emoji!,
                        style: const TextStyle(fontSize: 24),
                      )
                    : Icon(
                        widget.iconData ?? Icons.folder_outlined,
                        size: 18,
                        color: Color.lerp(
                          const Color(0xFFA1A1AA),
                          const Color(0xFF67E8F9),
                          hT,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );

    if (widget.onEmojiChanged != null) {
      iconBox = TEmojiPickerPopover(
        selectedEmoji: widget.emoji,
        onEmojiSelected: widget.onEmojiChanged!,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Listener(
            onPointerDown: (_) => _pressController.forward(),
            onPointerUp: (_) => _pressController.reverse(),
            onPointerCancel: (_) => _pressController.reverse(),
            child: iconBox,
          ),
        ),
      );
    }

    return iconBox;
  }
}

// ---------------------------------------------------------------------------
// Action Buttons
// ---------------------------------------------------------------------------

class _TEntityCardActions extends StatefulWidget {
  const _TEntityCardActions({
    required this.isHovered,
    required this.onEdit,
    required this.onDelete,
  });

  final bool isHovered;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  State<_TEntityCardActions> createState() => _TEntityCardActionsState();
}

class _TEntityCardActionsState extends State<_TEntityCardActions>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curved;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TDurations.sheetAnimation,
      vsync: this,
      value: widget.isHovered ? 1.0 : 0.0,
    );
    _curved = CurvedAnimation(parent: _controller, curve: Curves.ease);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.25, 0),
      end: Offset.zero,
    ).animate(_curved);
  }

  @override
  void didUpdateWidget(_TEntityCardActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHovered != oldWidget.isHovered) {
      widget.isHovered ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasActions = widget.onEdit != null || widget.onDelete != null;
    if (!hasActions) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _curved,
      child: SlideTransition(
        position: _slideAnimation,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.onEdit != null)
              _ActionButton(
                icon: Icons.edit_outlined,
                onTap: widget.onEdit!,
                hoverColor: TColors.primaryDark.withValues(alpha: 0.8),
                hoverBackground: const Color(0x1A083344),
              ),
            if (widget.onEdit != null && widget.onDelete != null)
              const SizedBox(width: 4),
            if (widget.onDelete != null)
              _ActionButton(
                icon: Icons.delete_outline,
                onTap: widget.onDelete!,
                hoverColor: const Color(0xFFF87171),
                hoverBackground: const Color(0x1A450A0A),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.hoverColor,
    required this.hoverBackground,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color hoverColor;
  final Color hoverBackground;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _curved;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TDurations.sheetAnimationX0p5,
      vsync: this,
    );
    _curved = CurvedAnimation(parent: _controller, curve: Curves.ease);
  }

  @override
  void dispose() {
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _curved,
          builder: (context, _) {
            final t = _curved.value;
            return SizedBox(
              width: 32,
              height: 32,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color.lerp(
                    Colors.transparent,
                    widget.hoverBackground,
                    t,
                  ),
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    size: 16,
                    color: Color.lerp(
                      const Color(0xFF71717A),
                      widget.hoverColor,
                      t,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Type Label
// ---------------------------------------------------------------------------

class _TEntityCardTypeLabel extends StatelessWidget {
  const _TEntityCardTypeLabel({required this.typeLabel});

  final String typeLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            height: 1,
            width: 32,
            color: TColors.primaryDark.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 12),
          Text(
            typeLabel.toUpperCase(),
            style: const TextStyle(
              fontFamily: TFontFamilies.jetBrainsMono,
              fontWeight: FontWeight.w700,
              fontSize: 9,
              color: TColors.primaryDark,
              letterSpacing: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Title
// ---------------------------------------------------------------------------

class _TEntityCardTitle extends StatelessWidget {
  const _TEntityCardTitle({
    required this.title,
    required this.isHovered,
  });

  final String title;
  final bool isHovered;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedDefaultTextStyle(
        duration: TDurations.sheetAnimation,
        style: TextStyle(
          fontFamily: TFontFamilies.manrope,
          fontWeight: FontWeight.w500,
          fontSize: 20,
          letterSpacing: -0.5,
          height: 1.375,
          color: isHovered ? const Color(0xFFF0F9FA) : Colors.white,
        ),
        child: Text(title, softWrap: true),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Subtitle
// ---------------------------------------------------------------------------

class _TEntityCardSubtitle extends StatelessWidget {
  const _TEntityCardSubtitle({
    required this.subtitle,
    required this.isHovered,
  });

  final String subtitle;
  final bool isHovered;

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: TDurations.sheetAnimation,
      style: TextStyle(
        fontFamily: TFontFamilies.jetBrainsMono,
        fontSize: 12,
        height: 1.625,
        color: isHovered ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
      ),
      child: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Properties Footer
// ---------------------------------------------------------------------------

class _TEntityCardPropertiesFooter extends StatelessWidget {
  const _TEntityCardPropertiesFooter({required this.propertiesCount});

  final int propertiesCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 24),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            width: TSizes.borderWidth,
            color: Color(0x0DFFFFFF),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PROPERTIES',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF52525B),
                  letterSpacing: 0.45,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$propertiesCount defined',
                style: const TextStyle(
                  fontFamily: TFontFamilies.jetBrainsMono,
                  fontSize: 12,
                  color: Color(0xFFA1A1AA),
                ),
              ),
            ],
          ),
          HoverIconButton(
            onTap: () {},
            iconSize: 12,
            borderColorIdle: Colors.white.withValues(alpha: 0.1),
            borderColorHover: Colors.white.withValues(alpha: 0.3),
            iconColorIdle: const Color(0xFF52525B),
            iconColorHover: Colors.white,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Corner Bracket
// ---------------------------------------------------------------------------

class _CornerBracket extends StatelessWidget {
  const _CornerBracket({
    required this.t,
    this.top = false,
    this.bottom = false,
    this.left = false,
    this.right = false,
  });

  final double t;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

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
      right: right ? 0 : null,
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
              right: right
                  ? BorderSide(width: TSizes.borderWidth, color: color)
                  : BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Corner Glow Painter
// ---------------------------------------------------------------------------

class _CornerGlowPainter extends CustomPainter {
  _CornerGlowPainter({required this.alpha});

  final double alpha;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width, 0),
        250,
        [
          TColors.primaryDark.withValues(alpha: alpha),
          Colors.transparent,
        ],
        [0.0, 1.0],
      );

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_CornerGlowPainter oldDelegate) =>
      oldDelegate.alpha != alpha;
}

// ---------------------------------------------------------------------------
// Spotlight Painter
// ---------------------------------------------------------------------------

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({
    required this.mousePosition,
    required this.opacity,
  }) : super(repaint: Listenable.merge([mousePosition, opacity]));

  final ValueNotifier<Offset> mousePosition;
  final Animation<double> opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity.value <= 0) return;

    final center = mousePosition.value;
    const radius = 600.0;
    final alpha = (0.04 * opacity.value * 255).round().clamp(0, 255);

    final paint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        [
          Color.fromARGB(alpha, 255, 255, 255),
          Colors.transparent,
        ],
        [0.0, 0.4],
      );

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Grid Pattern Painter
// ---------------------------------------------------------------------------

class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x04808080)
      ..strokeWidth = 1;

    const step = 24.0;

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPatternPainter oldDelegate) => false;
}
