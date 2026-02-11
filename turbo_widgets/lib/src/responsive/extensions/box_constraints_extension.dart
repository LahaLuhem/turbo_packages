import 'package:flutter/widgets.dart';
import 'package:turbo_widgets/src/responsive/config/t_breakpoint_config.dart';
import 'package:turbo_widgets/src/responsive/enums/t_device_type.dart';
import 'package:turbo_widgets/src/responsive/enums/t_orientation.dart';

extension BoxConstraintsExtension on BoxConstraints {
  TOrientation get orientation {
    final difference = (maxHeight - maxWidth).abs();
    const landscapeMultiplier = 1;
    const portraitMultiplier = 1;
    final landscapeThreshold = maxHeight * landscapeMultiplier;
    final portraitThreshold = maxWidth * portraitMultiplier;

    if (difference <= landscapeThreshold && difference <= portraitThreshold) {
      return TOrientation.square;
    }

    return maxHeight > maxWidth ? TOrientation.portrait : TOrientation.landscape;
  }

  TDeviceType deviceType({
    required TBreakpointConfig breakpointConfig,
    bool doConsiderHeight = false,
  }) {
    if (maxWidth >= breakpointConfig.desktopBreakpointWidth ||
        (doConsiderHeight &&  maxHeight >= breakpointConfig.desktopBreakpointHeight)) {
      return TDeviceType.desktop;
    }
    if (maxWidth >= breakpointConfig.tabletBreakpointWidth) {
      return TDeviceType.tablet;
    }
    return TDeviceType.mobile;
  }
}
