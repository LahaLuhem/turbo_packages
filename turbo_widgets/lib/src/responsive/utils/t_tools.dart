import 'package:turbo_widgets/src/responsive/extensions/t_scale_extension.dart';

class TTools {
  TTools({
    required this.currentWidth,
    required this.currentHeight,
    required this.widthInDesign,
    required this.heightInDesign,
  });

  final double currentWidth;
  final double currentHeight;
  final double widthInDesign;
  final double heightInDesign;

  double scaledPerWidth(
    double value, {
    double bottomLimit = 0.50,
    double upperLimit = 1,
    double speed = 1.0,
  }) => value
      .scaledPerWidth(
        currentWidth: currentWidth,
        widthInDesign: widthInDesign,
        speed: speed,
      )
      .clamp(value * bottomLimit, value * upperLimit);

  double scaledPerHeight(
    double value, {
    double bottomLimit = 0.50,
    double upperLimit = 1.00,
    double speed = 1.0,
  }) => value
      .scaledPerHeight(
        currentHeight: currentHeight,
        heightInDesign: heightInDesign,
        speed: speed,
      )
      .clamp(value * bottomLimit, value * upperLimit);

  double scaled(
    double value, {
    double bottomLimit = 0.50,
    double upperLimit = 1.00,
    double speed = 1.00,
  }) => value
      .scaledPerWidthAndHeight(
        currentHeight: currentHeight,
        currentWidth: currentWidth,
        widthInDesign: widthInDesign,
        heightInDesign: heightInDesign,
        speed: speed,
      )
      .clamp(value * bottomLimit, value * upperLimit);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TTools &&
          runtimeType == other.runtimeType &&
          currentWidth == other.currentWidth &&
          currentHeight == other.currentHeight &&
          widthInDesign == other.widthInDesign &&
          heightInDesign == other.heightInDesign;

  @override
  int get hashCode =>
      currentWidth.hashCode ^
      currentHeight.hashCode ^
      widthInDesign.hashCode ^
      heightInDesign.hashCode;

  TTools copyWith({double? currentWidth, double? currentHeight}) => TTools(
    currentWidth: currentWidth ?? this.currentWidth,
    currentHeight: currentHeight ?? this.currentHeight,
    widthInDesign: widthInDesign,
    heightInDesign: heightInDesign,
  );
}
