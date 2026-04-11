import 'package:flutter/foundation.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:turbo_mvvm/turbo_mvvm.dart';
import 'package:turbo_notifiers/turbo_notifiers.dart';
import 'package:turbo_widgets/turbo_widgets.dart';

/// Drives the product detail page for [TSideNavBar].
///
/// This is the richest navigation widget with the most tunable parameters:
/// layout mode (auto/vertical/horizontal), expanded/collapsed state,
/// selected item, button alignment, divider visibility, and a "last
/// selected key" observable for callback demonstration.
class TSideNavBarShowcaseViewModel extends TBaseViewModel<void> {
  TSideNavBarShowcaseViewModel();

  // 🎬 INIT & DISPOSE ------------------------------------------------------------------------ \\

  @override
  Future<void> initialise({bool doSetInitialised = true}) async {
    await super.initialise(doSetInitialised: doSetInitialised);
  }

  @override
  void dispose() {
    _layout.dispose();
    _isExpanded.dispose();
    _selectedKey.dispose();
    _showDividers.dispose();
    _buttonAlignment.dispose();
    _lastSelectedKey.dispose();
    super.dispose();
  }

  // 🎩 STATE --------------------------------------------------------------------------------- \\

  final TNotifier<TSideNavBarLayout> _layout =
      TNotifier<TSideNavBarLayout>(TSideNavBarLayout.auto);

  final TNotifier<bool> _isExpanded = TNotifier<bool>(false);

  final TNotifier<String?> _selectedKey = TNotifier<String?>('home');

  final TNotifier<bool> _showDividers = TNotifier<bool>(false);

  final TNotifier<TSideNavBarButtonAlignment> _buttonAlignment =
      TNotifier<TSideNavBarButtonAlignment>(TSideNavBarButtonAlignment.start);

  final TNotifier<String?> _lastSelectedKey = TNotifier<String?>(null);

  // 🧲 FETCHERS ------------------------------------------------------------------------------ \\

  /// The layout mode: auto (adapts to width), vertical, or horizontal.
  ValueListenable<TSideNavBarLayout> get layout => _layout;

  /// Whether the side nav bar is in expanded (wide) or collapsed (icon-only)
  /// mode.
  ValueListenable<bool> get isExpanded => _isExpanded;

  /// The currently selected button key.
  ValueListenable<String?> get selectedKey => _selectedKey;

  /// Whether dividers are shown between leading/buttons/trailing sections.
  ValueListenable<bool> get showDividers => _showDividers;

  /// The alignment of buttons within the nav bar.
  ValueListenable<TSideNavBarButtonAlignment> get buttonAlignment =>
      _buttonAlignment;

  /// The last button key selected via the onSelect callback.
  ValueListenable<String?> get lastSelectedKey => _lastSelectedKey;

  /// Sample buttons for the side nav bar demo.
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

  void updateLayout(TSideNavBarLayout value) => _layout.value = value;

  void toggleIsExpanded() => _isExpanded.value = !_isExpanded.value;

  void updateSelectedKey(String? value) => _selectedKey.value = value;

  void toggleShowDividers() => _showDividers.value = !_showDividers.value;

  void updateButtonAlignment(TSideNavBarButtonAlignment value) =>
      _buttonAlignment.value = value;

  /// Called when a button is selected via the side nav bar's onSelect.
  void onSelect(String key) {
    _selectedKey.value = key;
    _lastSelectedKey.value = key;
  }
}
