import 'dart:math';

import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/responsive/enums/t_device_type.dart';

class TSizes {
  TSizes({required this.context, required this.deviceType});

  // 🧩 DEPENDENCIES -------------------------------------------------------------------------- \\

  final BuildContext context;
  final TDeviceType deviceType;

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  static const appBarGap = 16.0;
  static const addButtonWidth = 120.0;
  static const appBarHeight = 64.0;
  static const appBarSpacing = 16.0;
  static const appBarRadius = 0.0;
  static const appPadding = 24.0;
  static const avatar = 40.0;
  static const appPaddingX0p5 = appPadding / 2;
  static const appPaddingX0p75 = appPadding * 0.75;
  static const appPaddingX2 = appPadding * 2;
  static const borderWidth = 1.0;
  static const bottomNavHeight = 64.0;
  static const buttonBorderRadius = 0.0;
  static const buttonHoverBorderRadius = 0.0;
  static const cardPadding = 24.0;
  static const cardRadius = 0.0;
  static const chipButtonHeight = 32.0;
  static const chipHeight = 32.0;
  static const ctaBarLabelMaxWidth = 280.0;
  static const dialogMaxWidth = 480.0;
  static const elementGap = 16.0;
  static const formFieldHeight = 40.0;
  static const headerTitleGap = 16.0;
  static const heightButtonBottomFade = 144.0;
  static const heightTabBarBottom = 56.0;
  static const horizontalButtonPadding = 16.0;
  static const iconButtonSize = 80.0;
  static const iconGap = 8.0;
  static const iconHeight = 32.0;
  static const iconSize = 24.0;
  static const iconSizeX0p75 = iconSize * 0.75;
  static const iconSizeX1p25 = iconSize * 1.25;
  static const itemGap = 12.0;
  static const labelGap = 12.0;
  static const listItemGap = 16.0;
  static const listItemMinHeight = 88.0;
  static const folderFileEditorHeight = listItemMinHeight * 4;
  static const listItemTitleCaption = 6.0;
  static const minButtonHeight = 40.0;
  static const minButtonWidth = 64.0;
  static const minIconSize = 40.0;
  static const opacityDisabled = 0.3;
  static const prototypeHeight = 1440.0;
  static const prototypeWidth = 720.0;
  static const sectionGap = 24.0;
  /// Collapsed workspace side rail width (icon-only).
  static const sideNavRailCollapsedWidth = 60.0;
  /// Expanded workspace side panel width (labels visible).
  static const sideNavPanelExpandedWidth = 256.0;
  static const sectionPadding = 10.0;
  static const showHideScrollDownThreshold = 10.0;
  static const smallCardButtonRadius = 0.0;
  static const subtitleGap = 4.0;
  static const tabHeight = 40.0;
  static const textGap = 8.0;
  static const titleGap = 16.0;
  static const wrapMinChildWidth = 320.0;

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  double get sideNavBarWidth {
    switch (deviceType) {
      case TDeviceType.mobile:
        return width * 0.8;
      case TDeviceType.tablet:
        return width * 0.6;
      case TDeviceType.desktop:
        return 400;
    }
  }

  Offset get globalBottomLeftPosition =>
      (context.findRenderObject() as RenderBox?)?.localToGlobal(
        (context.findRenderObject() as RenderBox?)!.size.bottomLeft(Offset.zero),
      ) ??
      Offset.zero;
  Offset get globalBottomRightPosition =>
      (context.findRenderObject() as RenderBox?)?.localToGlobal(
        (context.findRenderObject() as RenderBox?)!.size.bottomRight(Offset.zero),
      ) ??
      Offset.zero;
  Offset get globalCenterPosition =>
      (context.findRenderObject() as RenderBox?)?.localToGlobal(
        (context.findRenderObject() as RenderBox?)!.size.center(Offset.zero),
      ) ??
      Offset.zero;
  Offset get globalTopLeftPosition =>
      (context.findRenderObject() as RenderBox?)?.localToGlobal(
        (context.findRenderObject() as RenderBox?)!.size.topLeft(Offset.zero),
      ) ??
      Offset.zero;
  Offset get globalTopRightPosition =>
      (context.findRenderObject() as RenderBox?)?.localToGlobal(
        (context.findRenderObject() as RenderBox?)!.size.topRight(Offset.zero),
      ) ??
      Offset.zero;

  bool get hasKeyboard => MediaQuery.of(context).viewInsets.bottom > 0;

  double get bottomSafeArea => MediaQuery.of(context).viewPadding.bottom;
  double get bottomSafeAreaWithMinimum =>
      hasKeyboard ? 16 : max(bottomSafeArea, 16);
  double get bottomViewInsets => MediaQuery.of(context).viewInsets.bottom;
  double get globalBottomInPositioned => height - globalBottomLeftPosition.dy;
  double get globalLeftInPositioned => globalTopLeftPosition.dx;
  double get globalRightInPositioned => width - globalTopRightPosition.dx;
  double get globalTopInPositioned => globalTopLeftPosition.dy;
  double get height => MediaQuery.of(context).size.height;
  double get topSafeArea => MediaQuery.of(context).viewPadding.top;
  double get width => MediaQuery.of(context).size.width;
  double get keyboardInsets => MediaQuery.viewInsetsOf(context).bottom;

  double get appBarSafeHeight => kToolbarHeight + topSafeArea;
}
