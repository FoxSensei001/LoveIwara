import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/iwara_news.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/community/community_header_state.dart';
import 'package:i_iwara/app/ui/pages/forum/forum_page.dart';
import 'package:i_iwara/app/ui/pages/home_page.dart';
import 'package:i_iwara/app/ui/pages/news/news_page.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/fade_branch_container.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_overflow_menu_button.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:shimmer/shimmer.dart';

/// 社区栏目的目的地。
///
/// 论坛和新闻原本各占一个底栏 tab，加上搜索圆钮一共 6 个元素，浮动底栏摆不下
/// （见 `home_shell_navigation.dart`）。合并后两者共用一个 tab，在 header 上被
/// **拍平成一个下拉菜单**：论坛 / 更新 / 文章 / 广播。
///
/// 枚举顺序即菜单顺序，也是 [CommunityPageState] 里 `GlassFlipLabel` 的下标口径，
/// 不要随意调整。
enum CommunityDestination {
  forum,
  newsUpdates,
  newsArticles,
  newsBroadcast;

  bool get isForum => this == CommunityDestination.forum;

  bool get isNews => !isForum;

  /// 新闻分类；论坛返回 null。
  IwaraNewsCategoryType? get newsCategory => switch (this) {
    CommunityDestination.forum => null,
    CommunityDestination.newsUpdates => IwaraNewsCategoryType.newsUpdates,
    CommunityDestination.newsArticles => IwaraNewsCategoryType.articles,
    CommunityDestination.newsBroadcast => IwaraNewsCategoryType.broadcast,
  };

  /// 在新闻三个分类里的下标（0/1/2）；论坛返回 0。
  int get newsCategoryIndex =>
      isForum ? 0 : (index - CommunityDestination.newsUpdates.index);

  static CommunityDestination forNewsCategory(IwaraNewsCategoryType category) =>
      switch (category) {
        IwaraNewsCategoryType.newsUpdates => CommunityDestination.newsUpdates,
        IwaraNewsCategoryType.articles => CommunityDestination.newsArticles,
        IwaraNewsCategoryType.broadcast => CommunityDestination.newsBroadcast,
      };

  /// 持久化用的短名（写进 [ConfigKey.COMMUNITY_LAST_DESTINATION]）。
  String get storageKey => name;

  static CommunityDestination? fromStorageKey(Object? raw) {
    if (raw is! String) return null;
    for (final value in CommunityDestination.values) {
      if (value.storageKey == raw) return value;
    }
    return null;
  }

  /// 从 `/community?tab=...&category=...` 解析目的地。
  ///
  /// 老路径 `/forum` / `/news` 由路由层重定向成 `tab=forum` / `tab=news`
  /// 再走到这里，因此深链行为与合并前一致。
  static CommunityDestination? fromQuery({
    String? tab,
    IwaraNewsCategoryType? newsCategory,
  }) {
    if (tab == 'forum') return CommunityDestination.forum;
    if (tab == 'news') {
      return forNewsCategory(newsCategory ?? IwaraNewsCategoryType.newsUpdates);
    }
    // 没写 tab 但带了 category：按新闻处理（`/news?category=articles` 一类）
    if (newsCategory != null) return forNewsCategory(newsCategory);
    return null;
  }
}

/// 社区栏目页：论坛 + 新闻同处一个 `StatefulShellBranch`。
///
/// 本页只负责**外壳**——玻璃 header 行（头像 / 目的地下拉 / 动作胶囊）、
/// 顶部渐隐蒙层，以及两个半边之间的淡入切换。列表、分页、公告等等仍然各自
/// 留在 [ForumPage] / [NewsPage] 里，它们在嵌入模式下不再画自己的 header。
///
/// 为什么 header 归本页而不是各画各的：切半边时右侧动作胶囊要**形变**
/// （发帖键收掉、语言键长出来），而不是整组被替换掉。所以四个半边专属的
/// 按钮位在这里一次性全部声明，靠 [GlassGroupSlot] 的 `visible` 收放宽度
/// ——这是「液态玻璃形变词汇表」对按钮组增删的统一要求，见 glass_morph.dart。
///
/// 子页只往上报**影响按钮长相的那几项状态**（[ForumHeaderState] /
/// [NewsHeaderState]），不往上报 widget：这样首帧就有完整的胶囊，不必等子页
/// State 挂载完再补出来。按钮点下去时才通过各自的 `globalKey.currentState`
/// 回调进子页。
class CommunityPage extends StatefulWidget implements HomeWidgetInterface {
  static final globalKey = GlobalKey<CommunityPageState>();

  final int contentResetVersion;

  /// 深链指定的初始目的地；为 null 时恢复上次停留的位置。
  final CommunityDestination? initialDestination;

  final IwaraNewsLanguage? initialNewsLanguage;

  const CommunityPage({
    super.key,
    this.contentResetVersion = 0,
    this.initialDestination,
    this.initialNewsLanguage,
  });

  @override
  State<CommunityPage> createState() => CommunityPageState();

  @override
  void refreshCurrent() {
    globalKey.currentState?.refreshCurrent();
  }
}

class CommunityPageState extends State<CommunityPage> {
  final ConfigService _configService = Get.find<ConfigService>();
  final UserService _userService = Get.find<UserService>();

  late CommunityDestination _destination;

  final ValueNotifier<ForumHeaderState> _forumHeader =
      ValueNotifier<ForumHeaderState>(ForumHeaderState.initial);
  final ValueNotifier<NewsHeaderState> _newsHeader =
      ValueNotifier<NewsHeaderState>(NewsHeaderState.initial);

  /// 新闻 PageView 的小数页码，喂给下拉钮的 [GlassFlipLabel] 做跟手翻页。
  final ValueNotifier<double> _newsCategoryProgress = ValueNotifier<double>(0);

  /// 懒挂载：没去过的半边不建 widget，也就不发它的网络请求。
  /// 一旦去过就一直挂着（Offstage），滚动位置 / 分页状态全保留。
  final Set<int> _visitedHalves = <int>{};

  static const int _forumHalf = 0;
  static const int _newsHalf = 1;

  int get _activeHalf => _destination.isForum ? _forumHalf : _newsHalf;

  @override
  void initState() {
    super.initState();
    _destination =
        widget.initialDestination ??
        CommunityDestination.fromStorageKey(
          _configService[ConfigKey.COMMUNITY_LAST_DESTINATION],
        ) ??
        CommunityDestination.forum;
    _visitedHalves.add(_activeHalf);
    _newsCategoryProgress.value = _destination.newsCategoryIndex.toDouble();
  }

  @override
  void didUpdateWidget(covariant CommunityPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 深链再次进入（`/news?category=articles`）：跟着走过去。
    final next = widget.initialDestination;
    if (next != null && next != oldWidget.initialDestination) {
      _goTo(next);
    }
  }

  @override
  void dispose() {
    _forumHeader.dispose();
    _newsHeader.dispose();
    _newsCategoryProgress.dispose();
    super.dispose();
  }

  /// 当前是否停在论坛那一半（底栏搜索钮据此选默认搜索分段）。
  bool get isOnForum => _destination.isForum;

  /// 底栏 / 侧栏再次点击「社区」：转交给当前所在的半边。
  void refreshCurrent() {
    if (_destination.isForum) {
      ForumPage.globalKey.currentState?.tryRefreshCurrentList();
    } else {
      NewsPage.globalKey.currentState?.refreshCurrent();
    }
  }

  void _goTo(CommunityDestination destination) {
    if (destination == _destination) return;
    setState(() {
      _destination = destination;
      _visitedHalves.add(_activeHalf);
    });
    if (destination.isNews) {
      _newsCategoryProgress.value = destination.newsCategoryIndex.toDouble();
    }
    _configService.saveSetting(
      ConfigKey.COMMUNITY_LAST_DESTINATION,
      destination.storageKey,
    );
  }

  /// 新闻半边被横滑切了分类：同步目的地（下拉钮的标题跟着变）。
  void _handleNewsCategoryChanged(IwaraNewsCategoryType category) {
    final next = CommunityDestination.forNewsCategory(category);
    if (next == _destination) return;
    setState(() => _destination = next);
    _configService.saveSetting(
      ConfigKey.COMMUNITY_LAST_DESTINATION,
      next.storageKey,
    );
  }

  // ---------------------------------------------------------------- 文案

  String _destinationLabel(slang.Translations t, CommunityDestination d) =>
      switch (d) {
        CommunityDestination.forum => t.settings.forum,
        CommunityDestination.newsUpdates => t.news.newsUpdates,
        CommunityDestination.newsArticles => t.news.articles,
        CommunityDestination.newsBroadcast => t.news.broadcast,
      };

  IconData _destinationIcon(CommunityDestination d) => switch (d) {
    CommunityDestination.forum => Icons.forum,
    CommunityDestination.newsUpdates => Icons.update_rounded,
    CommunityDestination.newsArticles => Icons.article_outlined,
    CommunityDestination.newsBroadcast => Icons.campaign_outlined,
  };

  String _languageLabel(IwaraNewsLanguage language) => switch (language) {
    IwaraNewsLanguage.en => 'English',
    IwaraNewsLanguage.ja => '日本語',
    IwaraNewsLanguage.zh => '中文',
  };

  // ------------------------------------------------------------ header 行

  /// 左上角「我」圆钮：登录中显示闪烁占位，已登录显示头像（带未读红点）。
  Widget _buildAvatarButton(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() {
      final Widget inner;
      if (_userService.isLogining.value) {
        inner = KeyedSubtree(
          key: const ValueKey('avatar-shimmer'),
          child: Shimmer.fromColors(
            baseColor: colorScheme.surfaceContainerHighest,
            highlightColor: colorScheme.surface,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      } else if (_userService.hasLoadedProfile &&
          _userService.currentUser.value != null) {
        inner = KeyedSubtree(
          key: ValueKey('avatar-${_userService.currentUser.value?.id}'),
          child: IgnorePointer(
            child: AvatarWidget(
              user: _userService.currentUser.value,
              size: GlassTokens.pillHeight - 2,
            ),
          ),
        );
      } else {
        inner = KeyedSubtree(
          key: const ValueKey('avatar-placeholder'),
          child: Icon(
            Icons.account_circle,
            size: 26,
            color: colorScheme.onSurface,
          ),
        );
      }
      final count =
          _userService.notificationCount.value +
          _userService.messagesCount.value;
      return GlassSurface(
        circle: true,
        tooltip: t.common.me,
        onTap: AppService.switchGlobalDrawer,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            GlassShapeSwitcher(child: inner),
            Positioned(
              right: 2,
              top: 2,
              child: GlassAnimatedDot(visible: count > 0),
            ),
          ],
        ),
      );
    });
  }

  /// 中间的目的地下拉钮：论坛 ▾ / 更新 ▾ / 文章 ▾ / 广播 ▾。
  ///
  /// 选中新闻时标题**只显示分类名**（`📰 更新`），不写成「新闻 · 更新」——
  /// 两级前缀在 header 这个宽度上纯属浪费，图标已经把「这是新闻」说清楚了。
  ///
  /// 玻璃壳由 [GlassCapsuleMorph] 常驻提供，两侧只换无壳内容：论坛态是一枚
  /// 静态图标 + 文案，新闻态是跟着横滑进度翻页的 [GlassFlipLabel]。
  Widget _buildDestinationSwitcher(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: colorScheme.onSurface,
    );

    const newsDestinations = <CommunityDestination>[
      CommunityDestination.newsUpdates,
      CommunityDestination.newsArticles,
      CommunityDestination.newsBroadcast,
    ];

    // 标题部分：论坛态是一枚静态图标 + 文案；新闻态是跟着横滑进度逐帧
    // 翻页的 [GlassFlipLabel]（滑到一半就在换字，而不是滑完才换）。
    final Widget label = _destination.isForum
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.forum, size: 17, color: colorScheme.onSurface),
              const SizedBox(width: 6),
              Text(t.settings.forum, style: labelStyle),
            ],
          )
        : GlassFlipLabel(
            progress: _newsCategoryProgress,
            labels: [
              for (final d in newsDestinations) _destinationLabel(t, d),
            ],
            icons: [
              for (final d in newsDestinations) Icon(_destinationIcon(d)),
            ],
            iconSize: 17,
            iconGap: 6,
            style: labelStyle,
          );

    final Widget button = Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      child: PopupMenuButton<CommunityDestination>(
        initialValue: _destination,
        tooltip: _destinationLabel(t, _destination),
        onSelected: _goTo,
        position: PopupMenuPosition.under,
        // 往下挪一点，别压住玻璃胶囊本身
        offset: const Offset(0, 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        itemBuilder: (context) => <PopupMenuEntry<CommunityDestination>>[
          _destinationMenuItem(context, CommunityDestination.forum),
          const PopupMenuDivider(),
          // 三个新闻分类挂在一条分组标题下——菜单里保留「新闻」这层语义，
          // 只有胶囊上的标题省掉它。
          PopupMenuItem<CommunityDestination>(
            enabled: false,
            height: 32,
            child: Text(
              t.settings.news,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          for (final d in newsDestinations) _destinationMenuItem(context, d),
        ],
        // 无壳内容：玻璃壳统一由外层的 GlassCapsuleMorph 提供。
        // 下拉箭头必须在这一层里面，才会跟着胶囊的宽度一起伸缩。
        child: SizedBox(
          height: GlassTokens.pillHeight,
          child: Padding(
            padding: const EdgeInsets.only(left: 14, right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                label,
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // 论坛态 ↔ 新闻态是「同一只胶囊换内容」：壳只有一层、常驻不灭，宽度
    // 平滑伸缩，新旧内容在胶囊内部交接。Key 只在**半边**变化时变——按新闻
    // 分类变会让每次横滑都重跑一遍形变，把 GlassFlipLabel 的跟手翻页顶掉。
    return GlassCapsuleMorph(
      child: KeyedSubtree(
        key: ValueKey<bool>(_destination.isForum),
        child: button,
      ),
    );
  }

  PopupMenuItem<CommunityDestination> _destinationMenuItem(
    BuildContext context,
    CommunityDestination destination,
  ) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final selected = destination == _destination;
    return PopupMenuItem<CommunityDestination>(
      value: destination,
      child: Row(
        children: [
          Icon(_destinationIcon(destination), size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(_destinationLabel(t, destination))),
          if (selected) ...[
            const SizedBox(width: 8),
            Icon(Icons.check, size: 18, color: colorScheme.primary),
          ],
        ],
      ),
    );
  }

  /// 右侧动作胶囊。
  ///
  /// 两个半边**所有**的按钮位在这里一次性声明，靠 `visible` 收放宽度——
  /// 切半边时读起来是同一坨玻璃在形变（发帖键收掉、语言键长出来），
  /// 而不是整只胶囊被换掉。
  Widget _buildActionGroup(BuildContext context, {required bool isWide}) {
    final t = slang.Translations.of(context);
    final isForum = _destination.isForum;

    return ValueListenableBuilder<ForumHeaderState>(
      valueListenable: _forumHeader,
      builder: (context, forumState, _) {
        return ValueListenableBuilder<NewsHeaderState>(
          valueListenable: _newsHeader,
          builder: (context, newsState, _) {
            return GlassButtonGroup(
              children: [
                // 论坛：搜索（宽屏才直出，窄屏收进 ⋮）
                GlassGroupSlot(
                  visible: isForum && isWide,
                  child: GlassIconButton(
                    icon: const Icon(Icons.search),
                    tooltip: t.common.search,
                    onPressed: _openForumSearch,
                  ),
                ),
                // 论坛：瀑布流 / 分页（只作用于「最近」列表）
                GlassGroupSlot(
                  visible: isForum && forumState.showPaginationToggle,
                  child: GlassIconButton(
                    icon: Icon(
                      forumState.isPaginated
                          ? Icons.view_stream
                          : Icons.view_module,
                    ),
                    tooltip: forumState.isPaginated
                        ? t.common.pagination.waterfall
                        : t.common.pagination.pagination,
                    onPressed: () => ForumPage.globalKey.currentState
                        ?.togglePaginationMode(),
                  ),
                ),
                // 论坛：发帖
                GlassGroupSlot(
                  visible: isForum,
                  child: GlassIconButton(
                    icon: const Icon(Icons.add),
                    tooltip: t.forum.createThread,
                    onPressed: () =>
                        ForumPage.globalKey.currentState?.showPostDialog(),
                  ),
                ),
                // 新闻：语言
                GlassGroupSlot(
                  visible: !isForum,
                  child: _buildNewsLanguageButton(context, newsState),
                ),
                // 「更多」：只剩一条时会自动变成那枚动作本身
                GlassGroupOverflowMenuButton(
                  actions: isForum
                      ? [
                          if (!isWide)
                            GlassMenuAction(
                              icon: Icons.search,
                              label: t.common.search,
                              onSelected: _openForumSearch,
                            ),
                          GlassMenuAction(
                            icon: Icons.refresh,
                            label: t.common.refresh,
                            onSelected: () async =>
                                ForumPage.globalKey.currentState?.refreshAll(),
                            showsLoading: true,
                          ),
                        ]
                      : [
                          GlassMenuAction(
                            icon: Icons.refresh_rounded,
                            label: t.common.refresh,
                            onSelected: () async => NewsPage
                                .globalKey
                                .currentState
                                ?.refreshCurrentCategory(),
                            showsLoading: true,
                          ),
                          GlassMenuAction(
                            icon: Icons.vertical_align_top,
                            label: t.common.scrollToTop,
                            onSelected: () => NewsPage.globalKey.currentState
                                ?.scrollCurrentCategoryToTop(),
                          ),
                        ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildNewsLanguageButton(BuildContext context, NewsHeaderState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final current = state.language ?? IwaraNewsLanguage.en;
    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      child: PopupMenuButton<IwaraNewsLanguage>(
        initialValue: current,
        tooltip: _languageLabel(current),
        onSelected: (value) =>
            NewsPage.globalKey.currentState?.setLanguage(value),
        position: PopupMenuPosition.under,
        offset: const Offset(0, 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        itemBuilder: (context) => [
          for (final language in IwaraNewsLanguage.values)
            PopupMenuItem<IwaraNewsLanguage>(
              value: language,
              child: Row(
                children: [
                  const Icon(Icons.translate_rounded, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_languageLabel(language))),
                  if (language == current) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.check, size: 18, color: colorScheme.primary),
                  ],
                ],
              ),
            ),
        ],
        child: SizedBox(
          width: GlassTokens.groupIconButtonSize,
          height: GlassTokens.groupIconButtonSize,
          child: Icon(
            Icons.translate_rounded,
            size: GlassTokens.iconSize,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  void _openForumSearch() {
    ForumPage.globalKey.currentState?.openSearchDialog();
  }

  // ------------------------------------------------------------------ 构建

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;
    final bool isWide = MediaQuery.sizeOf(context).width > 600;

    return Scaffold(
      body: GlassHeaderOverlay(
        headerExtent: headerExtent,
        headerTop: statusBarHeight,
        solidExtent: statusBarHeight,
        body: FadeBranchContainer(
          currentIndex: _activeHalf,
          children: [_buildForumHalf(), _buildNewsHalf()],
        ),
        header: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildAvatarButton(context),
              const SizedBox(width: 8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  // 玻璃壳由 _buildDestinationSwitcher 里的 GlassCapsuleMorph
                  // 自带，这里不能再套 GlassSurface（会成壳中壳）。
                  child: _buildDestinationSwitcher(context),
                ),
              ),
              const SizedBox(width: 8),
              _buildActionGroup(context, isWide: isWide),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForumHalf() {
    if (!_visitedHalves.contains(_forumHalf)) {
      return const SizedBox.shrink();
    }
    return ForumPage(
      key: ForumPage.globalKey,
      contentResetVersion: widget.contentResetVersion,
      headerState: _forumHeader,
    );
  }

  Widget _buildNewsHalf() {
    if (!_visitedHalves.contains(_newsHalf)) {
      return const SizedBox.shrink();
    }
    return NewsPage(
      key: NewsPage.globalKey,
      contentResetVersion: widget.contentResetVersion,
      initialCategory:
          _destination.newsCategory ?? IwaraNewsCategoryType.newsUpdates,
      initialLanguage: widget.initialNewsLanguage,
      headerState: _newsHeader,
      categoryProgress: _newsCategoryProgress,
      onCategoryChanged: _handleNewsCategoryChanged,
    );
  }
}
