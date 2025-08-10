import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/emoji_library_service.dart';

class EmojiPickerWidget extends StatefulWidget {
  final Function(String) onEmojiSelected;
  final bool showOnlyTabs;
  final bool showOnlyContent;
  final ScrollController? scrollController;
  final bool isRailMode;

  const EmojiPickerWidget({
    super.key,
    required this.onEmojiSelected,
    this.showOnlyTabs = false,
    this.showOnlyContent = false,
    this.scrollController,
    this.isRailMode = false,
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

  @override
  void initState() {
    super.initState();
    _emojiService = Get.find<EmojiLibraryService>();
    _loadData();
  }

  void _loadData() async {
    try {
      _groups = _emojiService.getEmojiGroups();
      if (_groups.isNotEmpty) {
        _tabController = TabController(length: _groups.length, vsync: this);
        _currentTabIndex = _tabController.index;
        _tabController.addListener(() {
          if (mounted) {
            setState(() {
              _currentTabIndex = _tabController.index;
            });
          }
        });
        
        for (final group in _groups) {
          _groupImages[group.groupId] = _emojiService.getEmojiImages(group.groupId);
        }
      } else {
        _tabController = TabController(length: 1, vsync: this);
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_groups.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_emotions_outlined,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                '暂无表情包',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '前往设置添加表情包',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 只显示标签页
    if (widget.showOnlyTabs) {
      if (widget.isRailMode) {
        // Rail 模式：垂直布局，只显示头图
        return ListView.builder(
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
                        child: Image.network(
                          group.coverUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  group.name.isNotEmpty ? group.name[0] : '?',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            group.name.isNotEmpty ? group.name[0] : '?',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        // 原来的水平 TabBar 模式
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            tabs: _groups.map((group) {
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (group.coverUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          group.coverUrl!,
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  group.name.isNotEmpty ? group.name[0] : '?',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            group.name.isNotEmpty ? group.name[0] : '?',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    const SizedBox(width: 6),
                    Text(
                      group.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      }
    }

    // 只显示内容
    if (widget.showOnlyContent) {
      return TabBarView(
        controller: _tabController,
        children: _groups.asMap().entries.map((entry) {
          final int pageIndex = entry.key;
          final group = entry.value;
          final images = _groupImages[group.groupId] ?? [];
          if (images.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_emotions_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '该分组暂无表情包',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            controller: widget.scrollController != null && pageIndex == _currentTabIndex
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
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.network(
                      image.thumbnailUrl ?? image.url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      );
    }

    // 完整显示（标签页 + 内容）
    return Column(
      children: [
        // 标签栏
        if (_groups.length > 1)
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: _groups.map((group) {
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (group.coverUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            group.coverUrl!,
                            width: 20,
                            height: 20,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                group.name.isNotEmpty ? group.name[0] : '?',
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          ),
                        )
                      else
                        Text(
                          group.name.isNotEmpty ? group.name[0] : '?',
                          style: const TextStyle(fontSize: 12),
                        ),
                      const SizedBox(width: 4),
                      Text(group.name),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        // 表情包网格
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _groups.asMap().entries.map((entry) {
              final int pageIndex = entry.key;
              final group = entry.value;
              final images = _groupImages[group.groupId] ?? [];
              if (images.isEmpty) {
                return const Center(
                  child: Text(
                    '该分组暂无表情包',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              
              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                controller: widget.scrollController != null && pageIndex == _currentTabIndex
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
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.network(
                          image.thumbnailUrl ?? image.url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}