import 'package:flutter/material.dart';

class TGradient extends LinearGradient {
  const TGradient.topCenter({required super.colors, super.stops})
    : super(begin: Alignment.topCenter, end: Alignment.bottomCenter);

  const TGradient.bottomTop({super.stops, required super.colors})
    : super(begin: Alignment.bottomCenter, end: Alignment.topCenter);

  const TGradient.topLeft({required super.colors, super.stops})
    : super(begin: const Alignment(-0.5, -1.5), end: Alignment.bottomCenter);

  const TGradient.topRight({required super.colors, super.stops})
    : super(begin: Alignment.topRight, end: Alignment.bottomCenter);
}

class TGradientRadial extends RadialGradient {
  const TGradientRadial({required super.colors, super.stops})
    : super(center: Alignment.center, radius: 0.8);
}
