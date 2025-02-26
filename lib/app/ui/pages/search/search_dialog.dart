import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/global_search_service.dart';
import 'package:i_iwara/app/services/user_preference_service.dart';
import 'package:i_iwara/app/ui/widgets/link_input_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:url_launcher/url_launcher.dart';

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
  final TextEditingController _googleSearchController = TextEditingController();
  final FocusNode _focusNode = FocusNode(); // 添加 FocusNode
  late GlobalSearchService globalSearchService;
  late UserPreferenceService userPreferenceService;
  
  // 是否展开谷歌搜索辅助面板
  bool _isGoogleSearchPanelExpanded = false;
  
  // 滚动控制器，用于在展开谷歌搜索面板时自动滚动
  final ScrollController _scrollController = ScrollController();

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
  
  // 展开或收起谷歌搜索面板
  void _toggleGoogleSearchPanel() {
    setState(() {
      _isGoogleSearchPanelExpanded = !_isGoogleSearchPanelExpanded;
    });
    
    // 如果是展开面板，延迟滚动到面板位置，确保UI已更新
    if (_isGoogleSearchPanelExpanded) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          // 计算谷歌搜索面板的大致位置并滚动到那里
          final offset = _scrollController.position.pixels + 100.0;
          _scrollController.animateTo(
            offset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
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
  
  // 执行谷歌搜索
  void _performGoogleSearch() async {
    if (_googleSearchController.text.isEmpty) {
      showToastWidget(
        MDToastWidget(
          // message: "请输入搜索关键词",
          message: slang.t.search.pleaseEnterSearchKeywords,
          type: MDToastType.warning,
        ), 
        position: ToastPosition.top
      );
      return;
    }
    
    final keyword = _googleSearchController.text.trim();
    final searchQuery = "$keyword site:${CommonConstants.iwaraDomain}";
    
    // 复制到剪贴板
    await Clipboard.setData(ClipboardData(text: searchQuery));
    showToastWidget(
      MDToastWidget(
        message: slang.t.search.googleSearchQueryCopied,
        type: MDToastType.success,
      ), 
      position: ToastPosition.top
    );
    
    // 构建谷歌搜索URL
    final encodedQuery = Uri.encodeComponent(searchQuery);
    final url = Uri.parse("https://www.google.com/search?q=$encodedQuery");
    
    // 打开浏览器搜索
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      showToastWidget(
        MDToastWidget(
          message: slang.t.search.googleSearchBrowserOpenFailed(error: e.toString()),
          type: MDToastType.error,
        ), 
        position: ToastPosition.top
      );
    }
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
                          selected: {globalSearchService.selectedSegment.value},
                          onSelectionChanged: (Set<String> selection) {
                            if (selection.isNotEmpty) {
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
                ),
                
                // 谷歌搜索辅助功能
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                  child: Card(
                    clipBehavior: Clip.hardEdge,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    elevation: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 标题部分，可点击展开/收起
                        InkWell(
                          onTap: _toggleGoogleSearchPanel,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.search.googleSearch,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        t.search.googleSearchHint(webName: CommonConstants.webName),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  _isGoogleSearchPanelExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // 展开的内容部分
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: SizedBox(
                            height: _isGoogleSearchPanelExpanded ? null : 0,
                            child: FadeTransition(
                              opacity: CurvedAnimation(
                                parent: AlwaysStoppedAnimation(_isGoogleSearchPanelExpanded ? 1.0 : 0.0),
                                curve: Curves.easeInOut,
                              ),
                              child: _isGoogleSearchPanelExpanded ? Padding(
                                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 12,
                                  children: [
                                    Text(
                                      t.search.googleSearchDescription,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    TextField(
                                      controller: _googleSearchController,
                                      decoration: InputDecoration(
                                        hintText: t.search.googleSearchKeywordsHint,
                                        border: const OutlineInputBorder(),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                    Wrap(
                                      spacing: 8.0, // 水平间距
                                      runSpacing: 8.0, // 垂直间距
                                      children: [
                                        OutlinedButton.icon(
                                          icon: const Icon(Icons.link),
                                          label: Text(t.search.openLinkJump),
                                          onPressed: () {
                                            LinkInputDialogWidget.show();
                                          },
                                        ),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.search),
                                          label: Text(t.search.googleSearchButton),
                                          onPressed: _performGoogleSearch,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ) : const SizedBox(),
                            ),
                          ),
                        ),
                      ],
                    ),
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
    _googleSearchController.dispose();
    _focusNode.dispose();
    _scrollController.dispose(); // 释放滚动控制器
    globalSearchService.clearSearchError();
    super.dispose();
  }
}
