import 'package:flutter/widgets.dart';

class TCalculatedHeight extends StatelessWidget {
  const TCalculatedHeight({
    super.key,
    required this.count,
    required this.baseHeight,
    required this.multiplierThreshold,
    required this.child,
    this.minHeight,
    this.maxHeight,
  }) : assert(count >= 0),
       assert(multiplierThreshold > 0),
       assert(
         minHeight == null || maxHeight == null || minHeight <= maxHeight,
       );

  final int count;
  final double baseHeight;
  final int multiplierThreshold;
  final double? minHeight;
  final double? maxHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final rawHeight = (count / multiplierThreshold) * baseHeight;
    final height = rawHeight.clamp(
      minHeight ?? 0.0,
      maxHeight ?? double.infinity,
    );
    return SizedBox(
      height: height,
      child: child,
    );
  }
}
