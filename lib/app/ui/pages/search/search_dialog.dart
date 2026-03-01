import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/widgets/google_search_panel_widget.dart';
import 'dart:math';
import 'package:i_iwara/app/models/search_record.model.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/search_common_widgets.dart';
import 'package:i_iwara/common/enums/filter_enums.dart';
import 'package:i_iwara/app/ui/widgets/responsive_dialog_widget.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/filter_config.dart';
import 'package:i_iwara/app/ui/pages/search/widgets/filter_builder_widget.dart';

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

    if (value.isEmpty) {
      if (_searchPlaceholder.isNotEmpty) {
        _controller.text = _searchPlaceholder.value;
        _focusNode.requestFocus();
      } else {
        _searchErrorText.value = slang.t.search.pleaseEnterSearchContent;
      }
      return;
    }

    if (userPreferenceService.searchRecordEnabled.value) {
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isWide = width > 600;

    Widget searchContent = SingleChildScrollView(
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
          ),
          _GoogleSearchSection(scrollController: _scrollController),
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

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Obx(
        () => SearchInputField(
          controller: controller,
          focusNode: focusNode,
          hintText: searchPlaceholder.value.isEmpty
              ? t.search.pleaseEnterSearchContent
              : '${t.search.searchSuggestion}: ${searchPlaceholder.value}',
          errorText: searchErrorText.value.isEmpty
              ? null
              : searchErrorText.value,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          onClear: onClear,
          autofocus: true,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          elevation: 1,
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

  const _SearchControlsSection({
    required this.selectedSegment,
    required this.onSegmentChanged,
    required this.onSearch,
    required this.filters,
    required this.onFiltersChanged,
    required this.selectedSort,
  });

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = BorderRadius.circular(12);
    const controlHeight = 44.0;
    final iconButtonConstraints = BoxConstraints.tightFor(
      width: controlHeight,
      height: controlHeight,
    );

    ButtonStyle tonalButtonStyle() {
      return FilledButton.styleFrom(
        backgroundColor: colorScheme.surfaceContainer,
        foregroundColor: colorScheme.onSurfaceVariant,
        minimumSize: const Size(0, controlHeight),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: radius),
        elevation: 0,
      );
    }

    ButtonStyle iconButtonStyle({
      required Color backgroundColor,
      required Color foregroundColor,
    }) {
      return IconButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: const EdgeInsets.all(10),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: radius),
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

            PopupMenuItem<SearchSegment> segmentMenuItem(
              SearchSegment segment,
              IconData icon,
              String label,
            ) {
              return PopupMenuItem<SearchSegment>(
                value: segment,
                child: Row(
                  children: [
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                    Text(label),
                  ],
                ),
              );
            }

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

            List<PopupMenuEntry<String>> buildSortMenuItems() {
              if (seg == SearchSegment.oreno3d) {
                return [
                  PopupMenuItem<String>(
                    value: 'hot',
                    child: Row(
                      children: [
                        const Icon(Icons.trending_up, size: 20),
                        const SizedBox(width: 8),
                        Text(t.oreno3d.sortTypes.hot),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'favorites',
                    child: Row(
                      children: [
                        const Icon(Icons.favorite, size: 20),
                        const SizedBox(width: 8),
                        Text(t.oreno3d.sortTypes.favorites),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'latest',
                    child: Row(
                      children: [
                        const Icon(Icons.schedule, size: 20),
                        const SizedBox(width: 8),
                        Text(t.oreno3d.sortTypes.latest),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'popularity',
                    child: Row(
                      children: [
                        const Icon(Icons.star, size: 20),
                        const SizedBox(width: 8),
                        Text(t.oreno3d.sortTypes.popularity),
                      ],
                    ),
                  ),
                ];
              }

              final options = FilterConfig.getSortOptionsForSegment(seg);
              return options
                  .map(
                    (opt) => PopupMenuItem<String>(
                      value: opt.value,
                      child: Row(
                        children: [
                          Icon(sortIconFor(opt.value), size: 20),
                          const SizedBox(width: 8),
                          Text(opt.label),
                        ],
                      ),
                    ),
                  )
                  .toList();
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
              return PopupMenuButton<SearchSegment>(
                shape: RoundedRectangleBorder(borderRadius: radius),
                initialValue: seg,
                onSelected: onSegmentChanged,
                itemBuilder: (context) => [
                  segmentMenuItem(
                    SearchSegment.video,
                    Icons.video_library,
                    t.common.video,
                  ),
                  segmentMenuItem(
                    SearchSegment.image,
                    Icons.image,
                    t.common.gallery,
                  ),
                  segmentMenuItem(
                    SearchSegment.user,
                    Icons.person,
                    t.common.user,
                  ),
                  segmentMenuItem(
                    SearchSegment.playlist,
                    Icons.playlist_play,
                    t.common.playlist,
                  ),
                  segmentMenuItem(
                    SearchSegment.post,
                    Icons.article,
                    t.common.post,
                  ),
                  segmentMenuItem(
                    SearchSegment.forum,
                    Icons.forum,
                    t.forum.forum,
                  ),
                  segmentMenuItem(
                    SearchSegment.forum_posts,
                    Icons.comment,
                    t.forum.posts,
                  ),
                  segmentMenuItem(
                    SearchSegment.oreno3d,
                    Icons.view_in_ar,
                    'Oreno3D',
                  ),
                ],
                child: AbsorbPointer(
                  child: compact
                      ? IconButton(
                          onPressed: () {},
                          icon: Icon(segmentIcon(seg)),
                          tooltip: segmentLabel(seg),
                          constraints: iconButtonConstraints,
                          style: iconButtonStyle(
                            backgroundColor: colorScheme.surfaceContainer,
                            foregroundColor: colorScheme.onSurfaceVariant,
                          ),
                        )
                      : FilledButton.tonal(
                          onPressed: () {},
                          style: tonalButtonStyle(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(segmentIcon(seg), size: 20),
                              const SizedBox(width: 6),
                              Text(segmentLabel(seg)),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, size: 20),
                            ],
                          ),
                        ),
                ),
              );
            }

            Widget sortButton() {
              return PopupMenuButton<String>(
                shape: RoundedRectangleBorder(borderRadius: radius),
                initialValue: sort,
                onSelected: (v) => selectedSort.value = v,
                itemBuilder: (context) => buildSortMenuItems(),
                child: AbsorbPointer(
                  child: compact
                      ? IconButton(
                          onPressed: () {},
                          icon: Icon(sortIconFor(sort)),
                          tooltip: '${t.common.sort}: $currentSortLabel',
                          constraints: iconButtonConstraints,
                          style: iconButtonStyle(
                            backgroundColor: colorScheme.surfaceContainer,
                            foregroundColor: colorScheme.onSurfaceVariant,
                          ),
                        )
                      : FilledButton.tonal(
                          onPressed: () {},
                          style: tonalButtonStyle(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(sortIconFor(sort), size: 20),
                              const SizedBox(width: 6),
                              Text(currentSortLabel),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, size: 20),
                            ],
                          ),
                        ),
                ),
              );
            }

            Widget filterButton() {
              final tooltip = filterCount == 0
                  ? t.searchFilter.filterSettings
                  : '${t.searchFilter.filterSettings}: $filterCount';

              if (compact) {
                final icon = IconButton(
                  onPressed: () => _showFilterDialog(context, seg, t),
                  icon: const Icon(Icons.filter_list),
                  tooltip: tooltip,
                  constraints: iconButtonConstraints,
                  style: iconButtonStyle(
                    backgroundColor: colorScheme.surfaceContainer,
                    foregroundColor: colorScheme.onSurfaceVariant,
                  ),
                );

                if (filterCount <= 0) return icon;

                return Badge.count(
                  count: filterCount,
                  backgroundColor: colorScheme.primary,
                  child: icon,
                );
              }

              return FilledButton.tonal(
                onPressed: () => _showFilterDialog(context, seg, t),
                style: tonalButtonStyle(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.filter_list, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      filterCount == 0
                          ? t.searchFilter.filterSettings
                          : '${t.searchFilter.filterSettings} ($filterCount)',
                    ),
                  ],
                ),
              );
            }

            Widget searchButton() {
              if (compact) {
                return IconButton(
                  onPressed: onSearch,
                  icon: const Icon(Icons.search),
                  tooltip: t.common.search,
                  constraints: iconButtonConstraints,
                  style: iconButtonStyle(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                );
              }

              return FilledButton(
                onPressed: onSearch,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  minimumSize: const Size(0, controlHeight),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: radius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search, size: 20),
                    const SizedBox(width: 6),
                    Text(t.common.search),
                  ],
                ),
              );
            }

            final leftControls = <Widget>[
              segmentButton(),
              if (showSortButton) ...[const SizedBox(width: 6), sortButton()],
              if (seg != SearchSegment.oreno3d) ...[
                const SizedBox(width: 6),
                filterButton(),
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
        FilledButton(
          onPressed: () {
            onFiltersChanged(tempFilters.map((f) => f.copyWith()).toList());
            AppService.tryPop();
          },
          style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
          child: Text(t.common.confirm),
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

class _GoogleSearchSection extends StatelessWidget {
  final ScrollController scrollController;

  const _GoogleSearchSection({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GoogleSearchPanelWidget(scrollController: scrollController),
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

            final title = Text(
              t.search.searchHistory,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
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

    return TextButton.icon(
      onPressed: onClearHistory,
      icon: const Icon(Icons.delete_outline, size: 18),
      label: Text(t.common.clear),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.error,
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
