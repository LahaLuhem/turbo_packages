/// Filter for which positions are allowed to display contextual content.
///
/// Used with [TContextualButtons] to restrict which positions can show content.
/// For example, setting this to [left] will only allow left-positioned content
/// to be displayed, filtering out top, bottom, and right content.
enum TContextualAllowFilter {
  /// All positions are allowed.
  all,

  /// Only top position is allowed.
  top,

  /// Only bottom position is allowed.
  bottom,

  /// Only left position is allowed.
  left,

  /// Only right position is allowed.
  right,
}
