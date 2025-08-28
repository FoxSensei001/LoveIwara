import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/ui/widgets/link_input_dialog_widget.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 搜索类型枚举
enum SearchType {
  all,
  video,
  image,
  user,
  playlist,
  forum,
  post,
}

/// 搜索类型扩展
extension SearchTypeExtension on SearchType {
  String get path {
    switch (this) {
      case SearchType.all:
        return '';
      case SearchType.video:
        return '/video';
      case SearchType.image:
        return '/image';
      case SearchType.user:
        return '/user';
      case SearchType.playlist:
        return '/playlist';
      case SearchType.forum:
        return '/forum';
      case SearchType.post:
        return '/post';
    }
  }
  
  String getDisplayName(BuildContext context) {
    switch (this) {
      case SearchType.all:
        return t.common.all;
      case SearchType.video:
        return t.common.video;
      case SearchType.image:
        return t.common.gallery;
      case SearchType.user:
        return t.common.user;
      case SearchType.playlist:
        return t.common.playlist;
      case SearchType.forum:
        return t.forum.forum;
      case SearchType.post:
        return t.common.post;
    }
  }
  
  IconData get icon {
    switch (this) {
      case SearchType.all:
        return Icons.search;
      case SearchType.video:
        return Icons.video_library;
      case SearchType.image:
        return Icons.image;
      case SearchType.user:
        return Icons.person;
      case SearchType.playlist:
        return Icons.playlist_play;
      case SearchType.forum:
        return Icons.forum;
      case SearchType.post:
        return Icons.article;
    }
  }
}

/// 谷歌搜索辅助面板组件
class GoogleSearchPanelWidget extends StatefulWidget {
  const GoogleSearchPanelWidget({
    super.key,
    this.scrollController,
  });

  /// 滚动控制器，用于在展开谷歌搜索面板时自动滚动
  final ScrollController? scrollController;

  @override
  State<GoogleSearchPanelWidget> createState() => _GoogleSearchPanelWidgetState();
}

class _GoogleSearchPanelWidgetState extends State<GoogleSearchPanelWidget> {
  /// 是否展开谷歌搜索辅助面板
  bool _isGoogleSearchPanelExpanded = false;
  
  /// 谷歌搜索输入控制器
  final TextEditingController _googleSearchController = TextEditingController();
  
  /// 当前选择的搜索类型
  SearchType _selectedSearchType = SearchType.all;

  @override
  void dispose() {
    _googleSearchController.dispose();
    super.dispose();
  }
  
  /// 展开或收起谷歌搜索面板
  void _toggleGoogleSearchPanel() {
    setState(() {
      _isGoogleSearchPanelExpanded = !_isGoogleSearchPanelExpanded;
    });
    
    // 如果是展开面板，延迟滚动到面板位置，确保UI已更新
    if (_isGoogleSearchPanelExpanded && widget.scrollController != null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (widget.scrollController!.hasClients) {
          // 计算谷歌搜索面板的大致位置并滚动到那里
          final offset = widget.scrollController!.position.pixels + 100.0;
          widget.scrollController!.animateTo(
            offset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }
  
  /// 执行谷歌搜索
  void _performGoogleSearch() async {
    final t = slang.Translations.of(context);
    
    if (_googleSearchController.text.isEmpty) {
      showToastWidget(
        MDToastWidget(
          message: t.search.pleaseEnterSearchKeywords,
          type: MDToastType.warning,
        ), 
        position: ToastPosition.top
      );
      return;
    }
    
    final keyword = _googleSearchController.text.trim();
    final pathSuffix = _selectedSearchType.path;
    final searchQuery = "$keyword site:${CommonConstants.iwaraBaseUrl}$pathSuffix";
    
    // 复制到剪贴板
    await Clipboard.setData(ClipboardData(text: searchQuery));
    showToastWidget(
      MDToastWidget(
        message: t.search.googleSearchQueryCopied,
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
          message: t.search.googleSearchBrowserOpenFailed(error: e.toString()),
          type: MDToastType.error,
        ), 
        position: ToastPosition.top
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
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
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.search.googleSearch,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.search.googleSearchHint(webName: CommonConstants.webName),
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isGoogleSearchPanelExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: colorScheme.primary,
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        t.search.googleSearchDescription,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // MD3风格的搜索输入框
                      TextField(
                        controller: _googleSearchController,
                        decoration: InputDecoration(
                          hintText: t.search.googleSearchKeywordsHint,
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 搜索类型选择器 - 使用SegmentedButton
                      Text(
                        t.search.googleSearchScope,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: SearchType.values.map((type) {
                          return FilterChip(
                            selected: _selectedSearchType == type,
                            label: Text(type.getDisplayName(context)),
                            avatar: Icon(
                              type.icon,
                              size: 18,
                              color: _selectedSearchType == type
                                  ? colorScheme.onSecondaryContainer
                                  : colorScheme.onSurfaceVariant,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedSearchType = type;
                                });
                              }
                            },
                            selectedColor: colorScheme.secondaryContainer,
                            backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            checkmarkColor: colorScheme.onSecondaryContainer,
                            showCheckmark: false,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // 当宽度小于300时使用垂直布局
                          if (constraints.maxWidth < 300) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.link),
                                  label: Text(t.search.openLinkJump),
                                  onPressed: () {
                                    LinkInputDialogWidget.show();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                FilledButton.icon(
                                  icon: const Icon(Icons.search),
                                  label: Text(t.search.googleSearchButton),
                                  onPressed: _performGoogleSearch,
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // 宽屏使用水平布局
                            return Row(
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.link),
                                  label: Text(t.search.openLinkJump),
                                  onPressed: () {
                                    LinkInputDialogWidget.show();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FilledButton.icon(
                                    icon: const Icon(Icons.search),
                                    label: Text(t.search.googleSearchButton),
                                    onPressed: _performGoogleSearch,
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ) : const SizedBox(),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 