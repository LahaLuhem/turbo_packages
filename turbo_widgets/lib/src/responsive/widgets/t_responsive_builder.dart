import 'package:flutter/widgets.dart';
import 'package:turbo_widgets/src/responsive/config/t_breakpoint_config.dart';
import 'package:turbo_widgets/src/responsive/extensions/box_constraints_extension.dart';
import 'package:turbo_widgets/src/responsive/models/t_data.dart';
import 'package:turbo_widgets/src/responsive/utils/t_tools.dart';

class TResponsiveBuilder extends StatelessWidget {
  const TResponsiveBuilder({
    super.key,
    required this.builder,
    this.child,
    this.breakpointConfig = const TBreakpointConfig(),
    this.widthInDesign = 1440,
    this.heightInDesign = 1024,
    this.mediaQueryData,
  });

  final Widget Function(
    BuildContext context,
    Widget? child,
    BoxConstraints constraints,
    TTools tools,
    TData data,
  )
  builder;

  final Widget? child;
  final TBreakpointConfig breakpointConfig;
  final double widthInDesign;
  final double heightInDesign;
  final MediaQueryData? mediaQueryData;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final media = mediaQueryData ?? MediaQuery.of(context);
      final tools = TTools(
        currentWidth: constraints.maxWidth,
        currentHeight: constraints.maxHeight,
        widthInDesign: widthInDesign,
        heightInDesign: heightInDesign,
      );
      final data = TData(
        currentWidth: constraints.maxWidth,
        currentHeight: constraints.maxHeight,
        orientation: constraints.orientation,
        deviceType: constraints.deviceType(breakpointConfig: breakpointConfig),
        media: media,
      );
      final builtWidget = builder(context, child, constraints, tools, data);

      // Wrap the result in a SizedBox to avoid intrinsic dimension calculations.
      return SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: builtWidget,
      );
    },
  );
}
