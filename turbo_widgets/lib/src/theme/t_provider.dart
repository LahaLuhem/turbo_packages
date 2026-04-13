import 'package:flutter/material.dart';
import 'package:turbo_widgets/src/responsive/config/t_breakpoint_config.dart';
import 'package:turbo_widgets/src/responsive/models/t_data.dart';
import 'package:turbo_widgets/src/responsive/utils/t_tools.dart';
import 'package:turbo_widgets/src/theme/t_colors.dart';
import 'package:turbo_widgets/src/theme/t_decorations.dart';
import 'package:turbo_widgets/src/theme/t_sizes.dart';
import 'package:turbo_widgets/src/theme/t_texts.dart';
import 'package:turbo_widgets/src/theme/t_theme_mode.dart';

class TProvider extends InheritedWidget {
  const TProvider({
    super.key,
    required super.child,
    required this.colors,
    required this.data,
    required this.decorations,
    required this.texts,
    required this.themeMode,
    required this.tools,
    required this.breakpointConfig,
    required this.sizes,
  });

  final TColors colors;
  final TSizes sizes;
  final TDecorations decorations;
  final TTexts texts;
  final TData data;
  final TThemeMode themeMode;
  final TTools tools;
  final TBreakpointConfig breakpointConfig;

  static TProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TProvider>()!;
  @override
  bool updateShouldNotify(TProvider oldWidget) =>
      tools != oldWidget.tools ||
      data != oldWidget.data ||
      themeMode != oldWidget.themeMode ||
      colors != oldWidget.colors ||
      sizes != oldWidget.sizes ||
      decorations != oldWidget.decorations ||
      texts != oldWidget.texts ||
      breakpointConfig != oldWidget.breakpointConfig;
}
