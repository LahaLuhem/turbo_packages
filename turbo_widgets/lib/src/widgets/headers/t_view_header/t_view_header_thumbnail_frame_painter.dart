import 'package:flutter/rendering.dart';

class TViewHeaderThumbnailFramePainter extends CustomPainter {
  const TViewHeaderThumbnailFramePainter({
    required this.thumbnailSize,
  });

  final double thumbnailSize;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final half = thumbnailSize / 2;

    const innerOutset = 8.0;
    const outerOutset = 16.0;

    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x0DFFFFFF);

    final innerRect = Rect.fromCenter(
      center: center,
      width: half * 2 + innerOutset * 2,
      height: half * 2 + innerOutset * 2,
    );
    canvas.drawRect(innerRect, innerPaint);

    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x06FFFFFF);

    final outerRect = Rect.fromCenter(
      center: center,
      width: half * 2 + outerOutset * 2,
      height: half * 2 + outerOutset * 2,
    );
    canvas.drawRect(outerRect, outerPaint);
  }

  @override
  bool shouldRepaint(TViewHeaderThumbnailFramePainter oldDelegate) =>
      thumbnailSize != oldDelegate.thumbnailSize;
}
