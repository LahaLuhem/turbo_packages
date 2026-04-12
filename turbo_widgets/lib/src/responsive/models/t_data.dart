import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:turbo_widgets/src/responsive/enums/t_device_type.dart';
import 'package:turbo_widgets/src/responsive/enums/t_orientation.dart';

class TData {
  const TData({
    required this.currentWidth,
    required this.currentHeight,
    required this.orientation,
    required this.deviceType,
    required this.media,
  });

  final double currentWidth;
  final double currentHeight;
  final TOrientation orientation;
  final TDeviceType deviceType;
  final MediaQueryData media;

  bool get isPortrait => orientation == TOrientation.portrait;
  bool get isLandscape => orientation == TOrientation.landscape;
  bool get isSquare => orientation == TOrientation.square;
  bool get isTablet => deviceType == TDeviceType.tablet;
  bool get isMobile => deviceType == TDeviceType.mobile;

  TData copyWith({
    double? currentWidth,
    double? currentHeight,
    TOrientation? orientation,
    TDeviceType? deviceType,
    MediaQueryData? media,
  }) => TData(
    currentWidth: currentWidth ?? this.currentWidth,
    currentHeight: currentHeight ?? this.currentHeight,
    orientation: orientation ?? this.orientation,
    deviceType: deviceType ?? this.deviceType,
    media: media ?? this.media,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TData &&
          runtimeType == other.runtimeType &&
          currentWidth == other.currentWidth &&
          currentHeight == other.currentHeight &&
          orientation == other.orientation &&
          deviceType == other.deviceType &&
          media == other.media;

  @override
  int get hashCode =>
      currentWidth.hashCode ^
      currentHeight.hashCode ^
      orientation.hashCode ^
      deviceType.hashCode ^
      media.hashCode;

  double get bottomSafeArea => media.viewPadding.bottom;
  double get bottomSafeAreaWithMinimum => max(bottomSafeArea, 16);
  double get bottomViewInsets => media.viewInsets.bottom;
  double get height => media.size.height;
  double get topSafeArea => media.viewPadding.top;
  double get topViewInsets => media.viewInsets.top;
  double get width => media.size.width;
}
