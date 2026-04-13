import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:turbo_widgets/src/responsive/config/t_breakpoint_config.dart';
import 'package:turbo_widgets/src/responsive/enums/t_device_type.dart';
import 'package:turbo_widgets/src/responsive/models/t_data.dart';
import 'package:turbo_widgets/src/responsive/utils/t_tools.dart';
import 'package:turbo_widgets/src/theme/t_colors.dart';
import 'package:turbo_widgets/src/theme/t_decorations.dart';
import 'package:turbo_widgets/src/theme/t_provider.dart';
import 'package:turbo_widgets/src/theme/t_sizes.dart';
import 'package:turbo_widgets/src/theme/t_texts.dart';
import 'package:turbo_widgets/src/theme/t_theme.dart';
import 'package:turbo_widgets/src/theme/t_theme_mode.dart';

extension TContextExtension on BuildContext {
  RenderBox? get renderBox {
    final renderBox = findRenderObject() as RenderBox?;
    return renderBox;
  }

  TProvider get turboProvider => TProvider.of(this);
  TTexts get texts => turboProvider.texts;
  TColors get colors => turboProvider.colors;
  TTools get tools => turboProvider.tools;
  TSizes get sizes => turboProvider.sizes;
  TDecorations get decorations => turboProvider.decorations;
  TData get data => turboProvider.data;
  TThemeMode get themeMode => turboProvider.themeMode;

  TTheme get theme => TTheme(
    data: () => _shadTheme,
    materialData: () => _materialTheme,
    mode: () => _themeMode,
    text: () => _shadTextTheme,
    materialText: () => _materialTextTheme,
  );

  ShadTextTheme get _shadTextTheme => _shadTheme.textTheme;
  ShadThemeData get _shadTheme => ShadTheme.of(this);
  TThemeMode get _themeMode => turboProvider.themeMode;
  TextTheme get _materialTextTheme => _materialTheme.textTheme;
  ThemeData get _materialTheme => Theme.of(this);

  TBreakpointConfig get breakpointConfig => turboProvider.breakpointConfig;
  TDeviceType get deviceType => turboProvider.data.deviceType;
  bool get hasKeyboard => sizes.keyboardInsets > 0;
  OverlayState get overlayState => Overlay.of(this, rootOverlay: true);
  MediaQueryData get media => MediaQuery.of(this);
  double get maxWidth => media.size.width;
  double get maxHeight => media.size.height;

  void unfocus() => FocusScope.of(this).unfocus();
}
