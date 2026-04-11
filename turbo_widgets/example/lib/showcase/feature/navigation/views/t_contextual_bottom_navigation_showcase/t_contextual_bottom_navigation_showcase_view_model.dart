import 'package:flutter/foundation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';
import 'package:turbo_widgets/turbo_widgets.dart';

/// Drives the product detail page for [TContextualBottomNavigation].
///
/// Exposes tunable cells for the bottom navigation bar's visible parameters:
/// which tab is selected, whether labels are shown, and the active/inactive
/// button variants. Sample buttons are provided as a fixed list.
class TContextualBottomNavigationShowcaseViewModel
    extends TBaseViewModel<void> {
  TContextualBottomNavigationShowcaseViewModel();

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  @override
  void dispose() {
    _selectedKey.dispose();
    _showLabels.dispose();
    _lastSelectedKey.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final TNotifier<String?> _selectedKey = TNotifier<String?>('home');

  final TNotifier<bool> _showLabels = TNotifier<bool>(true);

  final TNotifier<String?> _lastSelectedKey = TNotifier<String?>(null);

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// The currently selected tab key.
  ValueListenable<String?> get selectedKey => _selectedKey;

  /// Whether button labels are visible.
  ValueListenable<bool> get showLabels => _showLabels;

  /// The last tab key selected via the onSelect callback.
  ValueListenable<String?> get lastSelectedKey => _lastSelectedKey;

  /// Sample buttons for the bottom navigation demo.
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

  /// Called when a tab is selected via the bottom navigation's onSelect.
  void onSelect(String key) {
    _selectedKey.value = key;
    _lastSelectedKey.value = key;
  }
}
