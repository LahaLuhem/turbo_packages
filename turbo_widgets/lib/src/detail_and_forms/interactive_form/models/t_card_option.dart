import 'package:flutter/widgets.dart';

class TCardOption {
  const TCardOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.svgPath,
  });

  final String title;
  final IconData? icon;
  final String? svgPath;
  final bool Function() isSelected;
  final VoidCallback onTap;
}
