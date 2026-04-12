import 'package:flutter/material.dart';

class TOverlayTuple {
  const TOverlayTuple({
    required this.overlayEntry,
    required this.onDismissed,
  });

  final OverlayEntry overlayEntry;
  final VoidCallback? onDismissed;
}
