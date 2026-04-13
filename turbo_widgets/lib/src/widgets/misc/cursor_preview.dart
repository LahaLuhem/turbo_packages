import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/extensions/t_context_extension.dart';
import 'package:turbo_widgets/src/theme/t_colors.dart';
import 'package:turbo_widgets/src/theme/t_font_families.dart';

class CursorPreview extends StatelessWidget {
  const CursorPreview({
    super.key,
    this.labelId = '',
    this.emoji,
    this.name = '',
    this.content,
  });

  final String labelId;
  final String? emoji;
  final String name;
  final String? content;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: 256,
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.overlay,
              border: Border.fromBorderSide(
                BorderSide(
                  width: 1,
                  color: colors.overlayBorder,
                ),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 50,
                  offset: Offset(0, 25),
                  spreadRadius: -12,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CursorPreviewHeader(
                  labelId: labelId,
                  emoji: emoji,
                  name: name,
                ),
                _CursorPreviewContent(content: content),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _CursorPreviewHeader extends StatelessWidget {
  const _CursorPreviewHeader({
    required this.labelId,
    required this.emoji,
    required this.name,
  });

  final String labelId;
  final String? emoji;
  final String name;

  @override
  Widget build(BuildContext context) {
    final displayName = emoji != null && emoji!.isNotEmpty
        ? '$emoji $name'
        : name;

    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.overlayHeader,
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: colors.overlayBorder,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          spacing: 8,
          children: [
            const PulsingDot(),
            Flexible(
              child: Text(
                labelId.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4.0,
                  color: colors.primary,
                ),
              ),
            ),
            Expanded(
              child: Text(
                displayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.heading,
                ),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Content
// ---------------------------------------------------------------------------

class _CursorPreviewContent extends StatelessWidget {
  const _CursorPreviewContent({required this.content});

  final String? content;

  @override
  Widget build(BuildContext context) {
    final text = content;
    final snippet = text != null && text.isNotEmpty
        ? '${text.substring(0, min(text.length, 150))}${text.length > 150 ? '...' : ''}'
        : 'No content added yet.';

    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          snippet,
          style: TextStyle(
            fontFamily: TFontFamilies.jetBrainsMono,
            fontSize: 10,
            color: context.colors.overlayText,
            height: 1.625,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pulsing Dot
// ---------------------------------------------------------------------------

class PulsingDot extends StatefulWidget {
  const PulsingDot({
    super.key,
    this.size = 6,
    this.color = TColors.primaryDark,
  });

  final double size;
  final Color color;

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 1.0, end: 0.5)
        .chain(CurveTween(curve: const Cubic(0.4, 0, 0.6, 1)))
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _opacity,
        builder: (context, child) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: _opacity.value),
            ),
            child: SizedBox(
              width: widget.size,
              height: widget.size,
            ),
          );
        },
      ),
    );
  }
}
