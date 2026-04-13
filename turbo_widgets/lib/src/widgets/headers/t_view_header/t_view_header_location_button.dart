import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/theme/t_font_families.dart';

class TViewHeaderLocationButton extends StatefulWidget {
  const TViewHeaderLocationButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isSmall = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isSmall;

  @override
  State<TViewHeaderLocationButton> createState() =>
      _TViewHeaderLocationButtonState();
}

class _TViewHeaderLocationButtonState extends State<TViewHeaderLocationButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isActive = false;

  static const _borderIdle = Color(0x1AFFFFFF);
  static const _borderHover = Color(0x8007B6D4);
  static const _borderActive = Color(0xB307B6D4);
  static const _textIdle = Color(0xFFA1A1AA);
  static const _textHover = Color(0xFF22D3EE);
  static const _bg = Color(0xFF18181B);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hPad = widget.isSmall ? 8.0 : 12.0;
    final fontSize = widget.isSmall ? 10.0 : 12.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _controller.forward(),
      onExit: (_) {
        _controller.reverse();
        if (_isActive) setState(() => _isActive = false);
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isActive = true),
        onTapUp: (_) {
          setState(() => _isActive = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isActive = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = _controller.value;
            final borderColor = _isActive
                ? _borderActive
                : Color.lerp(_borderIdle, _borderHover, t)!;
            final textColor = Color.lerp(_textIdle, _textHover, t)!;
            return DecoratedBox(
              decoration: BoxDecoration(
                color: _bg,
                border: Border.all(width: 1, color: borderColor),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 4),
                child: Text(
                  widget.label.toUpperCase(),
                  style: TextStyle(
                    fontFamily: TFontFamilies.jetBrainsMono,
                    fontWeight: FontWeight.w400,
                    fontSize: fontSize,
                    color: textColor,
                    letterSpacing: 0.8,
                    height: 1,
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
