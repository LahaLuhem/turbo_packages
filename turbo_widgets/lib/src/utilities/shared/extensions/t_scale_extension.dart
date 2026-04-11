import 'dart:math';

extension TScaleExtensionExtension on double {
  double scaledPerWidth({
    required double currentWidth,
    required double widthInDesign,
    double speed = 1.0,
  }) {
    final widthScale = currentWidth / widthInDesign;
    final adjustedScale = pow(widthScale, speed);
    return this * adjustedScale;
  }

  double scaledPerHeight({
    required double currentHeight,
    required double heightInDesign,
    double speed = 1.0,
  }) {
    final heightScale = currentHeight / heightInDesign;
    final adjustedScale = pow(heightScale, speed);
    return this * adjustedScale;
  }

  double scaledPerWidthAndHeight({
    required double currentWidth,
    required double currentHeight,
    required double widthInDesign,
    required double heightInDesign,
    double speed = 1.0,
  }) {
    final widthScale = currentWidth / widthInDesign;
    final heightScale = currentHeight / heightInDesign;
    final scale = min(widthScale, heightScale);
    final adjustedScale = pow(scale, speed);
    return this * adjustedScale;
  }
}
