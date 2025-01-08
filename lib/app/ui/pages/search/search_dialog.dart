import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/global_search_service.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

enum SearchSegment {
  video,
  image,
  post,
  user,
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
  final FocusNode _focusNode = FocusNode(); // 添加 FocusNode
  late GlobalSearchService globalSearchService;
  late UserPreferenceService userPreferenceService;

  @override
  void initState() {
    super.initState();
    globalSearchService = Get.find<GlobalSearchService>();
    userPreferenceService = Get.find<UserPreferenceService>();
    globalSearchService.clearSearchError();

    // 设置初始搜索内容和 segment
    _controller.text = widget.initialSearch;
    globalSearchService.selectedSegment.value = widget.initialSegment.name;

    // 更新搜索建议
    globalSearchService
        .updateSearchPlaceholder(userPreferenceService.videoSearchHistory);
  }

  void _removeHistoryItem(int index) {
    final record = userPreferenceService.videoSearchHistory[index];
    userPreferenceService.removeVideoSearchHistory(record.keyword);
  }

  void _clearHistory() {
    userPreferenceService.clearVideoSearchHistory();
  }

  void _handleSubmit(String value) {
    globalSearchService.clearSearchError();

    if (value.isEmpty) {
      if (globalSearchService.searchPlaceholder.isNotEmpty) {
        _controller.text = globalSearchService.searchPlaceholder.value;
        _focusNode.requestFocus(); // 重新聚焦 TextField
      } else {
        globalSearchService.setSearchError(slang.t.search.pleaseEnterSearchContent);
      }
      return;
    }

    if (userPreferenceService.searchRecordEnabled.value &&
        value != globalSearchService.currentSearch.value) {
      userPreferenceService.addVideoSearchHistory(value);
    }

    LogUtils.d('搜索内容: $value, 类型: ${globalSearchService.selectedSegment}');
    globalSearchService.currentSearch.value = value;
    _dismiss();
    widget.onSearch(value, globalSearchService.selectedSegment.value);
  }

  void _dismiss() {
    AppService.tryPop();
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    double width = MediaQuery.of(context).size.width;
    bool isWide = width > 600;

    Widget historyHeader = Padding(
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
    );

    Widget searchContent = Material(
      color: Colors.transparent,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              child: Obx(() => TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    // 绑定 FocusNode
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: globalSearchService
                              .searchPlaceholder.value.isEmpty
                          ? t.search.pleaseEnterSearchContent
                          : '${t.search.searchSuggestion}: ${globalSearchService.searchPlaceholder.value}',
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
                              globalSearchService.clearSearchError();
                              globalSearchService.searchPlaceholder.value = '';
                              _focusNode.requestFocus(); // 重新聚焦 TextField
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
                          globalSearchService.searchErrorText.value.isEmpty
                              ? null
                              : globalSearchService.searchErrorText.value,
                    ),
                    onChanged: (value) {
                      globalSearchService.clearSearchError();
                    },
                    onSubmitted: _handleSubmit,
                  )),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Obx(() => SegmentedButton<String>(
                  // 添加 Obx 包装
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
                  ],
                  selected: {globalSearchService.selectedSegment.value},
                  onSelectionChanged: (Set<String> selection) {
                    if (selection.isNotEmpty) {
                      // 添加空值检查
                      globalSearchService.selectedSegment.value =
                          selection.first;
                    }
                  },
                  multiSelectionEnabled: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )),
          ),
          historyHeader,
          Expanded(
            child: Obx(
              () => userPreferenceService.videoSearchHistory.isEmpty
                  ? Center(
                      child: Text(t.search.noSearchHistoryRecords),
                    )
                  : ListView.builder(
                      itemCount:
                          userPreferenceService.videoSearchHistory.length,
                      itemBuilder: (context, index) {
                        final record =
                            userPreferenceService.videoSearchHistory[index];
                        return ListTile(
                          leading: const Icon(Icons.history),
                          title: Text(record.keyword),
                          subtitle: Text(
                            '${t.search.usedTimes}: ${record.usedTimes} · ${t.search.lastUsed}: ${record.lastUsedAt.toString().split('.')[0]}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
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
                    ),
            ),
          ),
        ],
      ),
    );

    if (isWide) {
      return Expanded(
        child: searchContent, // 直接返回搜索内容，不需要额外的容器
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
    _focusNode.dispose(); // 释放 FocusNode
    globalSearchService.clearSearchError();
    super.dispose();
  }
}
