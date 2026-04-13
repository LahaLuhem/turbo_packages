import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/constants/t_durations.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/theme/t_font_families.dart';
import 'package:turbo_widgets/src/widgets/buttons/hover_builder.dart';

// -- Segment entry (tracks active vs exiting state) --------------------------

class _SegmentEntry {
  _SegmentEntry({required this.id, required this.name});

  final String id;
  final String name;
  bool isExiting = false;
}

// -- TBreadcrumbs (stateful to manage exit animations) ------------------------

class TBreadcrumbs extends StatefulWidget {
  const TBreadcrumbs({
    super.key,
    required this.path,
    required this.onNavigate,
  });

  final List<({String id, String name})> path;
  final ValueChanged<int> onNavigate;

  @override
  State<TBreadcrumbs> createState() => _TBreadcrumbsState();
}

class _TBreadcrumbsState extends State<TBreadcrumbs> {
  late List<_SegmentEntry> _segments;

  @override
  void initState() {
    super.initState();
    _segments = widget.path
        .map((p) => _SegmentEntry(id: p.id, name: p.name))
        .toList();
  }

  @override
  void didUpdateWidget(covariant TBreadcrumbs oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newIds = widget.path.map((p) => p.id).toSet();
    final oldIds = _segments
        .where((s) => !s.isExiting)
        .map((s) => s.id)
        .toSet();

    final removedIds = oldIds.difference(newIds);
    final addedIds = newIds.difference(oldIds);

    if (removedIds.isEmpty && addedIds.isEmpty) return;

    for (final seg in _segments) {
      if (removedIds.contains(seg.id)) {
        seg.isExiting = true;
      }
    }

    for (final p in widget.path) {
      if (addedIds.contains(p.id)) {
        _segments.add(_SegmentEntry(id: p.id, name: p.name));
      }
    }

    setState(() {});
  }

  void _onSegmentExitComplete(String id) {
    setState(() {
      _segments.removeWhere((s) => s.id == id);
    });
  }

  int _activeIndexOf(String id) {
    for (var i = 0; i < widget.path.length; i++) {
      if (widget.path[i].id == id) return i;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.deviceType.isMobile;
    final fontSize = isMobile ? 10.0 : 12.0;
    final separatorColor = context.colors.border;
    final activePath = widget.path;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 24),
      child: ScrollConfiguration(
        behavior: const _NoScrollbarBehavior(),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _BreadcrumbBackButton(
                key: const ValueKey('back'),
                showArrow: activePath.isNotEmpty,
                onTap: activePath.isEmpty
                    ? () => widget.onNavigate(-1)
                    : () => widget.onNavigate(activePath.length - 2),
                isMobile: isMobile,
                fontSize: fontSize,
              ),
              _BreadcrumbRootButton(
                onTap: () => widget.onNavigate(-1),
                isMobile: isMobile,
                fontSize: fontSize,
              ),
              for (final seg in _segments)
                _BreadcrumbSegment(
                  key: ValueKey(seg.id),
                  name: seg.name,
                  isLast:
                      !seg.isExiting &&
                      _activeIndexOf(seg.id) == activePath.length - 1,
                  isExiting: seg.isExiting,
                  onTap: seg.isExiting
                      ? null
                      : () => widget.onNavigate(_activeIndexOf(seg.id)),
                  onExitComplete: () => _onSegmentExitComplete(seg.id),
                  isMobile: isMobile,
                  fontSize: fontSize,
                  separatorColor: separatorColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// -- Ghost button (shared hover + color transition) --------------------------

class _BreadcrumbGhostButton extends StatelessWidget {
  const _BreadcrumbGhostButton({
    required this.onTap,
    required this.idleColor,
    required this.hoverColor,
    required this.child,
    this.horizontalPadding = 6,
  });

  final VoidCallback onTap;
  final Color idleColor;
  final Color hoverColor;
  final double horizontalPadding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: HoverBuilder(
          builder: (context, isHovered, _) {
            final target = isHovered ? hoverColor : idleColor;
            return TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: target),
              duration: TDurations.hover,
              curve: Curves.ease,
              builder: (context, color, child) {
                return _GhostButtonContent(
                  color: color ?? idleColor,
                  horizontalPadding: horizontalPadding,
                  child: this.child,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _GhostButtonContent extends StatelessWidget {
  const _GhostButtonContent({
    required this.color,
    required this.horizontalPadding,
    required this.child,
  });

  final Color color;
  final double horizontalPadding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Center(
          child: IconTheme(
            data: IconThemeData(color: color),
            child: DefaultTextStyle(
              style: DefaultTextStyle.of(context).style.copyWith(color: color),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

// -- Back button -------------------------------------------------------------

class _BreadcrumbBackButton extends StatefulWidget {
  const _BreadcrumbBackButton({
    super.key,
    required this.showArrow,
    required this.onTap,
    required this.isMobile,
    required this.fontSize,
  });

  final bool showArrow;
  final VoidCallback onTap;
  final bool isMobile;
  final double fontSize;

  @override
  State<_BreadcrumbBackButton> createState() => _BreadcrumbBackButtonState();
}

class _BreadcrumbBackButtonState extends State<_BreadcrumbBackButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: TDurations.animationX0p5,
    );
    _slide = Tween<double>(begin: 8, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.ease),
    );
    if (widget.showArrow) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant _BreadcrumbBackButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.showArrow && widget.showArrow) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final idleColor = colors.colorScheme.mutedForeground;
    final hoverColor = colors.primary;
    final iconSize = widget.isMobile ? 10.0 : 12.0;
    final padding = widget.isMobile ? 6.0 : 8.0;

    final button = _BreadcrumbGhostButton(
      onTap: widget.onTap,
      idleColor: idleColor,
      hoverColor: hoverColor,
      horizontalPadding: padding,
      child: AnimatedSwitcher(
        duration: TDurations.animationX0p5,
        child: Icon(
          widget.showArrow ? Icons.arrow_back : Icons.terminal,
          key: ValueKey(widget.showArrow),
          size: iconSize,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slide.value, 0),
          child: child,
        );
      },
      child: button,
    );
  }
}

// -- Root button -------------------------------------------------------------

class _BreadcrumbRootButton extends StatelessWidget {
  const _BreadcrumbRootButton({
    required this.onTap,
    required this.isMobile,
    required this.fontSize,
  });

  final VoidCallback onTap;
  final bool isMobile;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final idleColor = colors.colorScheme.mutedForeground;
    final hoverColor = colors.primary;
    final padding = isMobile ? 6.0 : 8.0;

    return _BreadcrumbGhostButton(
      onTap: onTap,
      idleColor: idleColor,
      hoverColor: hoverColor,
      horizontalPadding: padding,
      child: Text(
        isMobile ? 'ROOT' : '~/ROOT',
        style: TextStyle(
          fontFamily: TFontFamilies.jetBrainsMono,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// -- Segment -----------------------------------------------------------------

class _BreadcrumbSegment extends StatefulWidget {
  const _BreadcrumbSegment({
    super.key,
    required this.name,
    required this.isLast,
    required this.isExiting,
    required this.onTap,
    required this.onExitComplete,
    required this.isMobile,
    required this.fontSize,
    required this.separatorColor,
  });

  final String name;
  final bool isLast;
  final bool isExiting;
  final VoidCallback? onTap;
  final VoidCallback onExitComplete;
  final bool isMobile;
  final double fontSize;
  final Color separatorColor;

  @override
  State<_BreadcrumbSegment> createState() => _BreadcrumbSegmentState();
}

class _BreadcrumbSegmentState extends State<_BreadcrumbSegment>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slide;
  late final Animation<double> _fade;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: TDurations.animationX0p5,
    );
    _slide = Tween<double>(begin: -8, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.ease),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.ease),
    );
    _controller.addStatusListener(_onAnimationStatus);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _BreadcrumbSegment oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isExiting && widget.isExiting) {
      _isExiting = true;
      _controller.reverse();
    }
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      widget.onExitComplete();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final primary = colors.primary;
    final idleColor = widget.isLast
        ? primary
        : colors.colorScheme.mutedForeground;
    final hoverColor = widget.isLast ? primary : colors.primaryText;
    final padding = widget.isMobile ? 6.0 : 8.0;
    final separatorMargin = widget.isMobile ? 2.0 : 4.0;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: separatorMargin),
          child: Text(
            '/',
            style: TextStyle(
              fontFamily: TFontFamilies.jetBrainsMono,
              fontSize: widget.fontSize,
              color: widget.separatorColor,
            ),
          ),
        ),
        _BreadcrumbGhostButton(
          onTap: widget.onTap ?? () {},
          idleColor: idleColor,
          hoverColor: hoverColor,
          horizontalPadding: padding,
          child: _BreadcrumbSegmentLabel(
            name: widget.name,
            fontSize: widget.fontSize,
            isMobile: widget.isMobile,
          ),
        ),
      ],
    );

    if (_isExiting) {
      content = IgnorePointer(child: content);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slide.value, 0),
          child: _isExiting
              ? Opacity(opacity: _fade.value, child: child)
              : child,
        );
      },
      child: content,
    );
  }
}

class _BreadcrumbSegmentLabel extends StatelessWidget {
  const _BreadcrumbSegmentLabel({
    required this.name,
    required this.fontSize,
    required this.isMobile,
  });

  final String name;
  final double fontSize;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    Widget text = Text(
      name.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: TFontFamilies.jetBrainsMono,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
      ),
    );

    if (isMobile) {
      text = ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 80),
        child: text,
      );
    }

    return text;
  }
}

// -- Scrollbar behavior ------------------------------------------------------

class _NoScrollbarBehavior extends ScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}
