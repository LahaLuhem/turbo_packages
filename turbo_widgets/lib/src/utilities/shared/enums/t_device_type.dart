import 'package:flutter/cupertino.dart';

enum TDeviceType {
  mobile,
  tablet,
  desktop
  ;

  bool get isMobile => this == TDeviceType.mobile;
  bool get isTabletDesktop => this == TDeviceType.tablet;
  bool get isDesktop => this == TDeviceType.desktop;
  bool get isNotMobile => !isMobile;

  Axis get navigationBarAxis {
    switch (this) {
      case TDeviceType.mobile:
        return Axis.horizontal;
      case TDeviceType.tablet:
      case TDeviceType.desktop:
        return Axis.vertical;
    }
  }

  static const Set<TDeviceType> all = {...TDeviceType.values};

  bool get showButtonLabel {
    switch (this) {
      case TDeviceType.mobile:
        return false;
      case TDeviceType.tablet:
      case TDeviceType.desktop:
        return true;
    }
  }
}
