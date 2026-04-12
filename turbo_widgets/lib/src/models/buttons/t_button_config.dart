import 'package:flutter/widgets.dart';

class TButtonConfig {
  const TButtonConfig({
    required this.onPressed,
    this.icon,
    this.label,
    this.tooltip,
    this.isActive = false,
  });

  final IconData? icon;
  final String? label;
  final String? tooltip;
  final bool isActive;
  final VoidCallback onPressed;

  TButtonConfig copyWith({
    VoidCallback? onPressed,
    IconData? icon,
    String? label,
    String? tooltip,
    bool? isActive,
  }) => TButtonConfig(
    onPressed: onPressed ?? this.onPressed,
    icon: icon ?? this.icon,
    label: label ?? this.label,
    tooltip: tooltip ?? this.tooltip,
    isActive: isActive ?? this.isActive,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TButtonConfig &&
          runtimeType == other.runtimeType &&
          onPressed == other.onPressed &&
          icon == other.icon &&
          label == other.label &&
          tooltip == other.tooltip &&
          isActive == other.isActive;

  @override
  int get hashCode => Object.hash(
    onPressed,
    icon,
    label,
    tooltip,
    isActive,
  );
}
