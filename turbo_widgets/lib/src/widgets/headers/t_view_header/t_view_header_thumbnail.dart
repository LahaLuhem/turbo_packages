import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/theme/t_colors.dart';
import 'package:turbo_widgets/src/widgets/headers/t_view_header/t_view_header_thumbnail_frame_painter.dart';
import 'package:turbo_widgets/src/widgets/misc/t_emoji_picker_popover.dart';

class TViewHeaderThumbnail extends StatefulWidget {
  const TViewHeaderThumbnail({
    super.key,
    required this.size,
    required this.iconSize,
    required this.emojiFontSize,
    required this.icon,
    this.emoji,
    this.onEmojiChanged,
  });

  final double size;
  final double iconSize;
  final double emojiFontSize;
  final IconData icon;
  final String? emoji;
  final ValueChanged<String>? onEmojiChanged;

  @override
  State<TViewHeaderThumbnail> createState() => _TViewHeaderThumbnailState();
}

class _TViewHeaderThumbnailState extends State<TViewHeaderThumbnail>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  static const _borderIdle = Color(0x1AFFFFFF);
  static const _borderHover = Color(0x4D07B6D4);
  static const _bg = Color(0xFF18181B);
  static const _shadow = Color(0x40000000);

  @override
  void initState() {
    super.initState();
    if (widget.onEmojiChanged != null) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      );
    }
  }

  @override
  void didUpdateWidget(TViewHeaderThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onEmojiChanged != null && _controller == null) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      );
    } else if (widget.onEmojiChanged == null && _controller != null) {
      _controller!.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frameSize = widget.size + 32;

    Widget thumbnail = _buildThumbnailBox(_borderIdle);

    if (_controller != null && widget.onEmojiChanged != null) {
      thumbnail = TEmojiPickerPopover(
        selectedEmoji: widget.emoji,
        onEmojiSelected: widget.onEmojiChanged!,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => _controller?.forward(),
          onExit: (_) => _controller?.reverse(),
          child: AnimatedBuilder(
            animation: _controller!,
            builder: (context, _) => _buildThumbnailBox(
              Color.lerp(_borderIdle, _borderHover, _controller!.value),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: frameSize,
      height: frameSize,
      child: CustomPaint(
        painter: TViewHeaderThumbnailFramePainter(
          thumbnailSize: widget.size,
        ),
        child: Center(child: thumbnail),
      ),
    );
  }

  Widget _buildThumbnailBox(Color? borderColor) {
    final content = widget.emoji != null
        ? Text(
            widget.emoji!,
            style: TextStyle(fontSize: widget.emojiFontSize, height: 1),
          )
        : Icon(
            widget.icon,
            size: widget.iconSize,
            color: TColors.primaryDark,
          );

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _bg,
          border: Border.all(
            width: 1,
            color: borderColor ?? _borderIdle,
          ),
          boxShadow: const [
            BoxShadow(color: _shadow, blurRadius: 25),
          ],
        ),
        child: Center(child: content),
      ),
    );
  }
}
