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
import 'package:i_iwara/app/ui/pages/search/widgets/filter_button_widget.dart';
import 'package:i_iwara/common/enums/filter_enums.dart';
import 'package:i_iwara/app/ui/widgets/responsive_dialog_widget.dart';

class SearchDialog extends StatelessWidget {
  final String userInputKeywords;
  final SearchSegment initialSegment;
  final Function(String, SearchSegment, List<Filter>) onSearch;
  final List<Filter>? initialFilters;

  const SearchDialog({
    super.key,
    required this.userInputKeywords,
    required this.initialSegment,
    required this.onSearch,
    this.initialFilters,
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
      ),
    );
  }
}

class _SearchContent extends StatefulWidget {
  final String userInputKeywords;
  final SearchSegment initialSegment;
  final Function(String, SearchSegment, List<Filter>) onSearch;
  final List<Filter>? initialFilters;

  const _SearchContent({
    required this.userInputKeywords,
    required this.initialSegment,
    required this.onSearch,
    this.initialFilters,
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

    LogUtils.d('搜索内容: $value, 类型: ${_selectedSegment.value}, filters: ${_filters.toList()}');
    _dismiss();
    widget.onSearch(value, _selectedSegment.value, _filters.toList());
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
            onSegmentChanged: (segment) => _selectedSegment.value = segment,
            onSearch: () => _handleSubmit(_controller.text),
            filters: _filters,
            onFiltersChanged: (filters) => _filters.assignAll(filters),
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
      child: Obx(() => SearchInputField(
        controller: controller,
        focusNode: focusNode,
        hintText: searchPlaceholder.value.isEmpty
            ? t.search.pleaseEnterSearchContent
            : '${t.search.searchSuggestion}: ${searchPlaceholder.value}',
        errorText: searchErrorText.value.isEmpty ? null : searchErrorText.value,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onClear: onClear,
        autofocus: true,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        elevation: 1,
      )),
    );
  }
}

class _SearchControlsSection extends StatelessWidget {
  final Rx<SearchSegment> selectedSegment;
  final Function(SearchSegment) onSegmentChanged;
  final VoidCallback onSearch;
  final RxList<Filter> filters;
  final Function(List<Filter>) onFiltersChanged;

  const _SearchControlsSection({
    required this.selectedSegment,
    required this.onSegmentChanged,
    required this.onSearch,
    required this.filters,
    required this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Obx(() => SearchSegmentSelector(
            selectedSegment: selectedSegment.value,
            onSegmentChanged: onSegmentChanged,
            showLabel: true,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            elevation: 1,
          )),
          const SizedBox(width: 8),
          Obx(() => FilterButtonWidget(
            currentSegment: selectedSegment.value,
            filters: filters.toList(),
            onFiltersChanged: onFiltersChanged,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            elevation: 1,
          )),
          const SizedBox(width: 8),
          SearchButton(
            onSearch: onSearch,
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: 1,
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
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
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.search.searchHistory,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RecordingToggleButton(userPreferenceService: userPreferenceService),
              if (userPreferenceService.videoSearchHistory.isNotEmpty) ...[
                const SizedBox(width: 8),
                _ClearHistoryButton(onClearHistory: onClearHistory),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _RecordingToggleButton extends StatelessWidget {
  final UserPreferenceService userPreferenceService;

  const _RecordingToggleButton({required this.userPreferenceService});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    
    return Obx(() => Material(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          userPreferenceService.setSearchRecordEnabled(
            !userPreferenceService.searchRecordEnabled.value,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                userPreferenceService.searchRecordEnabled.value
                    ? Icons.history
                    : Icons.history_toggle_off,
                size: 18,
                color: userPreferenceService.searchRecordEnabled.value
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                userPreferenceService.searchRecordEnabled.value
                    ? t.common.recording
                    : t.common.paused,
                style: TextStyle(
                  fontSize: 14,
                  color: userPreferenceService.searchRecordEnabled.value
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    ));
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
    
    return ListTile(
      leading: const Icon(Icons.history),
      title: Text(record.keyword),
      subtitle: Text(
        '${t.search.usedTimes}: ${record.usedTimes} · ${t.search.lastUsed}: ${record.lastUsedAt.toString().split('.')[0]}',
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 18),
        onPressed: onRemove,
      ),
      onTap: onTap,
    );
  }
}
