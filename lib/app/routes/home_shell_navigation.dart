/// Home shell navigation helpers.
///
/// Why this exists:
/// - `StatefulNavigationShell.goBranch(index)` uses the *branch index* (the
///   position inside `StatefulShellRoute.branches`).
/// - Our bottom-nav / rail UI order is user-customizable, so its *display index*
///   is not stable.
///
/// This module provides a stable key <-> branchIndex mapping and utilities to
/// translate between display indices and branch indices.
class HomeShellNavigation {
  static const List<String> canonicalOrder = <String>[
    'video',
    'gallery',
    'subscription',
    'forum',
    'news',
  ];

  /// Stable key -> go_router branch index.
  /// Keep this in sync with `StatefulShellRoute.indexedStack(branches: [...])`.
  static const Map<String, int> branchIndexByKey = <String, int>{
    'video': 0,
    'gallery': 1,
    'subscription': 2,
    'forum': 3,
    'news': 4,
  };

  /// Stable key -> tab-root path.
  /// Keep this in sync with `StatefulShellRoute.indexedStack(branches: [...])`.
  static const Map<String, String> pathByKey = <String, String>{
    'video': '/',
    'gallery': '/gallery',
    'subscription': '/subscriptions',
    'forum': '/forum',
    'news': '/news',
  };

  static int branchIndexForKey(String? key, {int fallback = 0}) {
    if (key == null) return fallback;
    return branchIndexByKey[key] ?? fallback;
  }

  static String pathForKey(String? key, {String fallback = '/'}) {
    if (key == null) return fallback;
    return pathByKey[key] ?? fallback;
  }

  static String pathForBranchIndex(int branchIndex, {String fallback = '/'}) {
    for (final entry in branchIndexByKey.entries) {
      if (entry.value == branchIndex) {
        return pathForKey(entry.key, fallback: fallback);
      }
    }
    return fallback;
  }

  /// Normalize a persisted navigation order.
  /// - removes unknown keys
  /// - removes duplicates
  /// - appends missing keys using [canonicalOrder]
  static List<String> normalizeOrder(dynamic rawOrder) {
    final raw = rawOrder is List ? rawOrder : const <dynamic>[];
    final result = <String>[];

    for (final item in raw) {
      if (item is! String) continue;
      if (!branchIndexByKey.containsKey(item)) continue;
      if (result.contains(item)) continue;
      result.add(item);
    }

    for (final item in canonicalOrder) {
      if (!result.contains(item)) {
        result.add(item);
      }
    }

    return result;
  }

  /// Convert a display index (UI order) to a branch index.
  static int branchIndexFromDisplayIndex(
    int displayIndex,
    List<String> displayOrder, {
    int fallback = 0,
  }) {
    if (displayIndex < 0 || displayIndex >= displayOrder.length) {
      return fallback;
    }
    return branchIndexForKey(displayOrder[displayIndex], fallback: fallback);
  }

  /// Convert a branch index to a display index, based on the provided UI order.
  static int displayIndexFromBranchIndex(
    int branchIndex,
    List<String> displayOrder, {
    int fallback = 0,
  }) {
    for (var i = 0; i < displayOrder.length; i++) {
      if (branchIndexForKey(displayOrder[i], fallback: -1) == branchIndex) {
        return i;
      }
    }
    return fallback;
  }
}
