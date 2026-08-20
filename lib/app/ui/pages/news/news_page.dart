import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:go_router/go_router.dart';
import 'package:i_iwara/app/models/iwara_news.model.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/services/iwara_news_service.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/home_page.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/common_utils.dart';
import 'package:shimmer/shimmer.dart';

class NewsPage extends StatefulWidget implements HomeWidgetInterface {
  static final globalKey = GlobalKey<_NewsPageState>();

  final int contentResetVersion;
  final IwaraNewsCategoryType initialCategory;
  final IwaraNewsLanguage? initialLanguage;

  const NewsPage({
    super.key,
    this.contentResetVersion = 0,
    this.initialCategory = IwaraNewsCategoryType.newsUpdates,
    this.initialLanguage,
  });

  @override
  State<NewsPage> createState() => _NewsPageState();

  @override
  void refreshCurrent() {
    globalKey.currentState?.refreshCurrent();
  }
}

class _NewsPageState extends State<NewsPage>
    with SingleTickerProviderStateMixin {
  static const double _backToTopOffset = 320;

  final IwaraNewsService _newsService = Get.find<IwaraNewsService>();
  final Map<IwaraNewsCategoryType, _NewsFeedState> _feeds = {
    for (final type in IwaraNewsCategoryType.values)
      type: _NewsFeedState.initial(),
  };
  final Map<IwaraNewsCategoryType, int> _feedRequestVersions = {
    for (final type in IwaraNewsCategoryType.values) type: 0,
  };
  late final Map<IwaraNewsCategoryType, ScrollController>
  _feedScrollControllers;
  final Map<IwaraNewsCategoryType, bool> _showBackToTopByCategory = {
    for (final type in IwaraNewsCategoryType.values) type: false,
  };

  late final PageController _pageController;
  late final TabController _tabController;
  late IwaraNewsCategoryType _selectedCategory;
  IwaraNewsLanguage? _selectedLanguage;

  /// PageView 的小数页码，喂给分段胶囊做跟手高亮。
  late final ValueNotifier<double> _pageProgress;

  _NewsFeedState get _currentFeed => _feeds[_selectedCategory]!;
  bool get _showBackToTop =>
      _showBackToTopByCategory[_selectedCategory] == true &&
      _currentFeed.items.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _selectedLanguage = widget.initialLanguage;
    _feedScrollControllers = {
      for (final type in IwaraNewsCategoryType.values)
        type: ScrollController()..addListener(() => _handleFeedScroll(type)),
    };
    _pageController = PageController(initialPage: _selectedCategory.index);
    _pageProgress = ValueNotifier<double>(_selectedCategory.index.toDouble());
    _pageController.addListener(_syncPageProgress);
    _tabController = TabController(
      length: IwaraNewsCategoryType.values.length,
      vsync: this,
      initialIndex: _selectedCategory.index,
    );
  }

  void _syncPageProgress() {
    if (!_pageController.hasClients) return;
    final page = _pageController.page;
    if (page != null) _pageProgress.value = page;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLanguage ??= _newsService.resolveLanguage(
      slang.LocaleSettings.currentLocale.languageCode,
    );
    _ensureCategoryLoaded(_selectedCategory);
  }

  @override
  void didUpdateWidget(covariant NewsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nextLanguage = widget.initialLanguage ?? _selectedLanguage;
    final languageChanged = nextLanguage != _selectedLanguage;
    final categoryChanged = oldWidget.initialCategory != widget.initialCategory;

    if (oldWidget.initialLanguage != widget.initialLanguage ||
        categoryChanged) {
      setState(() {
        _selectedCategory = widget.initialCategory;
        _selectedLanguage = nextLanguage;
        if (languageChanged) {
          _invalidateAllFeeds();
        }
      });
      _tabController.index = _selectedCategory.index;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_selectedCategory.index);
      }
      if (languageChanged) {
        _refreshCategory(_selectedCategory);
      } else {
        _ensureCategoryLoaded(_selectedCategory);
      }
    }

    if (oldWidget.contentResetVersion != widget.contentResetVersion) {
      _refreshCategory(_selectedCategory);
    }
  }

  @override
  void dispose() {
    for (final controller in _feedScrollControllers.values) {
      controller.dispose();
    }
    _tabController.dispose();
    _pageController.removeListener(_syncPageProgress);
    _pageController.dispose();
    _pageProgress.dispose();
    super.dispose();
  }

  Future<void> refreshCurrent() async {
    if (!mounted) return;
    // 当前分类回到顶部（不阻塞数据刷新）
    unawaited(_scrollCurrentCategoryToTop());
    // 作废所有分类的数据：当前分类立即重载，其他已访问分类在下次切换时重新拉取
    setState(_invalidateAllFeeds);
    await _refreshCategory(_selectedCategory);
  }

  Future<void> _handleLanguageChange(IwaraNewsLanguage language) async {
    if (_selectedLanguage == language) return;
    setState(() {
      _selectedLanguage = language;
      _invalidateAllFeeds();
    });
    await _refreshCategory(_selectedCategory);
  }

  void _handleFeedScroll(IwaraNewsCategoryType type) {
    final controller = _feedScrollControllers[type];
    if (controller == null || !controller.hasClients) return;

    final shouldShow = controller.offset >= _backToTopOffset;
    if (_showBackToTopByCategory[type] == shouldShow || !mounted) {
      return;
    }

    setState(() {
      _showBackToTopByCategory[type] = shouldShow;
    });
  }

  Future<void> _scrollCurrentCategoryToTop() async {
    final controller = _feedScrollControllers[_selectedCategory];
    if (controller == null || !controller.hasClients) return;

    await controller.animateTo(
      0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _ensureCategoryLoaded(IwaraNewsCategoryType type) async {
    final feed = _feeds[type]!;
    if (feed.items.isEmpty && !feed.isLoading) {
      await _refreshCategory(type);
    }
  }

  Future<void> _refreshCategory(IwaraNewsCategoryType type) async {
    final feed = _feeds[type]!;
    final requestVersion = (_feedRequestVersions[type] ?? 0) + 1;
    _feedRequestVersions[type] = requestVersion;

    setState(() {
      feed
        ..isLoading = true
        ..loadMoreError = null;
      if (feed.items.isEmpty) {
        feed.error = null;
      }
    });

    try {
      final items = await _newsService.fetchCategoryPosts(
        type,
        languageCode: _languageCode(_selectedLanguage ?? IwaraNewsLanguage.en),
        page: 1,
      );
      if (!mounted || requestVersion != _feedRequestVersions[type]) return;

      final deduplicatedItems = _deduplicateNewsItems(items);
      setState(() {
        feed
          ..items = deduplicatedItems
          ..page = 1
          ..hasMore =
              deduplicatedItems.length >= IwaraNewsService.defaultPerPage
          ..error = null
          ..loadMoreError = null
          ..isLoading = false
          ..isLoadingMore = false;
      });
    } catch (error) {
      if (!mounted || requestVersion != _feedRequestVersions[type]) return;
      setState(() {
        feed
          ..error = CommonUtils.parseExceptionMessage(error)
          ..isLoading = false
          ..isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreCategory(IwaraNewsCategoryType type) async {
    final feed = _feeds[type]!;
    if (feed.isLoading || feed.isLoadingMore || !feed.hasMore) {
      return;
    }

    final requestVersion = (_feedRequestVersions[type] ?? 0) + 1;
    _feedRequestVersions[type] = requestVersion;

    setState(() {
      feed
        ..isLoadingMore = true
        ..loadMoreError = null;
    });

    try {
      final nextPage = feed.page + 1;
      final items = await _newsService.fetchCategoryPosts(
        type,
        languageCode: _languageCode(_selectedLanguage ?? IwaraNewsLanguage.en),
        page: nextPage,
      );
      if (!mounted || requestVersion != _feedRequestVersions[type]) return;

      final mergedItems = _deduplicateNewsItems([...feed.items, ...items]);
      setState(() {
        feed.items = mergedItems;
        feed
          ..page = nextPage
          ..hasMore = items.length >= IwaraNewsService.defaultPerPage
          ..isLoadingMore = false;
      });
    } catch (error) {
      if (!mounted || requestVersion != _feedRequestVersions[type]) return;
      setState(() {
        feed
          ..isLoadingMore = false
          ..loadMoreError = CommonUtils.parseExceptionMessage(error);
      });
    }
  }

  void _invalidateAllFeeds() {
    for (final entry in _feeds.entries) {
      _feedRequestVersions[entry.key] = _feedRequestVersions[entry.key]! + 1;
      final feed = entry.value;
      feed
        ..items = []
        ..page = 0
        ..isLoading = false
        ..isLoadingMore = false
        ..hasMore = true
        ..error = null
        ..loadMoreError = null;
    }
  }

  List<IwaraNewsListItem> _deduplicateNewsItems(List<IwaraNewsListItem> items) {
    final uniqueItems = <IwaraNewsListItem>[];
    final seenIds = <int>{};
    for (final item in items) {
      if (seenIds.add(item.id)) {
        uniqueItems.add(item);
      }
    }
    return uniqueItems;
  }

  String _languageCode(IwaraNewsLanguage language) {
    switch (language) {
      case IwaraNewsLanguage.en:
        return 'en';
      case IwaraNewsLanguage.ja:
        return 'ja';
      case IwaraNewsLanguage.zh:
        return 'zh';
    }
  }

  String _languageLabel(IwaraNewsLanguage language) {
    switch (language) {
      case IwaraNewsLanguage.en:
        return 'English';
      case IwaraNewsLanguage.ja:
        return '日本語';
      case IwaraNewsLanguage.zh:
        return '简体中文';
    }
  }

  String _categoryLabel(slang.Translations t, IwaraNewsCategoryType category) {
    switch (category) {
      case IwaraNewsCategoryType.newsUpdates:
        return t.news.newsUpdates;
      case IwaraNewsCategoryType.articles:
        return t.news.articles;
      case IwaraNewsCategoryType.broadcast:
        return t.news.broadcast;
    }
  }

  IconData _categoryIcon(IwaraNewsCategoryType category) {
    switch (category) {
      case IwaraNewsCategoryType.newsUpdates:
        return Icons.update_rounded;
      case IwaraNewsCategoryType.articles:
        return Icons.article_outlined;
      case IwaraNewsCategoryType.broadcast:
        return Icons.campaign_outlined;
    }
  }

  Future<void> _switchCategory(IwaraNewsCategoryType category) async {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
    });
    if (_tabController.index != category.index) {
      _tabController.animateTo(category.index);
    }
    if (_pageController.hasClients) {
      await _pageController.animateToPage(
        category.index,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
    await _ensureCategoryLoaded(category);
  }

  /// 左上角「我」圆钮：已登录显示头像（铺满圆钮，带未读红点），未登录显示占位图标。
  Widget _buildAvatarButton(BuildContext context) {
    final t = slang.Translations.of(context);
    final userService = Get.find<UserService>();
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() {
      final user = userService.hasLoadedProfile
          ? userService.currentUser.value
          : null;
      final count =
          userService.notificationCount.value + userService.messagesCount.value;
      final Widget inner = user != null
          ? KeyedSubtree(
              key: ValueKey('avatar-${user.id}'),
              child: IgnorePointer(
                child: AvatarWidget(
                  user: user,
                  size: GlassTokens.pillHeight - 2,
                ),
              ),
            )
          : KeyedSubtree(
              key: const ValueKey('avatar-placeholder'),
              child: Icon(
                Icons.account_circle,
                size: 26,
                color: colorScheme.onSurface,
              ),
            );
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

  static const String _menuActionRefresh = 'refresh';
  static const String _menuActionScrollTop = 'scroll_top';

  /// 右侧动作胶囊：语言 · 更多（刷新 / 回到顶部）。
  Widget _buildActionGroup(BuildContext context) {
    final t = slang.Translations.of(context);
    return GlassButtonGroup(
      children: [
        _NewsSelectButton<IwaraNewsLanguage>(
          icon: Icons.translate_rounded,
          label: _languageLabel(_selectedLanguage ?? IwaraNewsLanguage.en),
          showLabel: false,
          values: IwaraNewsLanguage.values,
          selectedValue: _selectedLanguage ?? IwaraNewsLanguage.en,
          itemIconBuilder: (_) => Icons.translate_rounded,
          itemLabelBuilder: _languageLabel,
          onSelected: _handleLanguageChange,
        ),
        SizedBox(
          width: GlassTokens.groupIconButtonSize,
          height: GlassTokens.groupIconButtonSize,
          child: PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.more_vert, size: GlassTokens.iconSize),
            position: PopupMenuPosition.under,
            // 往下挪一点，别压住玻璃胶囊本身
            offset: const Offset(0, 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              switch (value) {
                case _menuActionRefresh:
                  if (!_currentFeed.isLoading) {
                    _refreshCategory(_selectedCategory);
                  }
                  break;
                case _menuActionScrollTop:
                  _scrollCurrentCategoryToTop();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: _menuActionRefresh,
                enabled: !_currentFeed.isLoading,
                child: Row(
                  children: [
                    const Icon(Icons.refresh_rounded),
                    const SizedBox(width: 12),
                    Text(t.common.refresh),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: _menuActionScrollTop,
                child: Row(
                  children: [
                    const Icon(Icons.vertical_align_top),
                    const SizedBox(width: 12),
                    Text(t.common.scrollToTop),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 滚过一段后出现在右下角的「回到顶部」浮钮。
  Widget _buildScrollToTopFab(BuildContext context) {
    final t = slang.Translations.of(context);
    final visible = _showBackToTop;
    return Positioned(
      // 移动端底栏可见时与搜索圆钮中心共轴；宽屏（rail 布局）用普通右边距
      right: isFloatingBarInsetActive(context)
          ? GlassTokens.floatingActionCoAxisRight(GlassTokens.pillHeight)
          : 16,
      bottom: MediaQuery.paddingOf(context).bottom + 16,
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedSlide(
          duration: GlassTokens.motionDuration,
          curve: GlassTokens.motionCurve,
          offset: visible ? Offset.zero : const Offset(0, 0.4),
          child: AnimatedOpacity(
            duration: GlassTokens.motionDuration,
            opacity: visible ? 1 : 0,
            child: GlassIconButton(
              standalone: true,
              icon: const Icon(Icons.vertical_align_top),
              tooltip: t.common.scrollToTop,
              onPressed: _scrollCurrentCategoryToTop,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = slang.Translations.of(context);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double headerRowHeight = GlassTokens.headerRowHeight;
    final double headerExtent = statusBarHeight + headerRowHeight;

    final categoryItems = [
      for (final category in IwaraNewsCategoryType.values)
        GlassSegmentItem(
          label: _categoryLabel(t, category),
          icon: Icon(_categoryIcon(category)),
        ),
    ];

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return GlassHeaderOverlay(
            headerExtent: headerExtent,
            headerTop: statusBarHeight,
            solidExtent: statusBarHeight,
            body: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.surfaceContainerLowest,
                    theme.colorScheme.surface,
                  ],
                ),
              ),
              child: PageView.builder(
                controller: _pageController,
                itemCount: IwaraNewsCategoryType.values.length,
                onPageChanged: (index) {
                  final category = IwaraNewsCategoryType.values[index];
                  if (_tabController.index != index) {
                    _tabController.animateTo(index);
                  }
                  if (_selectedCategory != category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  }
                  _ensureCategoryLoaded(category);
                },
                itemBuilder: (context, index) {
                  final category = IwaraNewsCategoryType.values[index];
                  return _NewsCategoryList(
                    feed: _feeds[category]!,
                    scrollController: _feedScrollControllers[category]!,
                    paddingTop: headerExtent,
                    onRefresh: () => _refreshCategory(category),
                    onLoadMore: () => _loadMoreCategory(category),
                    onTapItem: (item) => context.push(
                      '/news/${item.id}',
                      extra: NewsDetailExtra(
                        postId: item.id,
                        postUrl: item.link,
                        title: item.title,
                        excerpt: item.excerpt,
                        publishedAt: item.publishedAt,
                        updatedAt: item.updatedAt,
                        language: item.language,
                        featuredImageUrl: item.featuredImageUrl,
                        heroTag:
                            'news-card-'
                            '${item.language.name}-'
                            '${item.categoryType.name}-'
                            '${item.id}',
                      ),
                    ),
                  );
                },
              ),
            ),
            header: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildAvatarButton(context),
                  const SizedBox(width: 8),
                  // 「够不够摆下分段胶囊」读 Expanded 实际分到的宽度，不靠
                  // 公式预测右侧胶囊有几个键——按钮收放途中公式差着一整个
                  // 动画的时长，会把分段胶囊塞进还没让出的空间里当场裁掉。
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, centerConstraints) {
                        // 平铺至少要能完整露出两个分类，否则让位给下拉钮
                        final bool useSegmented =
                            centerConstraints.maxWidth >=
                            GlassSegmentedControl.minWidthFor(
                              context,
                              categoryItems,
                            );
                        return Align(
                          alignment: Alignment.centerLeft,
                          // 玻璃壳由 GlassCapsuleMorph 常驻提供，两侧只换
                          // 无壳内容——胶囊平滑伸缩，阴影/圆角全程完整。
                          child: GlassCapsuleMorph(
                            child: useSegmented
                                ? GlassSegmentedControl(
                                    key: const ValueKey('segmented'),
                                    flat: true,
                                    selectedIndex: _selectedCategory.index,
                                    progress: _pageProgress,
                                    onChanged: (i) => _switchCategory(
                                      IwaraNewsCategoryType.values[i],
                                    ),
                                    items: categoryItems,
                                  )
                                : KeyedSubtree(
                                    key: const ValueKey('dropdown'),
                                    child:
                                        _NewsSelectButton<
                                          IwaraNewsCategoryType
                                        >(
                                          icon: _categoryIcon(
                                            _selectedCategory,
                                          ),
                                          label: _categoryLabel(
                                            t,
                                            _selectedCategory,
                                          ),
                                          values: IwaraNewsCategoryType.values,
                                          selectedValue: _selectedCategory,
                                          itemIconBuilder: _categoryIcon,
                                          itemLabelBuilder: (category) =>
                                              _categoryLabel(t, category),
                                          onSelected: _switchCategory,
                                          progress: _pageProgress,
                                        ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildActionGroup(context),
                ],
              ),
            ),
            extra: [_buildScrollToTopFab(context)],
          );
        },
      ),
    );
  }
}

class _NewsSelectButton<T> extends StatelessWidget {
  const _NewsSelectButton({
    required this.icon,
    required this.label,
    this.showLabel = true,
    required this.values,
    required this.selectedValue,
    required this.itemIconBuilder,
    required this.itemLabelBuilder,
    required this.onSelected,
    this.progress,
  });

  final IconData icon;
  final String label;
  final bool showLabel;
  final List<T> values;
  final T selectedValue;
  final IconData Function(T value) itemIconBuilder;
  final String Function(T value) itemLabelBuilder;
  final Future<void> Function(T value) onSelected;

  /// PageView 的小数页码。传了就让钮里的「图标 + 文案」跟着横滑进度翻页
  /// （见 [GlassFlipLabel]），而不是等滑完才换字。
  final ValueListenable<double>? progress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Theme(
      data: Theme.of(context).copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      child: PopupMenuButton<T>(
        initialValue: selectedValue,
        tooltip: label,
        onSelected: (value) {
          onSelected(value);
        },
        position: PopupMenuPosition.under,
        // 往下挪一点，别压住玻璃胶囊本身
        offset: const Offset(0, 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        itemBuilder: (context) => [
          for (final item in values)
            PopupMenuItem<T>(
              value: item,
              child: Row(
                children: [
                  Icon(itemIconBuilder(item), size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(itemLabelBuilder(item))),
                  if (item == selectedValue) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.check, size: 18, color: colorScheme.primary),
                  ],
                ],
              ),
            ),
        ],
        // 无标签：作为玻璃胶囊组里的一个 40×40 图标位；有标签：无壳内容行
        //（玻璃壳由外层 GlassCapsuleMorph 提供）
        child: showLabel
            ? SizedBox(
                height: GlassTokens.pillHeight,
                child: Padding(
                  padding: const EdgeInsets.only(left: 14, right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (progress != null)
                        GlassFlipLabel(
                          progress: progress!,
                          labels: [
                            for (final value in values) itemLabelBuilder(value),
                          ],
                          icons: [
                            for (final value in values)
                              Icon(itemIconBuilder(value)),
                          ],
                          iconGap: 6,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        )
                      else ...[
                        Icon(icon, size: 16, color: colorScheme.onSurface),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        color: colorScheme.onSurface,
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox(
                width: GlassTokens.groupIconButtonSize,
                height: GlassTokens.groupIconButtonSize,
                child: Icon(
                  icon,
                  size: GlassTokens.iconSize,
                  color: colorScheme.onSurface,
                ),
              ),
      ),
    );
  }
}

class _NewsCategoryList extends StatelessWidget {
  const _NewsCategoryList({
    required this.feed,
    required this.scrollController,
    required this.paddingTop,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onTapItem,
  });

  final _NewsFeedState feed;
  final ScrollController scrollController;
  final double paddingTop;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final void Function(IwaraNewsListItem item) onTapItem;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    if (feed.isLoading && feed.items.isEmpty) {
      return _NewsFeedSkeleton(paddingTop: paddingTop);
    }

    if (feed.error != null && feed.items.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: paddingTop),
        child: MyEmptyWidget(message: feed.error!, onRefresh: onRefresh),
      );
    }

    if (feed.items.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: paddingTop),
        child: MyEmptyWidget(message: t.common.noData, onRefresh: onRefresh),
      );
    }

    final showFooter = feed.isLoadingMore || feed.loadMoreError != null;

    return RefreshIndicator(
      edgeOffset: paddingTop,
      onRefresh: onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < 420) {
            onLoadMore();
          }
          return false;
        },
        child: ListView.separated(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          // 底部额外让出安全区（窄屏时 Shell 已把浮动底栏高度加进 padding.bottom）
          padding: EdgeInsets.fromLTRB(
            16,
            paddingTop + 4,
            16,
            28 + MediaQuery.of(context).padding.bottom,
          ),
          itemCount: feed.items.length + (showFooter ? 1 : 0),
          separatorBuilder: (context, index) =>
              SizedBox(height: index == 0 ? 16 : 12),
          itemBuilder: (context, index) {
            if (index >= feed.items.length) {
              return Align(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: _NewsLoadMoreFooter(
                    isLoading: feed.isLoadingMore,
                    errorMessage: feed.loadMoreError,
                    onRetry: onLoadMore,
                  ),
                ),
              );
            }

            final item = feed.items[index];
            final prominence = index == 0
                ? _NewsCardProminence.featured
                : _NewsCardProminence.standard;

            return Align(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: _NewsListCard(
                  item: item,
                  prominence: prominence,
                  onTap: () => onTapItem(item),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NewsLoadMoreFooter extends StatelessWidget {
  const _NewsLoadMoreFooter({
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                errorMessage!,
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: onRetry,
              child: Text(
                slang.t.common.retry,
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      );
    }

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return const SizedBox.shrink();
  }
}

enum _NewsCardProminence { featured, standard }

class _NewsListCard extends StatefulWidget {
  const _NewsListCard({
    required this.item,
    required this.prominence,
    required this.onTap,
  });

  final IwaraNewsListItem item;
  final _NewsCardProminence prominence;
  final VoidCallback onTap;

  @override
  State<_NewsListCard> createState() => _NewsListCardState();
}

class _NewsListCardState extends State<_NewsListCard> {
  static const Duration _hoverAnimationDuration = Duration(milliseconds: 200);

  bool _isHovering = false;

  bool get _isFeatured => widget.prominence == _NewsCardProminence.featured;

  String get _heroTag =>
      'news-card-'
      '${widget.item.language.name}-'
      '${widget.item.categoryType.name}-'
      '${widget.item.id}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasThumbnail =
        widget.item.featuredImageUrl != null &&
        widget.item.featuredImageUrl!.trim().isNotEmpty;
    final enableHover = _supportsHover();
    final showHoverState = enableHover && _isHovering;
    final animationDuration =
        WidgetsBinding
            .instance
            .platformDispatcher
            .accessibilityFeatures
            .disableAnimations
        ? Duration.zero
        : _hoverAnimationDuration;
    final borderRadius = BorderRadius.circular(_isFeatured ? 28 : 24);

    return RepaintBoundary(
      child: Semantics(
        button: true,
        label: widget.item.title,
        child: MouseRegion(
          onEnter: enableHover
              ? (_) => setState(() => _isHovering = true)
              : null,
          onExit: enableHover
              ? (_) => setState(() => _isHovering = false)
              : null,
          child: AnimatedContainer(
            duration: animationDuration,
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(
              0,
              showHoverState ? -2.0 : 0.0,
              0,
            ),
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              color: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: borderRadius,
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(
                    alpha: showHoverState ? 0.62 : 0.4,
                  ),
                ),
              ),
              child: InkWell(
                onTap: widget.onTap,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final useHorizontalLayout =
                        hasThumbnail &&
                        constraints.maxWidth >= (_isFeatured ? 760 : 700);

                    return Padding(
                      padding: EdgeInsets.all(_isFeatured ? 20 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: _heroTag,
                            child: Material(
                              color: Colors.transparent,
                              child: _NewsCardHeroContent(
                                item: widget.item,
                                featured: _isFeatured,
                                horizontal: useHorizontalLayout,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _NewsCardSupplementaryContent(
                            item: widget.item,
                            featured: _isFeatured,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _supportsHover() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return false;
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return true;
    }
  }
}

class _NewsCardTextContent extends StatelessWidget {
  const _NewsCardTextContent({
    required this.item,
    required this.featured,
    this.showExcerpt = true,
  });

  final IwaraNewsListItem item;
  final bool featured;
  final bool showExcerpt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title.trim().isEmpty ? slang.t.common.noTitle : item.title,
          maxLines: featured ? 3 : 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: featured ? 16 : 14,
            fontWeight: FontWeight.w700,
            height: featured ? 1.25 : 1.22,
            color: theme.textTheme.titleMedium?.color,
          ),
        ),
        if (showExcerpt && item.excerpt.trim().isNotEmpty) ...[
          SizedBox(height: featured ? 12 : 10),
          Text(
            item.excerpt,
            maxLines: featured ? 4 : 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: featured ? 14 : 13,
              height: 1.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _NewsCardHeroContent extends StatelessWidget {
  const _NewsCardHeroContent({
    required this.item,
    required this.featured,
    required this.horizontal,
  });

  final IwaraNewsListItem item;
  final bool featured;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final textContent = _NewsCardTextContent(
      item: item,
      featured: featured,
      showExcerpt: false,
    );

    if (horizontal) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: featured ? 12 : 10, child: textContent),
          const SizedBox(width: 18),
          _NewsCardThumbnail(
            imageUrl: item.featuredImageUrl,
            featured: featured,
            horizontal: true,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.featuredImageUrl != null &&
            item.featuredImageUrl!.trim().isNotEmpty) ...[
          _NewsCardThumbnail(
            imageUrl: item.featuredImageUrl,
            featured: featured,
            horizontal: false,
          ),
          SizedBox(height: featured ? 18 : 14),
        ],
        textContent,
      ],
    );
  }
}

class _NewsCardSupplementaryContent extends StatelessWidget {
  const _NewsCardSupplementaryContent({
    required this.item,
    required this.featured,
  });

  final IwaraNewsListItem item;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.excerpt.trim().isNotEmpty) ...[
          Text(
            item.excerpt,
            maxLines: featured ? 4 : 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: featured ? 14 : 13,
              height: 1.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: featured ? 16 : 14),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _NewsMetaPill(
                    icon: Icons.schedule_rounded,
                    label: CommonUtils.formatFriendlyTimestamp(
                      item.publishedAt,
                    ),
                  ),
                  _NewsMetaPill(
                    icon: Icons.update_rounded,
                    label: CommonUtils.formatFriendlyTimestamp(item.updatedAt),
                  ),
                  _NewsMetaPill(
                    icon: Icons.article_outlined,
                    label: item.id.toString(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Icon(
                Icons.arrow_outward_rounded,
                size: featured ? 22 : 20,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NewsCardThumbnail extends StatelessWidget {
  const _NewsCardThumbnail({
    required this.imageUrl,
    required this.featured,
    required this.horizontal,
  });

  final String? imageUrl;
  final bool featured;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final borderRadius = BorderRadius.circular(featured ? 22 : 18);
    final image = ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.broken_image_outlined),
        ),
      ),
    );

    if (horizontal) {
      return SizedBox(
        width: featured ? 320 : 240,
        child: AspectRatio(
          aspectRatio: featured ? 4 / 3 : 16 / 11,
          child: image,
        ),
      );
    }

    return AspectRatio(aspectRatio: featured ? 16 / 9 : 16 / 10, child: image);
  }
}

class _NewsMetaPill extends StatelessWidget {
  const _NewsMetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsFeedSkeleton extends StatelessWidget {
  const _NewsFeedSkeleton({required this.paddingTop});

  final double paddingTop;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16,
        paddingTop + 4,
        16,
        28 + MediaQuery.of(context).padding.bottom,
      ),
      itemCount: 5,
      separatorBuilder: (context, index) =>
          SizedBox(height: index == 0 ? 16 : 12),
      itemBuilder: (context, index) => Align(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: _NewsSkeletonCard(featured: index == 0),
        ),
      ),
    );
  }
}

class _NewsSkeletonCard extends StatelessWidget {
  const _NewsSkeletonCard({required this.featured});

  final bool featured;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(featured ? 24 : 20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(featured ? 18 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NewsSkeletonHeroContent(featured: featured),
            SizedBox(height: featured ? 12 : 10),
            _NewsSkeletonSupplementaryContent(featured: featured),
          ],
        ),
      ),
    );
  }
}

class _NewsSkeletonHeroContent extends StatelessWidget {
  const _NewsSkeletonHeroContent({required this.featured});

  final bool featured;

  @override
  Widget build(BuildContext context) {
    final titleHeight = featured ? 17.0 : 15.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _NewsSkeletonLine(
          widthFactor: featured ? 0.88 : 0.82,
          height: titleHeight,
          radius: 8,
        ),
        const SizedBox(height: 6),
        _NewsSkeletonLine(
          widthFactor: featured ? 0.62 : 0.54,
          height: titleHeight,
          radius: 8,
        ),
      ],
    );
  }
}

class _NewsSkeletonSupplementaryContent extends StatelessWidget {
  const _NewsSkeletonSupplementaryContent({required this.featured});

  final bool featured;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _NewsSkeletonLine(
          widthFactor: featured ? 0.9 : 0.72,
          height: 12,
          radius: 8,
        ),
        const SizedBox(height: 6),
        _NewsSkeletonLine(
          widthFactor: featured ? 0.58 : 0.42,
          height: 12,
          radius: 8,
        ),
        SizedBox(height: featured ? 12 : 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _NewsSkeletonBlock(width: 108, height: 22, radius: 999),
                  _NewsSkeletonBlock(width: 118, height: 22, radius: 999),
                  _NewsSkeletonBlock(width: 64, height: 22, radius: 999),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: _NewsSkeletonBlock(width: 18, height: 18, radius: 999),
            ),
          ],
        ),
      ],
    );
  }
}

class _NewsSkeletonLine extends StatelessWidget {
  const _NewsSkeletonLine({
    required this.widthFactor,
    required this.height,
    this.radius = 999,
  });

  final double widthFactor;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: _NewsSkeletonBlock(
        width: double.infinity,
        height: height,
        radius: radius,
      ),
    );
  }
}

class _NewsSkeletonBlock extends StatelessWidget {
  const _NewsSkeletonBlock({this.width, required this.height, this.radius = 8});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return _NewsSkeletonShimmer(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _NewsSkeletonShimmer extends StatelessWidget {
  const _NewsSkeletonShimmer({
    this.width,
    this.height,
    required this.decoration,
  });

  final double? width;
  final double? height;
  final BoxDecoration decoration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disableAnimations = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;

    final block = Container(
      width: width,
      height: height,
      decoration: decoration,
    );

    if (disableAnimations) {
      return block;
    }

    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainerHighest,
      highlightColor: theme.colorScheme.surfaceContainerLow,
      child: block,
    );
  }
}

class _NewsFeedState {
  _NewsFeedState({
    required this.items,
    required this.page,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.error,
    required this.loadMoreError,
  });

  factory _NewsFeedState.initial() => _NewsFeedState(
    items: [],
    page: 0,
    isLoading: false,
    isLoadingMore: false,
    hasMore: true,
    error: null,
    loadMoreError: null,
  );

  List<IwaraNewsListItem> items;
  int page;
  bool isLoading;
  bool isLoadingMore;
  bool hasMore;
  String? error;
  String? loadMoreError;
}
