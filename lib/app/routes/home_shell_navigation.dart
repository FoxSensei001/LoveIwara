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
    'community',
  ];

  /// Stable key -> go_router branch index.
  /// Keep this in sync with `StatefulShellRoute.indexedStack(branches: [...])`.
  static const Map<String, int> branchIndexByKey = <String, int>{
    'video': 0,
    'gallery': 1,
    'subscription': 2,
    'community': 3,
  };

  /// Stable key -> tab-root path.
  /// Keep this in sync with `StatefulShellRoute.indexedStack(branches: [...])`.
  static const Map<String, String> pathByKey = <String, String>{
    'video': '/',
    'gallery': '/gallery',
    'subscription': '/subscriptions',
    'community': '/community',
  };

  /// Keys the user is allowed to hide from the navigation UI.
  /// The corresponding `StatefulShellRoute` branch still exists so deep links
  /// (e.g. `/community`, `/forum`, `/news`) keep working even while hidden.
  static const Set<String> hideableKeys = <String>{'community'};

  /// 已下线的导航键 -> 现行键。
  ///
  /// 论坛与新闻在「社区」栏目里合并成了一个 tab（底栏元素数超了，见
  /// `community_page.dart`）。老用户的 [ConfigKey.NAVIGATION_ORDER] /
  /// [ConfigKey.NAVIGATION_HIDDEN] 里仍然存着 `forum` / `news`，
  /// [normalizeOrder] 会把它们就地折叠成 `community`——**位置按先出现的那个算**，
  /// 这样自定义过顺序的用户不会看到社区栏莫名其妙掉到最后一位。
  static const Map<String, String> legacyKeyAliases = <String, String>{
    'forum': 'community',
    'news': 'community',
  };

  /// 把一个可能是老键的导航键折叠成现行键；未知键返回 null。
  static String? resolveKey(Object? rawKey) {
    if (rawKey is! String) return null;
    final aliased = legacyKeyAliases[rawKey] ?? rawKey;
    return branchIndexByKey.containsKey(aliased) ? aliased : null;
  }

  /// 老栏目路径（`/forum` / `/news`）折叠到 `/community` 后的目标地址。
  ///
  /// 原有的 query 必须**原样带过去**：`/news?category=articles&lang=ja`
  /// 要变成 `/community?tab=news&category=articles&lang=ja`，否则从新闻站
  /// 分享出来的链接点进来会丢掉分类和语言。`tab` 放在前面、让原 query 覆盖
  /// 在后，是为了让显式带 `tab=` 的地址仍然说了算。
  static String legacyTabLocation(
    String tab,
    Map<String, String> queryParameters,
  ) {
    return Uri(
      path: pathByKey['community']!,
      queryParameters: <String, String>{'tab': tab, ...queryParameters},
    ).toString();
  }

  static int branchIndexForKey(String? key, {int fallback = 0}) {
    final resolved = resolveKey(key);
    if (resolved == null) return fallback;
    return branchIndexByKey[resolved] ?? fallback;
  }

  static String pathForKey(String? key, {String fallback = '/'}) {
    final resolved = resolveKey(key);
    if (resolved == null) return fallback;
    return pathByKey[resolved] ?? fallback;
  }

  /// go_router 分支下标 -> 现行导航键；不认识的下标返回 null。
  static String? keyForBranchIndex(int branchIndex) {
    for (final entry in branchIndexByKey.entries) {
      if (entry.value == branchIndex) return entry.key;
    }
    return null;
  }

  static String pathForBranchIndex(int branchIndex, {String fallback = '/'}) {
    final key = keyForBranchIndex(branchIndex);
    if (key == null) return fallback;
    return pathForKey(key, fallback: fallback);
  }

  /// 详情页顶部「回到主页」该落到哪个栏目。
  ///
  /// 判据只有一条：**当前所在栏目里有没有承载这类内容的子页签**。
  /// - 订阅栏自己就分「视频 / 图库 / 帖子」，所以从订阅进的详情，回主页落回
  ///   订阅栏（再由订阅页切到对应的那一半）；
  /// - 社区（论坛 / 新闻）里根本没有视频或图库列表，落回该类内容的固有栏目；
  /// - 视频 / 图库栏本身同理，落回自己。
  ///
  /// 不需要在进详情时「记住来路」：详情页是压在同一只 Shell Navigator 上的，
  /// `StatefulNavigationShell.currentIndex` 一路都还是进来时那个栏目——一层层
  /// 点进去（作者页 -> 另一个详情页）也不会变。
  static String homeBranchKeyForMedia(
    String? originKey, {
    required bool isGallery,
  }) {
    if (resolveKey(originKey) == 'subscription') return 'subscription';
    return isGallery ? 'gallery' : 'video';
  }

  /// Normalize a persisted navigation order.
  /// - folds legacy keys via [legacyKeyAliases] (`forum`/`news` -> `community`)
  /// - removes unknown keys
  /// - removes duplicates (first position wins)
  /// - appends missing keys using [canonicalOrder]
  static List<String> normalizeOrder(dynamic rawOrder) {
    final raw = rawOrder is List ? rawOrder : const <dynamic>[];
    final result = <String>[];

    for (final item in raw) {
      final key = resolveKey(item);
      if (key == null) continue;
      if (result.contains(key)) continue;
      result.add(key);
    }

    for (final item in canonicalOrder) {
      if (!result.contains(item)) {
        result.add(item);
      }
    }

    return result;
  }

  /// Normalize a persisted hidden-navigation list.
  /// - keeps only known, hideable keys
  /// - removes duplicates
  ///
  /// 合并迁移的关键一条：老配置里的 `forum` / `news` **必须两个都被隐藏**，
  /// 才把合并后的 `community` 判定为隐藏。只藏了新闻的用户当初还看得见论坛，
  /// 迁移后整条社区栏就不该凭空消失。
  static List<String> normalizeHidden(dynamic rawHidden) {
    final raw = rawHidden is List ? rawHidden : const <dynamic>[];
    final legacySeen = <String>{};
    final result = <String>[];

    for (final item in raw) {
      if (item is! String) continue;
      if (legacyKeyAliases.containsKey(item)) {
        legacySeen.add(item);
        continue;
      }
      if (!hideableKeys.contains(item)) continue;
      if (result.contains(item)) continue;
      result.add(item);
    }

    // 老键折叠：同一个现行键下的**所有**老键都在隐藏列表里才算隐藏。
    for (final entry in legacyKeyAliases.entries) {
      final target = entry.value;
      if (result.contains(target)) continue;
      if (!hideableKeys.contains(target)) continue;
      final legacyGroup = legacyKeyAliases.entries
          .where((e) => e.value == target)
          .map((e) => e.key);
      if (legacyGroup.every(legacySeen.contains)) {
        result.add(target);
      }
    }

    return result;
  }

  /// Filter a (normalized) display order down to the keys that are visible,
  /// i.e. not present in [hidden].
  static List<String> visibleOrder(
    List<String> displayOrder,
    Iterable<String> hidden,
  ) {
    final hiddenSet = hidden.toSet();
    return displayOrder.where((key) => !hiddenSet.contains(key)).toList();
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
