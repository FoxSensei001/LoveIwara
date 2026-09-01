import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Translations;
import 'package:i_iwara/app/services/emoji_library_service.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/common/constants.dart';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/ui/widgets/glass/batch_confirm_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_overflow_menu_button.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_selection.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/app_toast.dart';

class EmojiGroupDetailSheet extends StatefulWidget {
  final EmojiGroup group;

  const EmojiGroupDetailSheet({super.key, required this.group});

  @override
  State<EmojiGroupDetailSheet> createState() => _EmojiGroupDetailSheetState();
}

class _EmojiGroupDetailSheetState extends State<EmojiGroupDetailSheet> {
  late EmojiLibraryService _emojiService;
  List<EmojiImage> _images = [];
  bool _isLoading = true;
  bool _isSelectionMode = false;
  Set<int> _selectedImages = {};

  @override
  void initState() {
    super.initState();
    _emojiService = Get.find<EmojiLibraryService>();
    _loadImages();
  }

  void _loadImages() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      final images = _emojiService.getEmojiImages(widget.group.groupId);
      setState(() {
        _images = images;
        _isLoading = false;
      });
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedImages.clear();
      }
    });
  }

  void _toggleImageSelection(int imageId) {
    setState(() {
      if (_selectedImages.contains(imageId)) {
        _selectedImages.remove(imageId);
      } else {
        _selectedImages.add(imageId);
      }
    });
  }

  void _selectAllImages() {
    setState(() {
      _selectedImages = _images.map((img) => img.imageId).toSet();
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedImages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    // 选择态：动作行由底部玻璃坞承载，与全站其它九处批量能力同一套语言。
    // 系统返回 / iOS 侧滑 / Esc 先退选择态，而不是把整只弹窗关掉。
    return BatchSelectionScope(
      active: _isSelectionMode,
      selectedCount: _selectedImages.length,
      actions: [
        GlassSelectionAction(
          icon: Icons.delete,
          label: t.emoji.delete,
          destructive: true,
          onPressed: _selectedImages.isEmpty ? null : _showBatchDeleteDialog,
        ),
      ],
      onClear: _clearSelection,
      child: SelectionPopScope(
        active: _isSelectionMode,
        onExit: _toggleSelectionMode,
        child: _buildSheet(context),
      ),
    );
  }

  Widget _buildSheet(BuildContext context) {
    final t = Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      // 底部弹窗自己让出系统手势条/导航条
      padding: EdgeInsets.only(bottom: computeSheetBottomInset(context)),
      child: Column(
        children: [
          // 顶部拖拽指示器
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  // 选择态下标题让位给计数：进选择态是一次页面级的模式切换
                  child: Text(
                    _isSelectionMode
                        ? t.common.selectedRecords(num: _selectedImages.length)
                        : widget.group.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                if (!_isSelectionMode) ...[
                  GlassGroupOverflowMenuButton(
                    actions: [
                      GlassMenuAction(
                        icon: Icons.link,
                        label: t.emoji.addImageByUrl,
                        onSelected: _showUrlInputDialog,
                      ),
                      GlassMenuAction(
                        icon: Icons.file_upload,
                        label: t.emoji.batchImport,
                        onSelected: _showBatchImportDialog,
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  GlassIconButton(
                    standalone: true,
                    icon: const Icon(Icons.checklist),
                    tooltip: t.common.editMode,
                    onPressed: _images.isEmpty ? null : _toggleSelectionMode,
                  ),
                ] else ...[
                  // 全选 ↔ 取消全选：图标在原位交叉过渡（本页列表是有限的
                  // 一整组表情，全选够得着，所以这里给了全选键）
                  GlassIconButton(
                    standalone: true,
                    icon: Icon(
                      _selectedImages.length == _images.length
                          ? Icons.remove_done
                          : Icons.done_all,
                    ),
                    tooltip: _selectedImages.length == _images.length
                        ? t.common.cancelSelectAll
                        : t.common.selectAll,
                    onPressed: _selectedImages.length == _images.length
                        ? _clearSelection
                        : _selectAllImages,
                  ),
                  const SizedBox(width: 8),
                  GlassIconButton(
                    standalone: true,
                    icon: const Icon(Icons.close),
                    tooltip: t.common.exitEditMode,
                    onPressed: _toggleSelectionMode,
                  ),
                ],
                const SizedBox(width: 8),
                GlassIconButton(
                  standalone: true,
                  icon: const Icon(Icons.close),
                  tooltip: t.common.close,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // 内容区域。选择态的动作坞浮在网格之上（本页没有分页栏，
          // 所以永远走独立浮条这一支）。
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: _isLoading
                      ? _buildGridShimmer()
                      : _images.isEmpty
                      ? _buildEmptyState()
                      : _buildImageGrid(),
                ),
                const GlassSelectionDock(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final t = Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_emotions_outlined,
            size: 64,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            t.emoji.noEmojis,
            style: TextStyle(fontSize: 18, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            t.emoji.clickToAddEmojis,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: () => _showAddImagesDialog(),
            icon: const Icon(Icons.add),
            label: Text(t.emoji.addEmojis),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    final cs = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 3; // 默认3列

    // 根据屏幕宽度动态调整列数
    if (screenWidth > 1200) {
      crossAxisCount = 8; // 超宽屏显示8列
    } else if (screenWidth > 900) {
      crossAxisCount = 6; // 宽屏显示6列
    } else if (screenWidth > 600) {
      crossAxisCount = 4; // 中等屏幕显示4列
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0, // 确保正方形比例
      ),
      itemCount: _images.length,
      itemBuilder: (context, index) {
        final image = _images[index];
        final isSelected = _selectedImages.contains(image.imageId);

        return GestureDetector(
          onLongPress: () {
            if (!_isSelectionMode) {
              _toggleSelectionMode();
              _toggleImageSelection(image.imageId);
            }
          },
          onTap: () {
            if (_isSelectionMode) {
              _toggleImageSelection(image.imageId);
            } else {
              _showImagePreview(image);
            }
          },
          child: Container(
            // 使用 Container 包装整个 Stack，确保一致的尺寸和对齐。
            // 选中态的描边/勾选角标统一由下面的 GlassSelectableOverlay 负责，
            // 这里只画一条常驻的静态细边框，不再跟着 isSelected 变色/加粗
            // （曾经两层描边各画各的，选中时会叠出双层边框）。
            decoration: BoxDecoration(
              border: Border.all(color: cs.outlineVariant, width: 1),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand, // 确保 Stack 填满整个容器
                children: [
                  // 图片
                  Image.network(
                    image.thumbnailUrl ?? image.url,
                    fit: BoxFit.cover,
                    headers: const {'referer': CommonConstants.iwaraBaseUrl},
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(color: Colors.white),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: cs.surfaceContainerHighest,
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  ),
                  // 选择态：角标勾选片 + 选中描边（全站统一，
                  // 见 GlassSelectableOverlay）。常驻挂载以获得进出过渡。
                  Positioned.fill(
                    child: GlassSelectableOverlay(
                      selectionMode: _isSelectionMode,
                      selected: isSelected,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showImagePreview(EmojiImage image) {
    final t = Translations.of(context);
    showAppDialog(
      Builder(
        builder: (context) {
          final cs = Theme.of(context).colorScheme;
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 标题栏：标题 + 玻璃关闭圆钮
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.image, color: cs.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t.emoji.imagePreview,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        GlassIconButton(
                          standalone: true,
                          icon: const Icon(Icons.close),
                          tooltip: t.common.close,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  // 图片内容
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          image.url,
                          fit: BoxFit.contain,
                          headers: const {
                            'referer': CommonConstants.iwaraBaseUrl,
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(color: Colors.white),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: cs.surfaceContainerHighest,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      size: 64,
                                      color: cs.onSurfaceVariant,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      t.emoji.imageLoadFailed,
                                      style: TextStyle(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  // 操作按钮
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showDeleteImageDialog(image);
                            },
                            icon: Icon(Icons.delete, color: cs.error),
                            label: Text(
                              t.emoji.delete,
                              style: TextStyle(color: cs.error),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: cs.error),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            label: Text(t.emoji.close),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  void _showDeleteImageDialog(EmojiImage image) {
    final t = Translations.of(context);
    showAppDialog(
      GlassAlertDialog(
        title: t.emoji.deleteImage,
        content: Text(t.emoji.confirmDeleteImage),
        actions: [
          GlassDialogAction(
            label: t.emoji.cancel,
            emphasized: false,
            onPressed: () => Navigator.pop(context),
          ),
          GlassDialogAction(
            label: t.emoji.delete,
            destructive: true,
            emphasized: false,
            onPressed: () {
              _emojiService.deleteEmojiImage(image.imageId);
              Navigator.pop(context);
              _loadImages();
            },
          ),
        ],
      ),
    );
  }

  /// 批量删除确认：走全站统一的玻璃确认弹窗。
  Future<void> _showBatchDeleteDialog() async {
    if (_selectedImages.isEmpty) return;
    final t = Translations.of(context);
    final confirmed = await showBatchConfirmDialog(
      title: t.emoji.batchDelete,
      message: t.emoji.confirmBatchDelete(count: _selectedImages.length),
      confirmLabel: t.emoji.delete,
      totalCount: _selectedImages.length,
    );
    if (!confirmed || !mounted) return;
    for (final imageId in _selectedImages) {
      _emojiService.deleteEmojiImage(imageId);
    }
    _toggleSelectionMode();
    _loadImages();
    showAppToast(t.emoji.deleteSuccess, type: AppToastType.success);
  }

  void _showAddImagesDialog() {
    final t = Translations.of(context);
    showAppDialog(
      GlassAlertDialog(
        title: t.emoji.addImage,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: Text(t.emoji.addImageByUrl),
              onTap: () {
                Navigator.pop(context);
                _showUrlInputDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_upload),
              title: Text(t.emoji.batchImport),
              onTap: () {
                Navigator.pop(context);
                _showBatchImportDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUrlInputDialog() {
    final t = Translations.of(context);
    final controller = TextEditingController();
    showAppDialog(
      GlassAlertDialog(
        title: t.emoji.addImageUrl,
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: t.emoji.imageUrl,
            hintText: t.emoji.enterImageUrl,
          ),
        ),
        actions: [
          GlassDialogAction(
            label: t.emoji.cancel,
            emphasized: false,
            onPressed: () => Navigator.pop(context),
          ),
          GlassDialogAction(
            label: t.emoji.add,
            onPressed: () {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                _emojiService.addEmojiImage(widget.group.groupId, url);
                Navigator.pop(context);
                _loadImages();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showBatchImportDialog() {
    final t = Translations.of(context);
    final controller = TextEditingController();
    showAppDialog(
      GlassAlertDialog(
        title: t.emoji.batchImport,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.emoji.enterJsonUrlArray),
            const SizedBox(height: 8),
            Text(
              t.emoji.formatExample,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: t.emoji.pasteJsonUrlArray,
              ),
            ),
          ],
        ),
        actions: [
          GlassDialogAction(
            label: t.emoji.cancel,
            emphasized: false,
            onPressed: () => Navigator.pop(context),
          ),
          GlassDialogAction(
            label: t.emoji.import,
            onPressed: () {
              final jsonText = controller.text.trim();
              if (jsonText.isNotEmpty) {
                try {
                  final List<dynamic> urls = json.decode(jsonText);
                  final List<String> urlStrings = urls.cast<String>();
                  _emojiService.addEmojiImagesBatch(
                    widget.group.groupId,
                    urlStrings,
                  );
                  Navigator.pop(context);
                  _loadImages();
                  showAppToast(
                    t.emoji.importSuccess(count: urlStrings.length),
                    type: AppToastType.success,
                  );
                } catch (e) {
                  showAppToast(
                    t.emoji.jsonFormatError,
                    type: AppToastType.error,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // 加载骨架屏
  Widget _buildGridShimmer() {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 3;
    if (screenWidth > 1200) {
      crossAxisCount = 8;
    } else if (screenWidth > 900) {
      crossAxisCount = 6;
    } else if (screenWidth > 600) {
      crossAxisCount = 4;
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0, // 确保与主网格相同的比例
      ),
      itemCount: crossAxisCount * 3,
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
}

// 静态方法用于显示 sheet
class EmojiGroupDetailPage {
  static void show(BuildContext context, EmojiGroup group) {
    showAppBottomSheet(
      EmojiGroupDetailSheet(group: group),
      isScrollControlled: true,
    );
  }
}
