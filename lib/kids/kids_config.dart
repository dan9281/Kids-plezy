import 'package:flutter/foundation.dart';

import '../navigation/navigation_tabs.dart';

/// Central switches for the Kids Plezy build.
///
/// Everything kid-specific that a parent might want to tweak lives here so
/// changes don't have to be hunted down across the code base.
class KidsConfig {
  KidsConfig._();

  /// PIN a grown-up types to open Settings. Change this before you install
  /// the app on the kids' devices.
  static const String parentPin = '1234';

  /// Tabs that never appear in the kids build.
  static const Set<NavigationTabId> hiddenTabs = {
    NavigationTabId.explore, // Trakt / Seerr / trending from outside the library
    NavigationTabId.liveTv,
    NavigationTabId.downloads,
  };

  /// True once the parent PIN has been entered. Locks again as soon as the
  /// grown-up leaves Settings (see MainScreen._selectTab and ParentGate).
  static final ValueNotifier<bool> parentUnlocked = ValueNotifier<bool>(false);

  static void lock() => parentUnlocked.value = false;
}
