import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/download/download_category.model.dart';
import 'package:i_iwara/app/services/download_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 下载分类管理页：新建 / 重命名 / 删除 / 拖拽排序。
///
/// 与收藏夹管理页（favorite_list_page）同构，差异：
/// - 没有受保护的「默认」分类（未分类是虚拟桶，不在此页）。
/// - 删除分类不删文件，仅把任务退回「未分类」。
class DownloadCategoryManagePage extends StatefulWidget {
  const DownloadCategoryManagePage({super.key});

  @override
  State<DownloadCategoryManagePage> createState() =>
      _DownloadCategoryManagePageState();
}

class _DownloadCategoryManagePageState
    extends State<DownloadCategoryManagePage> {
  final DownloadService _service = Get.find<DownloadService>();
  final TextEditingController _newController = TextEditingController();

  List<DownloadCategory> _categories = [];
  bool _isLoading = true;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _newController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      final cats = await _service.getAllCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _create() async {
    final name = _newController.text.trim();
    if (name.isEmpty || _isCreating) return;
    setState(() => _isCreating = true);
    final t = slang.Translations.of(context);
    try {
      final cat = await _service.createCategory(title: name);
      if (cat != null) {
        _newController.clear();
        await _fetch();
        if (mounted) {
          showToastWidget(
            MDToastWidget(
              message: t.download.category.createSuccess,
              type: MDToastType.success,
            ),
          );
        }
      } else {
        throw Exception('create failed');
      }
    } catch (e) {
      if (mounted) {
        showToastWidget(
          MDToastWidget(
            message: t.download.category.createFailed,
            type: MDToastType.error,
          ),
        );
      }
    }
    if (mounted) setState(() => _isCreating = false);
  }

  Future<void> _rename(DownloadCategory category) async {
    final t = slang.Translations.of(context);
    final controller = TextEditingController(text: category.title);

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final mq = MediaQuery.of(context);
        final bottomInset = mq.viewInsets.bottom;
        final bottomSafeInset = computeBottomSafeInset(mq);
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset + bottomSafeInset),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  t.download.category.renameTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: t.download.category.renameHint,
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(t.common.cancel),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () {
                        if (controller.text.trim().isEmpty) {
                          showToastWidget(
                            MDToastWidget(
                              message: t.download.category.nameEmpty,
                              type: MDToastType.error,
                            ),
                          );
                          return;
                        }
                        Navigator.of(context).pop(controller.text.trim());
                      },
                      child: Text(t.common.confirm),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      final ok = await _service.updateCategory(category.id, title: result);
      if (ok) {
        await _fetch();
        if (mounted) {
          showToastWidget(
            MDToastWidget(
              message: t.download.category.renameSuccess,
              type: MDToastType.success,
            ),
          );
        }
      } else if (mounted) {
        showToastWidget(
          MDToastWidget(
            message: t.download.category.renameFailed,
            type: MDToastType.error,
          ),
        );
      }
    }
  }

  Future<void> _delete(DownloadCategory category) async {
    final t = slang.Translations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.download.category.deleteTitle),
        content: Text(
          t.download.category.deleteConfirm(
            title: category.title,
            count: category.itemCount ?? 0,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.common.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(t.common.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final ok = await _service.deleteCategory(category.id);
      if (ok) {
        await _fetch();
        if (mounted) {
          showToastWidget(
            MDToastWidget(
              message: t.download.category.deleteSuccess,
              type: MDToastType.success,
            ),
          );
        }
      } else if (mounted) {
        showToastWidget(
          MDToastWidget(
            message: t.download.category.deleteFailed,
            type: MDToastType.error,
          ),
        );
      }
    }
  }

  Future<void> _persistOrder() async {
    final ids = _categories.map((c) => c.id).toList();
    await _service.updateCategoriesOrder(ids);
  }

  Widget _buildDraggableCard(
    DownloadCategory category,
    int index,
    slang.Translations t,
  ) {
    return Card(
      key: ValueKey(category.id),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.drag_handle, size: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.folder,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category.itemCount ?? 0}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onSelected: (value) {
                if (value == 'edit') {
                  _rename(category);
                } else if (value == 'delete') {
                  _delete(category);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit, size: 18),
                      const SizedBox(width: 8),
                      Text(t.common.edit),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, size: 18, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        t.common.delete,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.download.category.manageTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newController,
                    enabled: !_isCreating,
                    decoration: InputDecoration(
                      hintText: t.download.category.newCategoryHint,
                      prefixIcon: const Icon(Icons.create_new_folder_outlined),
                    ),
                    onSubmitted: (_) => _create(),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: _isCreating
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _create,
                        ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_categories.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MyEmptyWidget(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        t.download.category.emptyHint,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _categories.length,
                buildDefaultDragHandles: false,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) newIndex -= 1;
                    final c = _categories.removeAt(oldIndex);
                    _categories.insert(newIndex, c);
                  });
                  _persistOrder();
                },
                itemBuilder: (context, index) =>
                    _buildDraggableCard(_categories[index], index, t),
              ),
            ),
        ],
      ),
    );
  }
}
