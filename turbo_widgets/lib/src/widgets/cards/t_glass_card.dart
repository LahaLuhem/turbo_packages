import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/constants/t_durations.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/theme/t_font_families.dart';
import 'package:turbo_widgets/src/theme/t_sizes.dart';

class TGlassCard extends StatefulWidget {
  const TGlassCard({
    super.key,
    this.code,
    required this.title,
    this.description,
    this.isActive = false,
    this.onHoverChanged,
    this.onTap,
  });

  final String? code;
  final String title;
  final String? description;
  final bool isActive;
  final ValueChanged<bool>? onHoverChanged;
  final VoidCallback? onTap;

  @override
  State<TGlassCard> createState() => _TGlassCardState();
}

class _TGlassCardState extends State<TGlassCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hoverController;

  static const _white5 = Color(0x0DFFFFFF);
  static const _white1 = Color(0x03FFFFFF);
  static const _white3 = Color(0x08FFFFFF);
  static const _cyanDark30 = Color(0x4D07B6D4);
  static const _cyan5 = Color(0x0D06B6D4);
  static const _cyan50percent = Color(0x8006B6D4);
  static const _cyan50Color = Color(0xFFECFEFF);
  static const _zinc400 = Color(0xFFA1A1AA);
  static const _zinc500 = Color(0xFF71717A);

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: TDurations.animationX2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool hovering) {
    if (hovering) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
    widget.onHoverChanged?.call(hovering);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            final p = _hoverController.value;
            final borderColor = Color.lerp(_white5, _cyanDark30, p)!;
            final bgColor = Color.lerp(_white1, _white3, p)!;
            final titleColor = Color.lerp(colors.heading, _cyan50Color, p)!;
            final descColor = Color.lerp(_zinc500, _zinc400, p)!;
            final cornerColor = Color.lerp(_white5, _cyanDark30, p)!;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Main card body
                Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(TSizes.cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _CardHeader(
                          code: widget.code,
                          isActive: widget.isActive,
                          hoverProgress: p,
                        ),
                        const SizedBox(height: TSizes.elementGap),
                        Text(
                          widget.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: TFontFamilies.manrope,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
                        ),
                        if (widget.description != null) ...[
                          const SizedBox(height: TSizes.textGap),
                          Text(
                            widget.description!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: TFontFamilies.jetBrainsMono,
                              fontSize: 12,
                              height: 1.625,
                              color: descColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Hover glow gradient overlay
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: p,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_cyan5, Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Top accent line
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 1,
                  child: Transform.scale(
                    scaleX: p,
                    alignment: Alignment.center,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            _cyan50percent,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Corner accent (bottom-right)
                Positioned(
                  bottom: 0,
                  right: 0,
                  width: 32,
                  height: 32,
                  child: CustomPaint(
                    painter: _CornerAccentPainter(color: cornerColor),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// -- Card Header --------------------------------------------------------------

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    this.code,
    required this.isActive,
    required this.hoverProgress,
  });

  final String? code;
  final bool isActive;
  final double hoverProgress;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (code != null)
          _CodeBadge(code: code!, hoverProgress: hoverProgress)
        else
          const SizedBox.shrink(),
        _StatusDot(isActive: isActive),
      ],
    );
  }
}

// -- Code Badge ---------------------------------------------------------------

class _CodeBadge extends StatelessWidget {
  const _CodeBadge({
    required this.code,
    required this.hoverProgress,
  });

  final String code;
  final double hoverProgress;

  static const _cyanDark = Color(0xFF07B6D4);
  static const _cyanDark30 = Color(0x4D07B6D4);

  @override
  Widget build(BuildContext context) {
    final bgColor = Color.lerp(Colors.transparent, _cyanDark, hoverProgress)!;
    final textColor = Color.lerp(_cyanDark, Colors.black, hoverProgress)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: _cyanDark30, width: 1),
      ),
      child: Text(
        code,
        style: TextStyle(
          fontFamily: TFontFamilies.jetBrainsMono,
          fontSize: 10,
          letterSpacing: 2.0,
          fontWeight: FontWeight.w400,
          color: textColor,
        ),
      ),
    );
  }
}

// -- Status Dot ---------------------------------------------------------------

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.isActive});

  final bool isActive;

  static const _cyanDark = Color(0xFF07B6D4);
  static const _cyanGlow = Color(0xFF22D3EE);
  static const _zinc700 = Color(0xFF3F3F46);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? _cyanDark : _zinc700,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: _cyanGlow.withValues(alpha: 0.5),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
    );
  }
}

// -- Corner Accent Painter ----------------------------------------------------

class _CornerAccentPainter extends CustomPainter {
  _CornerAccentPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Right edge (bottom to top)
    canvas.drawLine(
      Offset(size.width - 0.5, size.height),
      Offset(size.width - 0.5, 0),
      paint,
    );

    // Bottom edge (right to left)
    canvas.drawLine(
      Offset(size.width, size.height - 0.5),
      Offset(0, size.height - 0.5),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CornerAccentPainter oldDelegate) =>
      oldDelegate.color != color;
}
