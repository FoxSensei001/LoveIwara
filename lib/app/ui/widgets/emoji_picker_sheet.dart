import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/widgets/emoji_picker_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/common/enums/emoji_size_enum.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/emoji_library_service.dart';
import 'package:get/get.dart' hide Translations;
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';

class EmojiPickerSheet extends StatefulWidget {
  final Function(String imageUrl, EmojiSize size) onEmojiSelected;
  final EmojiSize initialSize;
  final Function(EmojiSize) onSizeChanged;

  const EmojiPickerSheet({
    super.key,
    required this.onEmojiSelected,
    this.initialSize = EmojiSize.medium,
    required this.onSizeChanged,
  });

  @override
  State<EmojiPickerSheet> createState() => _EmojiPickerSheetState();
}

class _EmojiPickerSheetState extends State<EmojiPickerSheet>
    with SingleTickerProviderStateMixin {
  late EmojiSize _selectedSize;
  late EmojiLibraryService _emojiService;
  late TabController _tabController;
  List<EmojiGroup> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.initialSize;
    _emojiService = Get.find<EmojiLibraryService>();
    _loadData();
  }

  void _loadData() async {
    try {
      _groups = _emojiService.getEmojiGroups();
      if (_groups.isNotEmpty) {
        _tabController = TabController(length: _groups.length, vsync: this);
      } else {
        _tabController = TabController(length: 1, vsync: this);
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _tabController = TabController(length: 1, vsync: this);
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

  void _handleEmojiSelected(String imageUrl) {
    widget.onEmojiSelected(imageUrl, _selectedSize);
  }

  void _handleSizeChanged(EmojiSize size) {
    setState(() {
      _selectedSize = size;
    });
    widget.onSizeChanged(size);
  }

  /// 尺寸选择钮：玻璃胶囊，点按弹出贴近触发件的玻璃菜单（[showGlassMenu]），
  /// 拥有长按开菜单 + 手指接力选中能力，与播放器倍速菜单保持一致的交互体验。
  Widget _buildSizePill(BuildContext context, ColorScheme cs) {
    return Builder(
      builder: (anchorContext) => GlassSurface(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        opensOverlay: true,
        onTap: () async {
          final picked = await showGlassMenu<EmojiSize>(
            anchorContext: anchorContext,
            entries: [
              for (final size in EmojiSize.values)
                GlassMenuOption<EmojiSize>(
                  value: size,
                  label: size.displayName,
                  selected: size == _selectedSize,
                ),
            ],
          );
          if (picked != null) {
            _handleSizeChanged(picked);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedSize.displayName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.expand_more, size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  /// 标题行的动作区：尺寸胶囊 / 设置 / 关闭。
  ///
  /// 液态档由 `showGlassBottomSheet` 在路由层供——本弹层是自建壳
  /// （`DraggableScrollableSheet` + 自己的 `Container`），不走 `GlassBottomSheet`，
  /// 所以必须从那个入口打开，裸 `showModalBottomSheet` 开出来会整只落回传统档。
  Widget _buildHeaderActions(BuildContext context, ColorScheme cs) {
    final t = Translations.of(context);
    return Row(
      children: [
        _buildSizePill(context, cs),
        const Spacer(),
        GlassIconButton(
          standalone: true,
          icon: const Icon(Icons.settings),
          tooltip: t.settings.settings,
          onPressed: () {
            Navigator.pop(context);
            NaviService.navigateToEmojiLibraryPage();
          },
        ),
        const SizedBox(width: 8),
        GlassIconButton(
          standalone: true,
          icon: const Icon(Icons.close),
          tooltip: t.common.close,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        if (_isLoading) {
          // Shimmer 骨架屏
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                // 拖拽条与标题栏共用同一块底色（同一个 Container），不能分开画：
                // 分开画的话拖拽条露的是外层 cs.surface，标题栏是叠了一层
                // surfaceContainerHighest 的淡灰——两截颜色对不上，接缝很难看。
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 12),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 100,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          const Spacer(),
                          ...List.generate(
                            2,
                            (i) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          border: Border(
                            right: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: 8,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              padding: const EdgeInsets.all(8),
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
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
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
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final cs = Theme.of(context).colorScheme;

        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          // 让内容避开系统手势条/导航条，背景仍然铺到屏幕底部
          padding: EdgeInsets.only(bottom: computeSheetBottomInset(context)),
          child: Column(
            children: [
              // 拖拽条与标题栏共用同一块底色（同一个 Container），不能分开画：
              // 分开画的话拖拽条露的是外层 cs.surface，标题栏是叠了一层
              // surfaceContainerHighest 的淡灰——两截颜色对不上，接缝很难看。
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // 标题行：左上角尺寸选择钮（打开全站通用弹窗，而不是原生
                    // DropdownButton 那种孤立的系统菜单）/ 右侧玻璃圆钮，
                    // 与全站其它弹窗标题行动作键同一约定
                    _buildHeaderActions(context, cs),
                  ],
                ),
              ),

              // 移除窄屏下方的尺寸选择行（统一使用左上角选择钮）

              // 表情包选择器主体区域
              Expanded(
                child: RepaintBoundary(
                  child: Row(
                    children: [
                      // 左侧分组导航 rail
                      if (_groups.isNotEmpty)
                        Container(
                          width: 80,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.3),
                            border: Border(
                              right: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              bottom: 16,
                            ), // 底部留出 padding
                            child: EmojiPickerWidget(
                              onEmojiSelected: _handleEmojiSelected,
                              showOnlyTabs: true, // 只显示标签页，不显示内容
                              isRailMode: true, // 新增参数，表示 rail 模式
                              tabController:
                                  _tabController, // 传递共享的 TabController
                            ),
                          ),
                        ),
                      // 右侧表情包内容区域
                      Expanded(
                        child: EmojiPickerWidget(
                          onEmojiSelected: _handleEmojiSelected,
                          showOnlyContent: true, // 只显示内容，不显示标签页
                          scrollController: scrollController,
                          tabController: _tabController, // 传递共享的 TabController
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/*
使用示例：

// 显示表情选择器
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => EmojiPickerSheet(
    initialSize: EmojiSize.medium, // 初始选中的规格
    onEmojiSelected: (imageUrl, size) {
      // 处理表情包选择
      print('选择了表情包: $imageUrl, 规格: ${size.displayName}');
      Navigator.pop(context);
    },
    onSizeChanged: (size) {
      // 处理规格变化
      print('规格变更为: ${size.displayName}');
    },
  ),
);

// 在其他地方也可以使用，比如评论输入、论坛发帖等
*/
