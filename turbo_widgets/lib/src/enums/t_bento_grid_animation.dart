/// Animation type for TBentoGrid layout transitions.
enum TBentoGridAnimation {
  /// Cards smoothly slide and resize to new positions.
  slide,

  /// Cards fade out, layout recalculates, then fade in.
  fade,

  /// Cards scale down, layout recalculates, then scale up.
  scale,

  /// Instant layout change with no animation.
  none,
}
