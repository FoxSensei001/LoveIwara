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
import 'dart:math';
import 'package:i_iwara/app/models/search_record.model.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/common/enums/filter_enums.dart';
import 'package:i_iwara/app/ui/widgets/responsive_dialog_widget.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/filter_config.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/filter_builder_widget.dart';
import 'package:i_iwara/app/models/saved_search.model.dart';
import 'package:i_iwara/app/services/saved_search_service.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/saved_search_drawer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';

class SearchDialog extends StatelessWidget {
  final String userInputKeywords;
  final SearchSegment initialSegment;
  final Function(String, SearchSegment, List<Filter>, String) onSearch;
  final List<Filter>? initialFilters;
  final String? initialSort;

  const SearchDialog({
    super.key,
    required this.userInputKeywords,
    required this.initialSegment,
    required this.onSearch,
    this.initialFilters,
    this.initialSort,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    return ResponsiveDialogWidget(
      title: t.common.search,
      maxWidth: 800,
      headerActions: [
        IconButton(
          onPressed: () {
            // 关闭当前搜索弹窗，改用底部 sheet 承载谷歌搜索内容
            AppService.tryPop();
            GoogleSearchBottomSheet.show();
          },
          icon: const Icon(Icons.travel_explore),
          tooltip: t.search.googleSearch,
        ),
      ],
      content: _SearchContent(
        userInputKeywords: userInputKeywords,
        initialSegment: initialSegment,
        onSearch: onSearch,
        initialFilters: initialFilters,
        initialSort: initialSort,
      ),
    );
  }
}

class _SearchContent extends StatefulWidget {
  final String userInputKeywords;
  final SearchSegment initialSegment;
  final Function(String, SearchSegment, List<Filter>, String) onSearch;
  final List<Filter>? initialFilters;
  final String? initialSort;

  const _SearchContent({
    required this.userInputKeywords,
    required this.initialSegment,
    required this.onSearch,
    this.initialFilters,
    this.initialSort,
  });

  @override
  State<_SearchContent> createState() => _SearchContentState();
}

class _SearchContentState extends State<_SearchContent> {
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

  // 滚动控制器，用于在展开谷歌搜索面板时自动滚动
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    userPreferenceService = Get.find<UserPreferenceService>();
    if (!Get.isRegistered<SavedSearchService>()) {
      Get.put(SavedSearchService(), permanent: true);
    }
    _savedSearchService = Get.find<SavedSearchService>();

    // 设置初始搜索内容和 segment
    _controller.text = widget.userInputKeywords;
    _selectedSegment.value = widget.initialSegment;
    _selectedSort.value =
        widget.initialSort ??
        FilterConfig.getDefaultSortForSegment(widget.initialSegment);

    // 设置初始筛选项
    if (widget.initialFilters != null) {
      _filters.assignAll(widget.initialFilters!);
    }

    // 更新搜索建议
    updateSearchPlaceholder(userPreferenceService.videoSearchHistory);
  }

  void updateSearchPlaceholder(List<SearchRecord> history) {
    if (history.isEmpty) {
      _searchPlaceholder.value = '';
      return;
    }

    // 计算最大使用次数，用于归一化
    final maxUsedTimes = history.map((e) => e.usedTimes).reduce(max);

    // 为每条记录计算权重分数
    final now = DateTime.now();
    List<(SearchRecord, double)> weightedRecords = history.map((record) {
      // 使用频率得分 (0-40分)
      double freqScore = (record.usedTimes / maxUsedTimes) * 40;

      // 时间衰减得分 (0-40分)
      double daysAgo = now.difference(record.lastUsedAt).inDays.toDouble();
      double timeScore = (1 - (daysAgo / 30)).clamp(0.0, 1.0) * 40;

      // 随机因素 (0-20分)
      double randomScore = Random().nextDouble() * 20;

      return (record, freqScore + timeScore + randomScore);
    }).toList();

    // 按总分排序
    weightedRecords.sort((a, b) => b.$2.compareTo(a.$2));

    // 从前3条中随机选择一条
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

    // 允许不输入关键词直接搜索（例如仅凭筛选项/排序浏览，或 oreno3d 浏览）。
    // 仅在确实输入了内容时才记录搜索历史。
    if (value.isNotEmpty && userPreferenceService.searchRecordEnabled.value) {
      userPreferenceService.addVideoSearchHistory(value);
    }

    LogUtils.d(
      '搜索内容: $value, 类型: ${_selectedSegment.value}, sort: ${_selectedSort.value}, filters: ${_filters.toList()}',
    );
    _dismiss();
    widget.onSearch(
      value,
      _selectedSegment.value,
      _filters.toList(),
      _selectedSort.value,
    );
  }

  void _dismiss() {
    AppService.tryPop();
  }

  /// 浏览指定 Oreno3d 实体（原作/角色/标签），关闭搜索弹窗后跳转浏览。
  void _browseOreno3d(String type, String id, String name) {
    _dismiss();
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

  // 打开全局右侧「已保存搜索」抽屉
  void _openSavedSearchDrawer() {
    showSavedSearchDrawer(
      onApply: _applySavedSearch,
      onAddCurrent: _promptSaveCurrentSearch,
    );
  }

  // 根据当前弹窗内的搜索条件生成默认名称
  String _buildDefaultSearchName() {
    final keyword = _controller.text.trim();
    final segmentLabel = SavedSearchDrawer.segmentLabel(_selectedSegment.value);
    if (keyword.isNotEmpty) return '$segmentLabel · $keyword';
    return segmentLabel;
  }

  // 弹出命名对话框，将弹窗内当前搜索条件保存为一条已保存搜索
  Future<void> _promptSaveCurrentSearch() async {
    final t = slang.Translations.of(context);

    final defaultName = _buildDefaultSearchName();
    final controller = TextEditingController(text: defaultName);
    final name = await showAppDialog<String>(
      Builder(
        builder: (dialogContext) => GlassAlertDialog(
          title: t.savedSearch.namePromptTitle,
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: t.savedSearch.nameLabel,
              hintText: t.savedSearch.nameHint,
            ),
            onSubmitted: (v) => Navigator.of(dialogContext).pop(v.trim()),
          ),
          actions: [
            GlassDialogAction(
              label: t.common.cancel,
              emphasized: false,
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            GlassDialogAction(
              label: t.common.save,
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
            ),
          ],
        ),
      ),
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

  // 应用一条已保存搜索：关闭弹窗后执行搜索/浏览
  void _applySavedSearch(SavedSearch search) {
    // Oreno3D 单实体浏览：直接按 id 跳转浏览
    final extData = search.extData;
    if (extData != null) {
      final type = extData['searchType'] as String?;
      final id = extData['id'] as String?;
      final name = (extData['name'] as String?) ?? search.singleTagName;
      if (type != null && id != null) {
        _dismiss();
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

    // 普通文本/筛选搜索
    if (userPreferenceService.searchRecordEnabled.value &&
        search.keyword.isNotEmpty) {
      userPreferenceService.addVideoSearchHistory(search.keyword);
    }
    _dismiss();
    widget.onSearch(
      search.keyword,
      search.segment,
      search.filters.toList(),
      search.sort,
    );
  }

  /// segment 为 oreno3d 时显示：收藏快捷区 + 浏览原作/角色/标签入口。
  Widget _buildOreno3dSection() {
    return Obx(() {
      if (_selectedSegment.value != SearchSegment.oreno3d) {
        return const SizedBox.shrink();
      }
      final t = slang.t;
      final favorites = userPreferenceService.oreno3dFavorites;
      // 浏览入口已移入上方控制栏，这里仅保留收藏快捷区
      if (favorites.isEmpty) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.favoriteTags.favoritesSection,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
                // 设置入口：跳转到 Oreno3D 收藏标签管理页（与全局抽屉一致）
                IconButton(
                  onPressed: () {
                    _dismiss();
                    NaviService.navigateToFavoriteOreno3dTagsPage();
                  },
                  icon: const Icon(Icons.settings_outlined, size: 18),
                  tooltip: t.favoriteTags.oreno3dTitle,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Theme.of(context).colorScheme.outline,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: favorites
                  .map(
                    (fav) => ActionChip(
                      label: Text(
                        Oreno3dLocalizationService.displayName(
                          type: fav.type,
                          id: fav.id,
                          name: fav.name,
                        ),
                      ),
                      onPressed: () =>
                          _browseOreno3d(fav.type, fav.id, fav.name),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isWide = width > 600;

    Widget searchContent = RepaintBoundary(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SearchInputSection(
              controller: _controller,
              focusNode: _focusNode,
              searchPlaceholder: _searchPlaceholder,
              searchErrorText: _searchErrorText,
              onChanged: (value) => _searchErrorText.value = '',
              onSubmitted: _handleSubmit,
              onClear: () {
                _controller.clear();
                _searchErrorText.value = '';
                _searchPlaceholder.value = '';
                _focusNode.requestFocus();
              },
            ),
            _SearchControlsSection(
              selectedSegment: _selectedSegment,
              onSegmentChanged: (segment) {
                _selectedSegment.value = segment;
                _selectedSort.value = FilterConfig.getDefaultSortForSegment(
                  segment,
                );
              },
              onSearch: () => _handleSubmit(_controller.text),
              filters: _filters,
              onFiltersChanged: (filters) => _filters.assignAll(filters),
              selectedSort: _selectedSort,
              onOpenSavedSearch: _openSavedSearchDrawer,
              onBrowseOreno3d: _openOreno3dPicker,
            ),
            _buildOreno3dSection(),
            _SearchHistorySection(
              userPreferenceService: userPreferenceService,
              onRemoveHistoryItem: _removeHistoryItem,
              onClearHistory: _clearHistory,
              onHistoryItemTap: (record) {
                _controller.text = record.keyword;
                _handleSubmit(record.keyword);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );

    if (isWide) {
      return searchContent;
    }

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: searchContent,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _SearchInputSection extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final RxString searchPlaceholder;
  final RxString searchErrorText;
  final Function(String) onChanged;
  final Function(String) onSubmitted;
  final VoidCallback onClear;

  const _SearchInputSection({
    required this.controller,
    required this.focusNode,
    required this.searchPlaceholder,
    required this.searchErrorText,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    // 玻璃胶囊输入框：半透明底色 + 细描边，与首页玻璃控件一致
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: GlassTokens.fill(colorScheme),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: GlassTokens.stroke(colorScheme),
              width: 0.6,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: searchPlaceholder.value.isEmpty
                  ? t.search.pleaseEnterSearchContent
                  : '${t.search.searchSuggestion}: ${searchPlaceholder.value}',
              hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              errorText: searchErrorText.value.isEmpty
                  ? null
                  : searchErrorText.value,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              prefixIcon: Icon(
                Icons.search,
                color: colorScheme.onSurfaceVariant,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClear,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        ),
      ),
    );
  }
}

class _SearchControlsSection extends StatelessWidget {
  final Rx<SearchSegment> selectedSegment;
  final Function(SearchSegment) onSegmentChanged;
  final VoidCallback onSearch;
  final RxList<Filter> filters;
  final Function(List<Filter>) onFiltersChanged;
  final RxString selectedSort;
  final VoidCallback onOpenSavedSearch;
  final VoidCallback onBrowseOreno3d;

  const _SearchControlsSection({
    required this.selectedSegment,
    required this.onSegmentChanged,
    required this.onSearch,
    required this.filters,
    required this.onFiltersChanged,
    required this.selectedSort,
    required this.onOpenSavedSearch,
    required this.onBrowseOreno3d,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const controlHeight = GlassTokens.pillHeight;
    final iconButtonConstraints = BoxConstraints.tightFor(
      width: controlHeight,
      height: controlHeight,
    );

    // 玻璃胶囊：图标 + 文字（宽屏）
    Widget glassLabelPill({
      required IconData icon,
      required String label,
      bool showDropdownArrow = false,
      bool opensOverlay = false,
      VoidCallback? onTap,
    }) {
      return GlassSurface(
        onTap: onTap,
        opensOverlay: opensOverlay,
        padding: EdgeInsets.only(left: 14, right: showDropdownArrow ? 8 : 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: colorScheme.onSurface),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            if (showDropdownArrow)
              Icon(
                Icons.arrow_drop_down,
                size: 20,
                color: colorScheme.onSurface,
              ),
          ],
        ),
      );
    }

    // 玻璃方钮：仅图标（窄屏）
    Widget glassIconPill({
      required IconData icon,
      String? tooltip,
      bool opensOverlay = false,
      VoidCallback? onTap,
    }) {
      return GlassSurface(
        width: controlHeight,
        onTap: onTap,
        opensOverlay: opensOverlay,
        tooltip: tooltip,
        child: Center(
          child: Icon(
            icon,
            size: GlassTokens.iconSize,
            color: colorScheme.onSurface,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 520;

          return Obx(() {
            final seg = selectedSegment.value;
            final sort = selectedSort.value;

            String segmentLabel(SearchSegment segment) {
              return switch (segment) {
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

            IconData segmentIcon(SearchSegment segment) {
              return switch (segment) {
                SearchSegment.video => Icons.video_library,
                SearchSegment.image => Icons.image,
                SearchSegment.user => Icons.person,
                SearchSegment.playlist => Icons.playlist_play,
                SearchSegment.post => Icons.article,
                SearchSegment.forum => Icons.forum,
                SearchSegment.forum_posts => Icons.comment,
                SearchSegment.oreno3d => Icons.view_in_ar,
              };
            }

            IconData sortIconFor(String value) {
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

            List<GlassMenuEntry> buildSortMenuEntries() {
              if (seg == SearchSegment.oreno3d) {
                return [
                  GlassMenuOption<String>(
                    value: 'hot',
                    icon: Icons.trending_up,
                    label: t.oreno3d.sortTypes.hot,
                    selected: sort == 'hot',
                  ),
                  GlassMenuOption<String>(
                    value: 'favorites',
                    icon: Icons.favorite,
                    label: t.oreno3d.sortTypes.favorites,
                    selected: sort == 'favorites',
                  ),
                  GlassMenuOption<String>(
                    value: 'latest',
                    icon: Icons.schedule,
                    label: t.oreno3d.sortTypes.latest,
                    selected: sort == 'latest',
                  ),
                  GlassMenuOption<String>(
                    value: 'popularity',
                    icon: Icons.star,
                    label: t.oreno3d.sortTypes.popularity,
                    selected: sort == 'popularity',
                  ),
                ];
              }

              final options = FilterConfig.getSortOptionsForSegment(seg);
              return options
                  .map(
                    (opt) => GlassMenuOption<String>(
                      value: opt.value,
                      icon: sortIconFor(opt.value),
                      label: opt.label,
                      selected: opt.value == sort,
                    ),
                  )
                  .toList();
            }

            List<GlassMenuEntry> buildSegmentMenuEntries() {
              const order = [
                SearchSegment.video,
                SearchSegment.image,
                SearchSegment.user,
                SearchSegment.playlist,
                SearchSegment.post,
                SearchSegment.forum,
                SearchSegment.forum_posts,
                SearchSegment.oreno3d,
              ];
              return [
                for (final s in order)
                  GlassMenuOption<SearchSegment>(
                    value: s,
                    icon: segmentIcon(s),
                    label: segmentLabel(s),
                    selected: s == seg,
                  ),
              ];
            }

            final sortOptions = FilterConfig.getSortOptionsForSegment(seg);
            final showSortButton =
                seg == SearchSegment.oreno3d || sortOptions.isNotEmpty;

            String sortLabelFor(String value) {
              if (seg == SearchSegment.oreno3d) {
                return switch (value) {
                  'hot' => t.oreno3d.sortTypes.hot,
                  'favorites' => t.oreno3d.sortTypes.favorites,
                  'latest' => t.oreno3d.sortTypes.latest,
                  'popularity' => t.oreno3d.sortTypes.popularity,
                  _ => t.common.sort,
                };
              }

              for (final opt in sortOptions) {
                if (opt.value == value) return opt.label;
              }
              return t.common.sort;
            }

            final currentSortLabel = sortLabelFor(sort);
            final filterCount = filters.length;

            Widget segmentButton() {
              return Builder(
                builder: (anchorContext) {
                  Future<void> openMenu() async {
                    final picked = await showGlassMenu<SearchSegment>(
                      anchorContext: anchorContext,
                      entries: buildSegmentMenuEntries(),
                    );
                    if (picked != null) onSegmentChanged(picked);
                  }

                  return compact
                      // 菜单的触发钮：长按也能打开，且长按不抬手可以直接划到
                      // 某一条上松手选中（见 GlassTapArea.opensOverlay）。
                      ? glassIconPill(
                          icon: segmentIcon(seg),
                          tooltip: segmentLabel(seg),
                          opensOverlay: true,
                          onTap: openMenu,
                        )
                      : glassLabelPill(
                          icon: segmentIcon(seg),
                          label: segmentLabel(seg),
                          showDropdownArrow: true,
                          opensOverlay: true,
                          onTap: openMenu,
                        );
                },
              );
            }

            Widget sortButton() {
              return Builder(
                builder: (anchorContext) {
                  Future<void> openMenu() async {
                    final picked = await showGlassMenu<String>(
                      anchorContext: anchorContext,
                      entries: buildSortMenuEntries(),
                    );
                    if (picked != null) selectedSort.value = picked;
                  }

                  return compact
                      // 菜单的触发钮，同上。
                      ? glassIconPill(
                          icon: sortIconFor(sort),
                          tooltip: '${t.common.sort}: $currentSortLabel',
                          opensOverlay: true,
                          onTap: openMenu,
                        )
                      : glassLabelPill(
                          icon: sortIconFor(sort),
                          label: currentSortLabel,
                          showDropdownArrow: true,
                          opensOverlay: true,
                          onTap: openMenu,
                        );
                },
              );
            }

            Widget filterButton() {
              final tooltip = filterCount == 0
                  ? t.searchFilter.filterSettings
                  : '${t.searchFilter.filterSettings}: $filterCount';

              if (compact) {
                final icon = glassIconPill(
                  icon: Icons.filter_list,
                  tooltip: tooltip,
                  onTap: () => _showFilterDialog(context, seg, t),
                );

                if (filterCount <= 0) return icon;

                return Badge.count(
                  count: filterCount,
                  backgroundColor: colorScheme.primary,
                  child: icon,
                );
              }

              return glassLabelPill(
                icon: Icons.filter_list,
                label: filterCount == 0
                    ? t.searchFilter.filterSettings
                    : '${t.searchFilter.filterSettings} ($filterCount)',
                onTap: () => _showFilterDialog(context, seg, t),
              );
            }

            // 搜索是唯一的主色按钮，与玻璃胶囊区分开
            Widget searchButton() {
              if (compact) {
                return IconButton.filled(
                  onPressed: onSearch,
                  icon: const Icon(Icons.search),
                  tooltip: t.common.search,
                  constraints: iconButtonConstraints,
                );
              }

              // 主色实心胶囊走 GlassSubmitButton：高度就是 GlassTokens.pillHeight，
              // 按下缩放/配色与全站主动作键同一族，不再是裸 FilledButton。
              return GlassSubmitButton(
                label: t.common.search,
                icon: Icons.search,
                onPressed: onSearch,
              );
            }

            Widget savedSearchButton() {
              return GlassIconButton(
                standalone: true,
                icon: const Icon(Icons.bookmarks_outlined),
                tooltip: t.savedSearch.title,
                onPressed: onOpenSavedSearch,
              );
            }

            // Oreno3D 浏览原作/角色/标签入口，作为单独图标放进控制栏
            Widget oreno3dBrowseButton() {
              return glassIconPill(
                icon: Icons.travel_explore,
                tooltip: t.favoriteTags.browseEntry,
                onTap: onBrowseOreno3d,
              );
            }

            final leftControls = <Widget>[
              segmentButton(),
              if (showSortButton) ...[const SizedBox(width: 6), sortButton()],
              if (seg != SearchSegment.oreno3d) ...[
                const SizedBox(width: 6),
                filterButton(),
              ],
              if (seg == SearchSegment.oreno3d) ...[
                const SizedBox(width: 6),
                oreno3dBrowseButton(),
              ],
            ];

            return Row(
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: controlHeight),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(children: leftControls),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                savedSearchButton(),
                const SizedBox(width: 8),
                searchButton(),
              ],
            );
          });
        },
      ),
    );
  }

  void _showFilterDialog(
    BuildContext context,
    SearchSegment currentSegment,
    slang.Translations t,
  ) {
    List<Filter> tempFilters = filters.map((f) => f.copyWith()).toList();

    ResponsiveDialog.show(
      context: context,
      title: t.searchFilter.filterSettings,
      maxWidth: 800,
      headerActions: [
        GlassButtonGroup(
          children: [
            GlassTextActionButton(
              label: t.common.confirm,
              emphasized: true,
              onPressed: () {
                onFiltersChanged(tempFilters.map((f) => f.copyWith()).toList());
                AppService.tryPop();
              },
            ),
          ],
        ),
      ],
      content: FilterBuilderWidget(
        initialSegment: currentSegment,
        initialFilters: filters.toList(),
        onFiltersChanged: (newFilters) {
          tempFilters = newFilters;
        },
        destroyOnClose: true,
      ),
    );
  }
}

class _SearchHistorySection extends StatelessWidget {
  final UserPreferenceService userPreferenceService;
  final Function(int) onRemoveHistoryItem;
  final VoidCallback onClearHistory;
  final Function(SearchRecord) onHistoryItemTap;

  const _SearchHistorySection({
    required this.userPreferenceService,
    required this.onRemoveHistoryItem,
    required this.onClearHistory,
    required this.onHistoryItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      // 拉伸子项占满宽度，否则窄屏下标题会被居中而非靠左
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SearchHistoryHeader(
          userPreferenceService: userPreferenceService,
          onClearHistory: onClearHistory,
        ),
        _SearchHistoryList(
          userPreferenceService: userPreferenceService,
          onRemoveHistoryItem: onRemoveHistoryItem,
          onHistoryItemTap: onHistoryItemTap,
        ),
      ],
    );
  }
}

class _SearchHistoryHeader extends StatelessWidget {
  final UserPreferenceService userPreferenceService;
  final VoidCallback onClearHistory;

  const _SearchHistoryHeader({
    required this.userPreferenceService,
    required this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);

    return Obx(() {
      final hasHistory = userPreferenceService.videoSearchHistory.isNotEmpty;

      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 420;

            // 与「收藏」分区标签保持一致的样式
            final title = Text(
              t.search.searchHistory,
              style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
            );

            final actions = Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _RecordingToggleButton(
                  userPreferenceService: userPreferenceService,
                ),
                if (hasHistory)
                  _ClearHistoryButton(onClearHistory: onClearHistory),
              ],
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [title, const SizedBox(height: 10), actions],
              );
            }

            return Row(
              children: [
                Expanded(child: title),
                actions,
              ],
            );
          },
        ),
      );
    });
  }
}

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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    enabled ? Icons.history : Icons.history_toggle_off,
                    size: 18,
                    color: fg,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    enabled ? t.common.recording : t.common.paused,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12.5,
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

class _ClearHistoryButton extends StatelessWidget {
  final VoidCallback onClearHistory;

  const _ClearHistoryButton({required this.onClearHistory});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    return GlassButtonGroup(
      children: [
        GlassTextActionButton(
          label: t.common.clear,
          destructive: true,
          onPressed: () => _confirmClear(context, t),
        ),
      ],
    );
  }

  // 清除前二次确认，避免误触清空搜索历史
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

class _SearchHistoryList extends StatelessWidget {
  final UserPreferenceService userPreferenceService;
  final Function(int) onRemoveHistoryItem;
  final Function(SearchRecord) onHistoryItemTap;

  const _SearchHistoryList({
    required this.userPreferenceService,
    required this.onRemoveHistoryItem,
    required this.onHistoryItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    return Obx(() {
      if (userPreferenceService.videoSearchHistory.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(t.search.noSearchHistoryRecords),
          ),
        );
      }

      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: userPreferenceService.videoSearchHistory.length,
        itemBuilder: (context, index) {
          final record = userPreferenceService.videoSearchHistory[index];
          return _SearchHistoryItem(
            record: record,
            onRemove: () => onRemoveHistoryItem(index),
            onTap: () => onHistoryItemTap(record),
          );
        },
      );
    });
  }
}

class _SearchHistoryItem extends StatelessWidget {
  final SearchRecord record;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _SearchHistoryItem({
    required this.record,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = BorderRadius.circular(14);
    final subtitleText =
        '${t.search.usedTimes}: ${record.usedTimes} · ${t.search.lastUsed}: ${record.lastUsedAt.toString().split('.')[0]}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: radius,
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
              child: Row(
                children: [
                  Icon(
                    Icons.history,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.keyword,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
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
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: onRemove,
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
