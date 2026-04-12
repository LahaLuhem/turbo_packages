import 'package:flutter/foundation.dart';

/// Interface for tracking which navigation tab is active.
/// T is the enum type representing navigation tabs.
abstract interface class TNavigationTabServiceInterface<T> {
  /// Listenable for the currently active navigation tab.
  ValueListenable<T?> get activeTab;
}
