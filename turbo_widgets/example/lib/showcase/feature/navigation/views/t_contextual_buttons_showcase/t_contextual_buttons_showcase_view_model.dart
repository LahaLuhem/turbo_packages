import 'package:flutter/foundation.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';
import 'package:turbo_widgets/turbo_widgets.dart';

/// Drives the product detail page for [TContextualButtons].
///
/// TContextualButtons is a structural widget — it doesn't render visible
/// chrome by itself, it hosts content at four positions (top/bottom/left/right).
/// This view model lets the visitor toggle which positions have content,
/// change the allow filter, and observe config changes.
class TContextualButtonsShowcaseViewModel extends TBaseViewModel<void> {
  TContextualButtonsShowcaseViewModel();

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  @override
  void dispose() {
    _showTop.dispose();
    _showBottom.dispose();
    _showLeft.dispose();
    _showRight.dispose();
    _allowFilter.dispose();
    _lastConfigChange.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final TNotifier<bool> _showTop = TNotifier<bool>(true);

  final TNotifier<bool> _showBottom = TNotifier<bool>(true);

  final TNotifier<bool> _showLeft = TNotifier<bool>(false);

  final TNotifier<bool> _showRight = TNotifier<bool>(false);

  final TNotifier<TContextualAllowFilter> _allowFilter =
      TNotifier<TContextualAllowFilter>(TContextualAllowFilter.all);

  final TNotifier<String?> _lastConfigChange = TNotifier<String?>(null);

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// Whether the top position has content.
  ValueListenable<bool> get showTop => _showTop;

  /// Whether the bottom position has content.
  ValueListenable<bool> get showBottom => _showBottom;

  /// Whether the left position has content.
  ValueListenable<bool> get showLeft => _showLeft;

  /// Whether the right position has content.
  ValueListenable<bool> get showRight => _showRight;

  /// The active allow filter restricting which positions display content.
  ValueListenable<TContextualAllowFilter> get allowFilter => _allowFilter;

  /// Description of the last config change, for toast display.
  ValueListenable<String?> get lastConfigChange => _lastConfigChange;

  /// Builds the set of hidden positions from the current toggle states.
  Set<TContextualPosition> get hiddenPositions => {
        if (!_showTop.value) TContextualPosition.top,
        if (!_showBottom.value) TContextualPosition.bottom,
        if (!_showLeft.value) TContextualPosition.left,
        if (!_showRight.value) TContextualPosition.right,
      };

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void toggleShowTop() {
    _showTop.value = !_showTop.value;
    _lastConfigChange.value = 'Top ${_showTop.value ? 'shown' : 'hidden'}';
  }

  void toggleShowBottom() {
    _showBottom.value = !_showBottom.value;
    _lastConfigChange.value =
        'Bottom ${_showBottom.value ? 'shown' : 'hidden'}';
  }

  void toggleShowLeft() {
    _showLeft.value = !_showLeft.value;
    _lastConfigChange.value = 'Left ${_showLeft.value ? 'shown' : 'hidden'}';
  }

  void toggleShowRight() {
    _showRight.value = !_showRight.value;
    _lastConfigChange.value = 'Right ${_showRight.value ? 'shown' : 'hidden'}';
  }

  void updateAllowFilter(TContextualAllowFilter value) {
    _allowFilter.value = value;
    _lastConfigChange.value = 'Allow filter → ${value.name}';
  }
}
