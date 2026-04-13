import 'package:flutter/material.dart';

typedef HoverWidgetBuilder =
    Widget Function(BuildContext context, bool isHovered, Widget? child);

class HoverBuilder extends StatefulWidget {
  const HoverBuilder({
    super.key,
    required this.builder,
    this.isActive = true,
    this.child,
    this.onHover,
  });

  final HoverWidgetBuilder builder;
  final bool isActive;
  final Widget? child;
  final void Function(bool isHovered)? onHover;

  @override
  HoverBuilderState createState() => HoverBuilderState();
}

class HoverBuilderState extends State<HoverBuilder> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) => widget.isActive
      ? MouseRegion(
          onEnter: (_) => setState(() {
            isHovered = true;
            widget.onHover?.call(isHovered);
          }),
          onExit: (_) => setState(() {
            isHovered = false;
            widget.onHover?.call(isHovered);
          }),
          child: widget.builder(context, isHovered, widget.child),
        )
      : widget.builder(context, isHovered, widget.child);
}
