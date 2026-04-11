import 'package:flutter/foundation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';
import 'package:turbo_widgets/turbo_widgets.dart';

/// Drives the product detail page for [TContextualSideNavigation].
///
/// Exposes tunable cells for the side navigation's visible parameters:
/// which item is selected, whether labels are shown, the spacing between
/// items, and a "last selected key" observable for callback demonstration.
class TContextualSideNavigationShowcaseViewModel extends TBaseViewModel<void> {
  TContextualSideNavigationShowcaseViewModel();

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  @override
  void dispose() {
    _selectedKey.dispose();
    _showLabels.dispose();
    _spacing.dispose();
    _lastSelectedKey.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final TNotifier<String?> _selectedKey = TNotifier<String?>('home');

  final TNotifier<bool> _showLabels = TNotifier<bool>(true);

  final TNotifier<double> _spacing = TNotifier<double>(8.0);

  final TNotifier<String?> _lastSelectedKey = TNotifier<String?>(null);

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// The currently selected item key.
  ValueListenable<String?> get selectedKey => _selectedKey;

  /// Whether item labels are visible.
  ValueListenable<bool> get showLabels => _showLabels;

  /// The vertical spacing between navigation items.
  ValueListenable<double> get spacing => _spacing;

  /// The last item key selected via the onSelect callback.
  ValueListenable<String?> get lastSelectedKey => _lastSelectedKey;

  /// Sample buttons for the side navigation demo.
  Map<String, TButtonConfig> get sampleButtons => {
        'home': TButtonConfig(
          icon: LucideIcons.house,
          label: 'Home',
          onPressed: () => onSelect('home'),
        ),
        'search': TButtonConfig(
          icon: LucideIcons.search,
          label: 'Search',
          onPressed: () => onSelect('search'),
        ),
        'inbox': TButtonConfig(
          icon: LucideIcons.inbox,
          label: 'Inbox',
          onPressed: () => onSelect('inbox'),
        ),
        'profile': TButtonConfig(
          icon: LucideIcons.user,
          label: 'Profile',
          onPressed: () => onSelect('profile'),
        ),
        'settings': TButtonConfig(
          icon: LucideIcons.settings,
          label: 'Settings',
          onPressed: () => onSelect('settings'),
        ),
      };

  // 🪄 MUTATORS ------------------------------------------------------------------------------ \\

  void updateSelectedKey(String? value) => _selectedKey.value = value;

  void toggleShowLabels() => _showLabels.value = !_showLabels.value;

  void updateSpacing(double value) => _spacing.value = value;

  /// Called when an item is selected via the side navigation's onSelect.
  void onSelect(String key) {
    _selectedKey.value = key;
    _lastSelectedKey.value = key;
  }
}
