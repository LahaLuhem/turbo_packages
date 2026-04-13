import 'package:flutter/material.dart';

class HoverIconButton extends StatefulWidget {
  const HoverIconButton({
    super.key,
    required this.onTap,
    this.icon = Icons.edit_outlined,
    this.iconSize = 12,
    this.size = 32,
    this.borderColorIdle = const Color(0x1AFFFFFF),
    this.borderColorHover = const Color(0x4DFFFFFF),
    this.iconColorIdle = const Color(0xFF52525B),
    this.iconColorHover = const Color(0xFFFFFFFF),
    this.backgroundColorIdle = Colors.transparent,
    this.backgroundColorHover = Colors.transparent,
    this.duration = const Duration(milliseconds: 150),
  });

  final VoidCallback onTap;
  final IconData icon;
  final double iconSize;
  final double size;
  final Color borderColorIdle;
  final Color borderColorHover;
  final Color iconColorIdle;
  final Color iconColorHover;
  final Color backgroundColorIdle;
  final Color backgroundColorHover;
  final Duration duration;

  @override
  State<HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<HoverIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final borderColor = Color.lerp(
              widget.borderColorIdle,
              widget.borderColorHover,
              t,
            )!;
            final iconColor = Color.lerp(
              widget.iconColorIdle,
              widget.iconColorHover,
              t,
            )!;
            final bgColor = Color.lerp(
              widget.backgroundColorIdle,
              widget.backgroundColorHover,
              t,
            )!;

            return SizedBox(
              width: widget.size,
              height: widget.size,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(width: 1, color: borderColor),
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    size: widget.iconSize,
                    color: iconColor,
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
