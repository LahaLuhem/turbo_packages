/// Variations for contextual content in a [TContextualButtons].
///
/// Variations allow multiple content layers at the same position,
/// stacked according to the position's axis (vertical for top/bottom,
/// horizontal for left/right).
enum TContextualVariation {
  /// Primary variation (closest to the screen edge).
  primary,

  /// Secondary variation (middle layer).
  secondary,

  /// Tertiary variation (furthest from the screen edge).
  tertiary,
}
