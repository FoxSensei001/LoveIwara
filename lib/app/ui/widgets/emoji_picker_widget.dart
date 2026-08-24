// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Translations;
import 'package:i_iwara/app/services/emoji_library_service.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EmojiPickerWidget extends StatefulWidget {
  final Function(String) onEmojiSelected;
  final bool showOnlyTabs;
  final bool showOnlyContent;
  final ScrollController? scrollController;
  final bool isRailMode;
  final TabController? tabController; // 新增：外部传入的 TabController

  const EmojiPickerWidget({
    super.key,
    required this.onEmojiSelected,
    this.showOnlyTabs = false,
    this.showOnlyContent = false,
    this.scrollController,
    this.isRailMode = false,
    this.tabController, // 新增参数
  });

  @override
  State<EmojiPickerWidget> createState() => _EmojiPickerWidgetState();
}

class _EmojiPickerWidgetState extends State<EmojiPickerWidget>
    with SingleTickerProviderStateMixin {
  late EmojiLibraryService _emojiService;
  late TabController _tabController;
  List<EmojiGroup> _groups = [];
  final Map<int, List<EmojiImage>> _groupImages = {};
  bool _isLoading = true;
  int _currentTabIndex = 0;
  bool _isExternalController = false; // 标记是否使用外部控制器

  @override
  void initState() {
    super.initState();
    _emojiService = Get.find<EmojiLibraryService>();

    // 如果外部传入了 TabController，使用外部的
    if (widget.tabController != null) {
      _tabController = widget.tabController!;
      _isExternalController = true;
    }
    _loadData();
  }

  void _onTabChanged() {
    if (!mounted) return;
    if (_tabController.index != _currentTabIndex && !_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    }
  }

  void _loadData() {
    try {
      _groups = _emojiService.getEmojiGroups();
      if (_groups.isNotEmpty) {
        if (!_isExternalController) {
          _tabController = TabController(length: _groups.length, vsync: this);
        }
        _currentTabIndex = _tabController.index.clamp(0, _groups.length - 1);
        _tabController.removeListener(_onTabChanged);
        _tabController.addListener(_onTabChanged);

        // 如果不是仅显示标签页，按需预加载当前选中的分组
        if (!widget.showOnlyTabs && _groups.isNotEmpty) {
          final initialGroupId = _groups[_currentTabIndex].groupId;
          _groupImages[initialGroupId] = _emojiService.getEmojiImages(initialGroupId);
        }
      } else {
        if (!_isExternalController) {
          _tabController = TabController(length: 1, vsync: this);
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!_isExternalController) {
        _tabController = TabController(length: 1, vsync: this);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    if (_groups.isNotEmpty || !_isExternalController) {
      _tabController.removeListener(_onTabChanged);
    }
    // 只有非外部控制器才需要释放
    if (!_isExternalController) {
      _tabController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    if (_isLoading) {
      // 使用 Shimmer 骨架屏
      // 当前唯一调用方 EmojiPickerSheet 里 showOnlyTabs 恒配合 isRailMode: true
      // 使用，水平 TabBar 骨架分支已作为死代码删除。
      if (widget.showOnlyTabs && widget.isRailMode) {
        // Rail 模式：垂直头像骨架
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: 8,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            );
          },
        );
      }

      // 内容网格骨架
      return GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 16,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
      );
    }

    if (_groups.isEmpty) {
      // 如果只显示标签页，并且没有分组，则返回一个空容器
      if (widget.showOnlyTabs) {
        return const SizedBox.shrink();
      }

      // 否则，显示“暂无表情”的提示
      final cs = Theme.of(context).colorScheme;
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_emotions_outlined,
                size: 48,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                t.emoji.noEmojis,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                t.emoji.goToSettingsToAddEmojis,
                style: TextStyle(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 只显示标签页（同上，水平 TabBar 分支已作为死代码删除）
    if (widget.showOnlyTabs && widget.isRailMode) {
      // Rail 模式：垂直布局，只显示头图
      return RepaintBoundary(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _groups.length,
          itemBuilder: (context, index) {
            final group = _groups[index];
            final isSelected = _tabController.index == index;

            return GestureDetector(
              onTap: () {
                _tabController.animateTo(index);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 头图
                    if (group.coverUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: group.coverUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                group.name.isNotEmpty ? group.name[0] : '?',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            group.name.isNotEmpty ? group.name[0] : '?',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    // 只显示内容
    if (widget.showOnlyContent) {
      return TabBarView(
        controller: _tabController,
        children: _groups.asMap().entries.map((entry) {
          final int pageIndex = entry.key;
          final group = entry.value;
          final images = _groupImages.putIfAbsent(
            group.groupId,
            () => _emojiService.getEmojiImages(group.groupId),
          );
          if (images.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_emotions_outlined,
                    size: 48,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.emoji.noEmojisInGroup,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return RepaintBoundary(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              controller:
                  widget.scrollController != null && pageIndex == _currentTabIndex
                  ? widget.scrollController
                  : null,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                return GestureDetector(
                  onTap: () => widget.onEmojiSelected(image.url),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: CachedNetworkImage(
                        imageUrl: image.thumbnailUrl ?? image.url,
                        fit: BoxFit.cover,
                        httpHeaders: const {
                          'referer': CommonConstants.iwaraBaseUrl,
                        },
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(color: Colors.white),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          child: Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
      );
    }

    // 兜底：唯一调用方 EmojiPickerSheet 恒传 showOnlyTabs 或 showOnlyContent
    // 二选一，不会同时为 false；原先这里的"标签页+内容一体"横向 TabBar 布局
    // 是死代码（永远走不到），已删除。保留断言便于未来误用时尽早暴露。
    assert(
      false,
      'EmojiPickerWidget 需要 showOnlyTabs 或 showOnlyContent 至少一个为 true',
    );
    return const SizedBox.shrink();
  }
}
