import 'package:flutter/widgets.dart';
import 'package:turbo_widgets/src/responsive/typdefs/device_type_builder_def.dart';
import 'package:turbo_widgets/src/services/t_overlay_buttons_service.dart';

class TOverlayButtons extends StatefulWidget {
  const TOverlayButtons({
    super.key,
    this.child,
    required this.route,
    this.navigationBar,
    this.builder,
    this.forceUpdate = false,
  });

  final Widget? child;
  final bool forceUpdate;
  final DeviceTypeBuilderDef? navigationBar;
  final String route;
  final Widget Function(BuildContext context, Widget? child)? builder;

  @override
  State<TOverlayButtons> createState() => _TOverlayButtonsState();
}

class _TOverlayButtonsState extends State<TOverlayButtons> {
  @override
  void initState() {
    TOverlayButtonsService.locate.add(
      forceUpdate: widget.forceUpdate,
      route: widget.route,
      navigationBar: widget.navigationBar,
    );
    super.initState();
  }

  @override
  Future<void> dispose() async {
    TOverlayButtonsService.locate.remove(route: widget.route);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder == null
      ? widget.child ?? const SizedBox.shrink()
      : widget.builder!(context, widget.child);
}
