import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/oreno3d_localization_service.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/ui/widgets/oreno3d_tag_picker_dialog.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/widgets/google_search_panel_widget.dart';
import 'package:i_iwara/app/models/search_record.model.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/common/enums/filter_enums.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/filter_config.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/search_filter_drawer.dart';
import 'package:i_iwara/app/models/saved_search.model.dart';
import 'package:i_iwara/app/services/saved_search_service.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/saved_search_drawer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_saved_items_drawer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_title_pill.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';

const List<SearchSegment> _kAllSearchSegments = [
  SearchSegment.video,
  SearchSegment.image,
  SearchSegment.user,
  SearchSegment.playlist,
  SearchSegment.post,
  SearchSegment.forum,
  SearchSegment.forum_posts,
  SearchSegment.oreno3d,
];

class SearchPage extends StatefulWidget {
  final String userInputKeywords;
  final SearchSegment initialSegment;
  final Function(String, SearchSegment, List<Filter>, String)? onSearch;
  final List<Filter>? initialFilters;
  final String? initialSort;

  const SearchPage({
    super.key,
    this.userInputKeywords = '',
    this.initialSegment = SearchSegment.video,
    this.onSearch,
    this.initialFilters,
    this.initialSort,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late UserPreferenceService userPreferenceService;
  late final SavedSearchService _savedSearchService;

  // 搜索状态
  final RxString _searchPlaceholder = ''.obs;
  final RxString _searchErrorText = ''.obs;
  final Rx<SearchSegment> _selectedSegment = SearchSegment.video.obs;
  final RxString _selectedSort = ''.obs;

  // 筛选项状态
  final RxList<Filter> _filters = <Filter>[].obs;

  // 滚动控制器
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    userPreferenceService = Get.find<UserPreferenceService>();
    if (!Get.isRegistered<SavedSearchService>()) {
      Get.put(SavedSearchService(), permanent: true);
    }
    _savedSearchService = Get.find<SavedSearchService>();

    _controller.text = widget.userInputKeywords;
    _selectedSegment.value = widget.initialSegment;
    _selectedSort.value =
        widget.initialSort ??
        FilterConfig.getDefaultSortForSegment(widget.initialSegment);

    if (widget.initialFilters != null) {
      _filters.assignAll(widget.initialFilters!);
    }

    _updateSearchPlaceholder(userPreferenceService.videoSearchHistory);
  }

  void _updateSearchPlaceholder(List<SearchRecord> history) {
    if (history.isEmpty) {
      _searchPlaceholder.value = '';
      return;
    }

    final maxUsedTimes = history.map((e) => e.usedTimes).reduce(max);
    final now = DateTime.now();
    List<(SearchRecord, double)> weightedRecords = history.map((record) {
      double freqScore = (record.usedTimes / maxUsedTimes) * 40;
      double daysAgo = now.difference(record.lastUsedAt).inDays.toDouble();
      double timeScore = (1 - (daysAgo / 30)).clamp(0.0, 1.0) * 40;
      double randomScore = Random().nextDouble() * 20;
      return (record, freqScore + timeScore + randomScore);
    }).toList();

    weightedRecords.sort((a, b) => b.$2.compareTo(a.$2));
    final topCount = min(3, weightedRecords.length);
    final selectedIndex = Random().nextInt(topCount);
    _searchPlaceholder.value = weightedRecords[selectedIndex].$1.keyword;
  }

  void _removeHistoryItem(int index) {
    final record = userPreferenceService.videoSearchHistory[index];
    userPreferenceService.removeVideoSearchHistory(record.keyword);
  }

  void _clearHistory() {
    userPreferenceService.clearVideoSearchHistory();
  }

  void _handleSubmit(String value) {
    _searchErrorText.value = '';

    if (value.isNotEmpty && userPreferenceService.searchRecordEnabled.value) {
      userPreferenceService.addVideoSearchHistory(value);
    }

    LogUtils.d(
      '搜索内容: $value, 类型: ${_selectedSegment.value}, sort: ${_selectedSort.value}, filters: ${_filters.toList()}',
    );

    if (widget.onSearch != null) {
      AppService.tryPop();
      widget.onSearch!(
        value,
        _selectedSegment.value,
        _filters.toList(),
        _selectedSort.value,
      );
    } else {
      NaviService.toSearchPage(
        searchInfo: value,
        segment: _selectedSegment.value,
        filters: _filters.toList(),
        sort: _selectedSort.value,
      );
    }
  }

  void _browseOreno3d(String type, String id, String name) {
    NaviService.toSearchPage(
      searchInfo: '',
      segment: SearchSegment.oreno3d,
      searchType: type,
      extData: {'searchType': type, 'id': id, 'name': name},
      sort: _selectedSort.value,
    );
  }

  void _openOreno3dPicker() {
    showAppDialog(
      Oreno3dTagPickerDialog(
        initialType: 'tag',
        closeOnSelect: true,
        onSelected: (e) => _browseOreno3d(e.type, e.id, e.name),
      ),
    );
  }

  void _openSavedSearchDrawer() {
    showSavedSearchDrawer(
      context: context,
      onApply: _applySavedSearch,
      onAddCurrent: _promptSaveCurrentSearch,
    );
  }

  String _buildDefaultSearchName() {
    final keyword = _controller.text.trim();
    final segmentLabel = SavedSearchDrawer.segmentLabel(_selectedSegment.value);
    if (keyword.isNotEmpty) return '$segmentLabel · $keyword';
    return segmentLabel;
  }

  Future<void> _promptSaveCurrentSearch() async {
    final t = slang.Translations.of(context);
    final defaultName = _buildDefaultSearchName();
    final name = await showGlassPromptNameDialog(
      title: t.savedSearch.namePromptTitle,
      hint: t.savedSearch.nameHint,
      initialText: defaultName,
    );
    if (name == null) return;

    final search = SavedSearch(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.isEmpty ? defaultName : name,
      keyword: _controller.text,
      segment: _selectedSegment.value,
      sort: _selectedSort.value,
      filters: _filters.toList(),
    );
    await _savedSearchService.add(search);
    showGlassToast(
      t.savedSearch.saveSuccess,
      type: GlassToastType.success,
      position: GlassToastPosition.bottom,
    );
  }

  void _applySavedSearch(SavedSearch search) {
    final extData = search.extData;
    if (extData != null) {
      final type = extData['searchType'] as String?;
      final id = extData['id'] as String?;
      final name = (extData['name'] as String?) ?? search.singleTagName;
      if (type != null && id != null) {
        NaviService.toSearchPage(
          searchInfo: '',
          segment: SearchSegment.oreno3d,
          searchType: type,
          extData: {'searchType': type, 'id': id, 'name': name},
          sort: search.sort,
        );
        return;
      }
    }

    if (userPreferenceService.searchRecordEnabled.value &&
        search.keyword.isNotEmpty) {
      userPreferenceService.addVideoSearchHistory(search.keyword);
    }
    if (widget.onSearch != null) {
      AppService.tryPop();
      widget.onSearch!(
        search.keyword,
        search.segment,
        search.filters.toList(),
        search.sort,
      );
    } else {
      NaviService.toSearchPage(
        searchInfo: search.keyword,
        segment: search.segment,
        filters: search.filters.toList(),
        sort: search.sort,
      );
    }
  }

  String _getSegmentLabel(SearchSegment seg, slang.Translations t) {
    return switch (seg) {
      SearchSegment.video => t.common.video,
      SearchSegment.image => t.common.gallery,
      SearchSegment.user => t.common.user,
      SearchSegment.playlist => t.common.playlist,
      SearchSegment.post => t.common.post,
      SearchSegment.forum => t.forum.forum,
      SearchSegment.forum_posts => t.forum.posts,
      SearchSegment.oreno3d => 'Oreno3D',
    };
  }

  IconData _getSegmentIcon(SearchSegment seg) {
    return switch (seg) {
      SearchSegment.video => Icons.video_library_outlined,
      SearchSegment.image => Icons.image_outlined,
      SearchSegment.user => Icons.person_outline,
      SearchSegment.playlist => Icons.playlist_play_outlined,
      SearchSegment.post => Icons.article_outlined,
      SearchSegment.forum => Icons.forum_outlined,
      SearchSegment.forum_posts => Icons.comment_outlined,
      SearchSegment.oreno3d => Icons.view_in_ar_outlined,
    };
  }

  IconData _getSortIconFor(SearchSegment seg, String value) {
    if (seg == SearchSegment.oreno3d) {
      switch (value) {
        case 'hot':
          return Icons.trending_up;
        case 'favorites':
          return Icons.favorite;
        case 'latest':
          return Icons.schedule;
        case 'popularity':
          return Icons.star;
        default:
          return Icons.sort;
      }
    }
    switch (value) {
      case 'relevance':
        return Icons.recommend;
      case 'date':
        return Icons.schedule;
      case 'views':
        return Icons.visibility;
      case 'likes':
        return Icons.favorite;
      default:
        return Icons.sort;
    }
  }

  String _getSortLabelFor(
    SearchSegment seg,
    String value,
    slang.Translations t,
  ) {
    if (seg == SearchSegment.oreno3d) {
      return switch (value) {
        'hot' => t.oreno3d.sortTypes.hot,
        'favorites' => t.oreno3d.sortTypes.favorites,
        'latest' => t.oreno3d.sortTypes.latest,
        'popularity' => t.oreno3d.sortTypes.popularity,
        _ => t.common.sort,
      };
    }
    final sortOptions = FilterConfig.getSortOptionsForSegment(seg);
    for (final opt in sortOptions) {
      if (opt.value == value) return opt.label;
    }
    return t.common.sort;
  }

  List<GlassMenuEntry> _buildSortMenuEntries(
    SearchSegment seg,
    String currentSort,
    slang.Translations t,
  ) {
    if (seg == SearchSegment.oreno3d) {
      return [
        GlassMenuOption<String>(
          value: 'hot',
          icon: Icons.trending_up,
          label: t.oreno3d.sortTypes.hot,
          selected: currentSort == 'hot',
        ),
        GlassMenuOption<String>(
          value: 'favorites',
          icon: Icons.favorite,
          label: t.oreno3d.sortTypes.favorites,
          selected: currentSort == 'favorites',
        ),
        GlassMenuOption<String>(
          value: 'latest',
          icon: Icons.schedule,
          label: t.oreno3d.sortTypes.latest,
          selected: currentSort == 'latest',
        ),
        GlassMenuOption<String>(
          value: 'popularity',
          icon: Icons.star,
          label: t.oreno3d.sortTypes.popularity,
          selected: currentSort == 'popularity',
        ),
      ];
    }
    final options = FilterConfig.getSortOptionsForSegment(seg);
    return options
        .map(
          (opt) => GlassMenuOption<String>(
            value: opt.value,
            icon: _getSortIconFor(seg, opt.value),
            label: opt.label,
            selected: opt.value == currentSort,
          ),
        )
        .toList();
  }

  /// 打开右侧「筛选」抽屉。改动即时生效（这里只是把条件记进 [_filters]，真正
  /// 发出去要等提交搜索），抽屉常驻不关。
  void _showFilterDialog(BuildContext context, SearchSegment currentSegment) {
    showSearchFilterDrawer(
      context: context,
      segment: currentSegment,
      initialFilters: _filters.toList(),
      onFiltersChanged: _filters.assignAll,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 640;
        return isWide ? _buildDesktopLayout() : _buildMobileLayout();
      },
    );
  }

  /// 📱 移动端布局：顶部无缝集成搜索框，水平滑动分段控制，紧凑触控历史列表
  Widget _buildMobileLayout() {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double bottomPadding = MediaQuery.paddingOf(context).bottom;
    final double headerExtent = statusBarHeight + 58;

    return Scaffold(
      body: GlassHeaderOverlay(
        headerExtent: headerExtent,
        headerTop: statusBarHeight,
        solidExtent: statusBarHeight,
        liquid: true,
        header: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            children: [
              GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.arrow_back),
                tooltip: t.common.back,
                onPressed: () => AppService.tryPop(),
              ),
              const SizedBox(width: 8),
              // 顶部内嵌搜索输入框（液态玻璃风格）
              Expanded(
                child: Obx(
                  () => GlassSurface(
                    height: 44,
                    borderRadius: BorderRadius.circular(22),
                    padding: const EdgeInsets.only(left: 12, right: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            autofocus: false,
                            textInputAction: TextInputAction.search,
                            textAlignVertical: TextAlignVertical.center,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: _searchPlaceholder.value.isEmpty
                                  ? t.search.pleaseEnterSearchContent
                                  : '${t.search.searchSuggestion}: ${_searchPlaceholder.value}',
                              hintStyle: TextStyle(
                                fontSize: 13.5,
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (val) {
                              _searchErrorText.value = '';
                              setState(() {});
                            },
                            onSubmitted: _handleSubmit,
                          ),
                        ),
                        if (_controller.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _controller.clear();
                              _searchErrorText.value = '';
                              _searchPlaceholder.value = '';
                              _focusNode.requestFocus();
                              setState(() {});
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 右上角：液态玻璃风格「已保存搜索」抽屉入口
              GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.bookmarks_outlined),
                tooltip: t.savedSearch.title,
                onPressed: _openSavedSearchDrawer,
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.only(
            top: headerExtent + 4,
            bottom: bottomPadding + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. 分段滑动切换器
              _buildMobileSegmentControl(),

              // 2. 移动端快捷工具栏（排序、筛选、Oreno3D探索、Google搜索等）
              _buildMobileQuickActionsBar(),

              // 3. Oreno3D 专属收藏区
              _buildOreno3dSection(isWide: false),

              // 4. 搜索历史记录区
              _buildHistorySection(isWide: false),
            ],
          ),
        ),
      ),
    );
  }

  /// 📱 移动端 Segment 滑动栏
  Widget _buildMobileSegmentControl() {
    final t = slang.Translations.of(context);

    return Obx(() {
      final selectedIndex = _kAllSearchSegments.indexOf(_selectedSegment.value);
      final validIndex = selectedIndex >= 0 ? selectedIndex : 0;

      final items = _kAllSearchSegments.map((s) {
        return GlassSegmentItem(
          label: _getSegmentLabel(s, t),
          icon: Icon(_getSegmentIcon(s), size: 16),
        );
      }).toList();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: GlassSegmentedControl(
          items: items,
          selectedIndex: validIndex,
          onChanged: (index) {
            final nextSeg = _kAllSearchSegments[index];
            _selectedSegment.value = nextSeg;
            _selectedSort.value = FilterConfig.getDefaultSortForSegment(
              nextSeg,
            );
          },
        ),
      );
    });
  }

  /// 📱 移动端快捷工具栏（横向滚动胶囊）
  Widget _buildMobileQuickActionsBar() {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 4),
      child: Obx(() {
        final seg = _selectedSegment.value;
        final sort = _selectedSort.value;
        final filterCount = _filters.length;
        final sortLabel = _getSortLabelFor(seg, sort, t);
        final sortOptions = FilterConfig.getSortOptionsForSegment(seg);
        final showSort = seg == SearchSegment.oreno3d || sortOptions.isNotEmpty;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              // 排序下拉
              if (showSort)
                Builder(
                  builder: (anchorContext) => GlassSurface(
                    // 这块玻璃就是菜单的触发件：长按也能打开，且长按不抬手可以
                    // 直接划到某一条上松手选中（见 GlassTapArea.opensOverlay）。
                    opensOverlay: true,
                    onTap: () async {
                      final picked = await showGlassMenu<String>(
                        anchorContext: anchorContext,
                        entries: _buildSortMenuEntries(seg, sort, t),
                      );
                      if (picked != null) _selectedSort.value = picked;
                    },
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getSortIconFor(seg, sort),
                          size: 16,
                          color: colorScheme.onSurface,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          sortLabel,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),

              if (showSort) const SizedBox(width: 8),

              // 多维筛选
              if (seg != SearchSegment.oreno3d)
                Badge(
                  isLabelVisible: filterCount > 0,
                  label: Text('$filterCount'),
                  backgroundColor: colorScheme.primary,
                  child: GlassSurface(
                    onTap: () => _showFilterDialog(context, seg),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 16,
                          color: colorScheme.onSurface,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          t.searchFilter.filterSettings,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Oreno3D 探索实体入口
              if (seg == SearchSegment.oreno3d)
                GlassSurface(
                  onTap: _openOreno3dPicker,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.travel_explore,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        t.favoriteTags.browseEntry,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(width: 8),

              // 已保存搜索
              GlassSurface(
                onTap: _openSavedSearchDrawer,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmarks_outlined,
                      size: 16,
                      color: colorScheme.onSurface,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      t.savedSearch.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Google 搜索入口
              GlassSurface(
                onTap: () => GoogleSearchBottomSheet.show(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.travel_explore,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      t.search.googleSearch,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// 💻 PC / 桌面端布局：居中 Hero 搜索控制台 + 展开式分段 + 双列网格历史记录
  Widget _buildDesktopLayout() {
    final t = slang.Translations.of(context);
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double bottomPadding = MediaQuery.paddingOf(context).bottom;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;

    return Scaffold(
      body: GlassHeaderOverlay(
        headerExtent: headerExtent,
        headerTop: statusBarHeight,
        solidExtent: statusBarHeight,
        liquid: true,
        header: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.arrow_back),
                tooltip: t.common.back,
                onPressed: () => AppService.tryPop(),
              ),
              const SizedBox(width: 12),
              GlassTitlePill(title: t.common.search),
              const Spacer(),
              GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.bookmarks_outlined),
                tooltip: t.savedSearch.title,
                onPressed: _openSavedSearchDrawer,
              ),
              const SizedBox(width: 8),
              GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.travel_explore),
                tooltip: t.search.googleSearch,
                onPressed: () => GoogleSearchBottomSheet.show(),
              ),
            ],
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.only(
                top: headerExtent + 16,
                bottom: bottomPadding + 32,
                left: 20,
                right: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Hero 搜索主卡片
                  _buildDesktopHeroConsole(),

                  const SizedBox(height: 24),

                  // 2. Oreno3D 专属收藏区
                  _buildOreno3dSection(isWide: true),

                  // 3. 搜索历史区（双列/网格卡片）
                  _buildHistorySection(isWide: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 💻 PC 桌面 Hero 搜索主卡片
  Widget _buildDesktopHeroConsole() {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: GlassTokens.stroke(colorScheme),
          width: 0.8,
        ),
        // ⛔ 不吐外投影：玻璃件（半透明底 + GlassTokens.stroke）一律靠底色
        // 与描边立起来，见 GlassTokens 里已删的 shadow token 注释。
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 搜索输入栏（液态玻璃风格）
          Obx(
            () => GlassSurface(
              height: 52,
              borderRadius: BorderRadius.circular(26),
              padding: const EdgeInsets.only(left: 16, right: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: false,
                      textInputAction: TextInputAction.search,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: _searchPlaceholder.value.isEmpty
                            ? t.search.pleaseEnterSearchContent
                            : '${t.search.searchSuggestion}: ${_searchPlaceholder.value}',
                        hintStyle: TextStyle(
                          fontSize: 14.5,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.75,
                          ),
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (val) {
                        _searchErrorText.value = '';
                        setState(() {});
                      },
                      onSubmitted: _handleSubmit,
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        _controller.clear();
                        _searchErrorText.value = '';
                        _searchPlaceholder.value = '';
                        _focusNode.requestFocus();
                        setState(() {});
                      },
                    ),
                  const SizedBox(width: 6),
                  GlassSubmitButton(
                    label: t.common.search,
                    icon: Icons.search,
                    onPressed: () => _handleSubmit(_controller.text),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 分段全展开选择器
          Obx(() {
            final selectedIndex = _kAllSearchSegments.indexOf(
              _selectedSegment.value,
            );
            final validIndex = selectedIndex >= 0 ? selectedIndex : 0;
            final items = _kAllSearchSegments.map((s) {
              return GlassSegmentItem(
                label: _getSegmentLabel(s, t),
                icon: Icon(_getSegmentIcon(s), size: 16),
              );
            }).toList();

            return GlassSegmentedControl(
              items: items,
              selectedIndex: validIndex,
              onChanged: (index) {
                final nextSeg = _kAllSearchSegments[index];
                _selectedSegment.value = nextSeg;
                _selectedSort.value = FilterConfig.getDefaultSortForSegment(
                  nextSeg,
                );
              },
            );
          }),

          const SizedBox(height: 16),

          // 桌面端工具栏（排序、高级筛选、Oreno3D 探索）
          Obx(() {
            final seg = _selectedSegment.value;
            final sort = _selectedSort.value;
            final filterCount = _filters.length;
            final sortLabel = _getSortLabelFor(seg, sort, t);
            final sortOptions = FilterConfig.getSortOptionsForSegment(seg);
            final showSort =
                seg == SearchSegment.oreno3d || sortOptions.isNotEmpty;

            return Row(
              children: [
                if (showSort)
                  Builder(
                    builder: (anchorContext) => GlassSurface(
                      // 同上：触发件要声明 opensOverlay 才有长按开菜单 + 手指接力
                      opensOverlay: true,
                      onTap: () async {
                        final picked = await showGlassMenu<String>(
                          anchorContext: anchorContext,
                          entries: _buildSortMenuEntries(seg, sort, t),
                        );
                        if (picked != null) _selectedSort.value = picked;
                      },
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getSortIconFor(seg, sort),
                            size: 18,
                            color: colorScheme.onSurface,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${t.common.sort}: $sortLabel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),

                if (showSort) const SizedBox(width: 10),

                if (seg != SearchSegment.oreno3d)
                  Badge(
                    isLabelVisible: filterCount > 0,
                    label: Text('$filterCount'),
                    backgroundColor: colorScheme.primary,
                    child: GlassSurface(
                      onTap: () => _showFilterDialog(context, seg),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.filter_list,
                            size: 18,
                            color: colorScheme.onSurface,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            filterCount > 0
                                ? '${t.searchFilter.filterSettings} ($filterCount)'
                                : t.searchFilter.filterSettings,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (seg == SearchSegment.oreno3d)
                  GlassSurface(
                    onTap: _openOreno3dPicker,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.travel_explore,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          t.favoriteTags.browseEntry,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// 🔖 Oreno3D 快捷收藏区域（自适应移动/宽屏）
  Widget _buildOreno3dSection({required bool isWide}) {
    return Obx(() {
      if (_selectedSegment.value != SearchSegment.oreno3d) {
        return const SizedBox.shrink();
      }
      final t = slang.t;
      final favorites = userPreferenceService.oreno3dFavorites;
      if (favorites.isEmpty) {
        return const SizedBox.shrink();
      }

      final colorScheme = Theme.of(context).colorScheme;

      return Container(
        margin: EdgeInsets.only(
          left: isWide ? 0 : 12,
          right: isWide ? 0 : 12,
          bottom: 16,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: isWide ? 0.6 : 0.4),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: GlassTokens.stroke(colorScheme),
            width: 0.6,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.favorite_outline,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    t.favoriteTags.favoritesSection,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    NaviService.navigateToFavoriteOreno3dTagsPage();
                  },
                  icon: const Icon(Icons.settings_outlined, size: 18),
                  tooltip: t.favoriteTags.oreno3dTitle,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: colorScheme.outline,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: favorites.map((fav) {
                return ActionChip(
                  avatar: const Icon(Icons.tag, size: 14),
                  label: Text(
                    Oreno3dLocalizationService.displayName(
                      type: fav.type,
                      id: fav.id,
                      name: fav.name,
                    ),
                  ),
                  onPressed: () => _browseOreno3d(fav.type, fav.id, fav.name),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  /// 🕒 搜索历史区（自适应单列/双列网格）
  Widget _buildHistorySection({required bool isWide}) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      final history = userPreferenceService.videoSearchHistory;
      final hasHistory = history.isNotEmpty;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: isWide ? 0 : 12),
        padding: isWide ? const EdgeInsets.all(20) : EdgeInsets.zero,
        decoration: isWide
            ? BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: GlassTokens.stroke(colorScheme),
                  width: 0.6,
                ),
              )
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 历史标题与操作区
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 0 : 4,
                vertical: isWide ? 8 : 2,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.history,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    t.search.searchHistory,
                    style: TextStyle(
                      fontSize: isWide ? 15 : 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (hasHistory) ...[
                    const SizedBox(width: 6),
                    Text(
                      '(${history.length})',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                  const Spacer(),
                  // 记录状态开关
                  _RecordingToggleButton(
                    userPreferenceService: userPreferenceService,
                  ),
                  if (hasHistory) ...[
                    const SizedBox(width: 8),
                    _ClearHistoryButton(
                      onClearHistory: _clearHistory,
                      isWide: isWide,
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: isWide ? 8 : 4),

            // 历史列表 / 网格
            if (!hasHistory)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history_toggle_off,
                        size: 40,
                        color: colorScheme.outline.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        t.search.noSearchHistoryRecords,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (isWide)
              // 宽屏：双列网格卡片
              GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 64,
                ),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final record = history[index];
                  return _SearchHistoryCard(
                    record: record,
                    onRemove: () => _removeHistoryItem(index),
                    onTap: () {
                      _controller.text = record.keyword;
                      _handleSubmit(record.keyword);
                    },
                  );
                },
              )
            else
              // 移动端：单列卡片流（无多余内边距）
              ListView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final record = history[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _SearchHistoryCard(
                      record: record,
                      onRemove: () => _removeHistoryItem(index),
                      onTap: () {
                        _controller.text = record.keyword;
                        _handleSubmit(record.keyword);
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

/// 🕒 搜索历史卡片（鼠标悬浮高亮与整行点击）
class _SearchHistoryCard extends StatefulWidget {
  final SearchRecord record;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _SearchHistoryCard({
    required this.record,
    required this.onRemove,
    required this.onTap,
  });

  @override
  State<_SearchHistoryCard> createState() => _SearchHistoryCardState();
}

class _SearchHistoryCardState extends State<_SearchHistoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = BorderRadius.circular(14);
    final subtitleText =
        '${t.search.usedTimes}: ${widget.record.usedTimes} · ${t.search.lastUsed}: ${widget.record.lastUsedAt.toString().split('.')[0]}';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            color: _isHovered
                ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.65)
                : colorScheme.surface,
            borderRadius: radius,
            border: Border.all(
              color: _isHovered
                  ? colorScheme.primary.withValues(alpha: 0.4)
                  : colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
              child: Row(
                children: [
                  Icon(
                    Icons.history,
                    size: 18,
                    color: _isHovered
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.record.keyword,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: _isHovered ? colorScheme.primary : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitleText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: widget.onRemove,
                    tooltip: t.common.delete,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 🔴 历史记录开关
class _RecordingToggleButton extends StatelessWidget {
  final UserPreferenceService userPreferenceService;

  const _RecordingToggleButton({required this.userPreferenceService});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = BorderRadius.circular(999);

    return Obx(() {
      final enabled = userPreferenceService.searchRecordEnabled.value;
      final fg = enabled ? colorScheme.primary : colorScheme.onSurfaceVariant;
      final bg = fg.withValues(alpha: enabled ? 0.12 : 0.08);

      return Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: () {
              userPreferenceService.setSearchRecordEnabled(!enabled);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    enabled ? Icons.history : Icons.history_toggle_off,
                    size: 16,
                    color: fg,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    enabled ? t.common.recording : t.common.paused,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: fg,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// 🗑️ 清空历史按钮（胶囊样式，与记录中按钮尺寸一致）
class _ClearHistoryButton extends StatelessWidget {
  final VoidCallback onClearHistory;
  final bool isWide;

  const _ClearHistoryButton({
    required this.onClearHistory,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = BorderRadius.circular(999);
    final fg = colorScheme.error;
    final bg = fg.withValues(alpha: 0.08);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: Ink(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: radius,
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: () => _confirmClear(context, t),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: fg,
                ),
                const SizedBox(width: 4),
                Text(
                  t.common.clear,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: fg,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context, slang.Translations t) {
    showAppDialog(
      Builder(
        builder: (dialogContext) {
          return GlassAlertDialog(
            title: t.common.clear,
            content: Text(t.search.clearSearchHistoryConfirm),
            actions: [
              GlassDialogAction(
                label: t.common.cancel,
                emphasized: false,
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              GlassDialogAction(
                label: t.common.clear,
                destructive: true,
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  onClearHistory();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
