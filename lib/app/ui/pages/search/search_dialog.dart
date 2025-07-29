import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/ui/widgets/google_search_panel_widget.dart';
import 'dart:math';
import 'package:i_iwara/app/models/search_record.model.dart';

enum SearchSegment {
  video,
  image,
  post,
  user,
  forum,
  ;

  static SearchSegment fromValue(String value) {
    return SearchSegment.values.firstWhere((element) => element.name == value,
        orElse: () => SearchSegment.video);
  }
}

class SearchDialog extends StatelessWidget {
  final String initialSearch;
  final SearchSegment initialSegment;
  final Function(String, String) onSearch;

  const SearchDialog(
      {super.key,
      required this.initialSearch,
      required this.initialSegment,
      required this.onSearch});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 600) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 800,
            minWidth: 400,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t.common.search,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 搜索内容
                _SearchContent(
                    initialSearch: initialSearch,
                    initialSegment: initialSegment,
                    onSearch: onSearch),
              ],
            ),
          ),
        ),
      );
    } else {
      // 对于窄屏幕，显示为全屏模态
      return Scaffold(
        appBar: AppBar(
          title: Text(t.common.search),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: _SearchContent(
            initialSearch: initialSearch,
            initialSegment: initialSegment,
            onSearch: onSearch),
      );
    }
  }
}

class _SearchContent extends StatefulWidget {
  final String initialSearch;
  final SearchSegment initialSegment;
  final Function(String, String) onSearch;

  const _SearchContent(
      {required this.initialSearch,
      required this.initialSegment,
      required this.onSearch});

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
  final RxString _selectedSegment = 'video'.obs;
  
  // 滚动控制器，用于在展开谷歌搜索面板时自动滚动
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    userPreferenceService = Get.find<UserPreferenceService>();
    
    // 设置初始搜索内容和 segment
    _controller.text = widget.initialSearch;
    _selectedSegment.value = widget.initialSegment.name;

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
        _focusNode.requestFocus(); // 重新聚焦 TextField
      } else {
        _searchErrorText.value = slang.t.search.pleaseEnterSearchContent;
      }
      return;
    }

    if (userPreferenceService.searchRecordEnabled.value) {
      userPreferenceService.addVideoSearchHistory(value);
    }

    LogUtils.d('搜索内容: $value, 类型: ${_selectedSegment.value}');
    _dismiss();
    widget.onSearch(value, _selectedSegment.value);
  }

  void _dismiss() {
    AppService.tryPop();
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    double width = MediaQuery.of(context).size.width;
    bool isWide = width > 600;
    
    // 构建搜索内容
    Widget searchContent = LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: _scrollController,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Column(
              children: [
                // 搜索输入框
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(8),
                    child: Obx(() => TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          autofocus: true,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          decoration: InputDecoration(
                            hintText: _searchPlaceholder.value.isEmpty
                                ? t.search.pleaseEnterSearchContent
                                : '${t.search.searchSuggestion}: ${_searchPlaceholder.value}',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontWeight: FontWeight.normal,
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _controller.clear();
                                    _searchErrorText.value = '';
                                    _searchPlaceholder.value = '';
                                    _focusNode.requestFocus();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.search),
                                  onPressed: () => _handleSubmit(_controller.text),
                                ),
                              ],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error,
                                width: 2,
                              ),
                            ),
                            errorText:
                                _searchErrorText.value.isEmpty
                                    ? null
                                    : _searchErrorText.value,
                          ),
                          onChanged: (value) {
                            _searchErrorText.value = '';
                          },
                          onSubmitted: _handleSubmit,
                        )),
                  ),
                ),
                
                // 分类选项卡
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Obx(() => SegmentedButton<String>(
                          segments: [
                            ButtonSegment(
                              value: SearchSegment.video.name,
                              icon: const Icon(Icons.video_library),
                            ),
                            ButtonSegment(
                              value: SearchSegment.image.name,
                              icon: const Icon(Icons.image),
                            ),
                            ButtonSegment(
                              value: SearchSegment.post.name,
                              icon: const Icon(Icons.article),
                            ),
                            ButtonSegment(
                              value: SearchSegment.user.name,
                              icon: const Icon(Icons.person),
                            ),
                            ButtonSegment(
                              value: SearchSegment.forum.name,
                              icon: const Icon(Icons.forum),
                            ),
                          ],
                          selected: {_selectedSegment.value},
                          onSelectionChanged: (Set<String> selection) {
                            if (selection.isNotEmpty) {
                              _selectedSegment.value = selection.first;
                            }
                          },
                          multiSelectionEnabled: false,
                          style: const ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        )),
                  ),
                ),
                
                // 谷歌搜索辅助功能
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                  child: GoogleSearchPanelWidget(
                    scrollController: _scrollController,
                  ),
                ),
                
                // 历史记录标题
                Padding(
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
                          Obx(() => Material(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    userPreferenceService.setSearchRecordEnabled(
                                        !userPreferenceService.searchRecordEnabled.value);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          userPreferenceService.searchRecordEnabled.value
                                              ? Icons.history
                                              : Icons.history_toggle_off,
                                          size: 18,
                                          color: userPreferenceService
                                                  .searchRecordEnabled.value
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
                                            color: userPreferenceService
                                                    .searchRecordEnabled.value
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                          if (userPreferenceService.videoSearchHistory.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: _clearHistory,
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: Text(t.common.clear),
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 历史记录列表
                Obx(() {
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
                      return ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(record.keyword),
                        subtitle: Text(
                          '${t.search.usedTimes}: ${record.usedTimes} · ${t.search.lastUsed}: ${record.lastUsedAt.toString().split('.')[0]}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => _removeHistoryItem(index),
                        ),
                        onTap: () {
                          _controller.text = record.keyword;
                          _focusNode.requestFocus(); // 重新聚焦 TextField
                        },
                      );
                    },
                  );
                }),
                
                // 底部空白区域，确保滚动内容可见
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }
    );

    if (isWide) {
      return Expanded(
        child: searchContent,
      );
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
