import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/favorite/favorite_folder.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class FavoriteListPage extends StatefulWidget {
  const FavoriteListPage({super.key});

  @override
  State<FavoriteListPage> createState() => _FavoriteListPageState();
}

class _FavoriteListPageState extends State<FavoriteListPage> {
  final FavoriteService _favoriteService = Get.find<FavoriteService>();
  final TextEditingController _newFolderController = TextEditingController();

  List<FavoriteFolder> _folders = [];
  bool _isLoading = true;
  String? _error;
  bool _isCreating = false;
  bool _isDragMode = false;

  @override
  void initState() {
    super.initState();
    _fetchFolders();
  }

  Future<void> _fetchFolders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final folders = await _favoriteService.getAllFolders();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _folders = folders;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _createNewFolder() async {
    if (_newFolderController.text.isEmpty || _isCreating) return;

    setState(() => _isCreating = true);

    try {
      final folder = await _favoriteService.createFolder(
        title: _newFolderController.text,
      );

      if (folder != null) {
        _newFolderController.clear();
        await _fetchFolders();
        if (mounted) {
          showToastWidget(
            MDToastWidget(
              message: slang.t.favorite.createFolderSuccess,
              type: MDToastType.success,
            ),
          );
        }
      } else {
        throw Exception('Create failed');
      }
    } catch (e) {
      if (mounted) {
        showToastWidget(
          MDToastWidget(
            message: slang.t.favorite.createFolderFailed,
            type: MDToastType.error,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isCreating = false);
    }
  }

  Future<void> _deleteFolder(FavoriteFolder folder) async {
    final t = slang.Translations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.favorite.deleteFolderTitle),
        content: Text(t.favorite.deleteFolderConfirmWithTitle(title: folder.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.common.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              t.common.confirm,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final success = await _favoriteService.deleteFolder(folder.id);
        if (success) {
          await _fetchFolders();
          if (mounted) {
            showToastWidget(
              MDToastWidget(
                message: t.favorite.errors.deleteFolderSuccess,
                type: MDToastType.success,
              ),
            );
          }
        } else {
          throw Exception('Delete failed');
        }
      } catch (e) {
        if (mounted) {
          showToastWidget(
            MDToastWidget(
              message: t.favorite.errors.deleteFolderFailed,
              type: MDToastType.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _editFolder(FavoriteFolder folder) async {
    final t = slang.Translations.of(context);
    final controller = TextEditingController(text: folder.title);

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
                t.favorite.editFolderTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: t.favorite.enterFolderNameHere,
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
                            message: t.favorite.errors.folderNameCannotBeEmpty,
                            type: MDToastType.error,
                          ),
                        );
                        return;
                      }
                      Navigator.of(context).pop(controller.text);
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

    if (result != null && result.trim().isNotEmpty) {
      try {
        final success = await _favoriteService.updateFolder(
          folder.id,
          title: result.trim(),
        );
        if (success) {
          await _fetchFolders();
          if (mounted) {
            showToastWidget(
              MDToastWidget(
                message: t.favorite.editFolderSuccess,
                type: MDToastType.success,
              ),
            );
          }
        } else {
          throw Exception('Update failed');
        }
      } catch (e) {
        if (mounted) {
          showToastWidget(
            MDToastWidget(
              message: t.favorite.editFolderFailed,
              type: MDToastType.error,
            ),
          );
        }
      }
    }
  }

  void _navigateToFolderDetail(String folderId, String? folderTitle) {
    NaviService.navigateToLocalFavoriteDetailPage(folderId, folderTitle);
  }

  Future<void> _updateFoldersOrder() async {
    final folderIds = _folders.map((f) => f.id).toList();
    await _favoriteService.updateFoldersOrder(folderIds);
  }

  Widget _buildFolderCard(FavoriteFolder folder, slang.Translations t) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToFolderDetail(folder.id, folder.title),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 第一行：名称
              Text(
                folder.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // 第二行：数量和按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 左边：数量
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondaryContainer
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.video_library,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${folder.itemCount ?? 0}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                              ),
                        ),
                      ],
                    ),
                  ),
                  // 右边：按钮
                  if (folder.id != 'default')
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      padding: EdgeInsets.zero,
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editFolder(folder);
                        } else if (value == 'delete') {
                          _deleteFolder(folder);
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableFolderCard(FavoriteFolder folder, int index, slang.Translations t) {
    return Card(
      key: ValueKey(folder.id),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 拖拽手柄
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
            // 文件夹图标
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.folder,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // 文件夹信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    folder.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.video_library,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${folder.itemCount ?? 0} ${t.favorite.items}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 排序序号
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
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
      appBar: AppBar(
        title: Text(t.favorite.myFavorites),
        actions: [
          if (_folders.isNotEmpty)
            IconButton(
              icon: Icon(_isDragMode ? Icons.check : Icons.sort),
              tooltip: _isDragMode ? t.common.confirm : t.common.sort,
              onPressed: () {
                setState(() {
                  _isDragMode = !_isDragMode;
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newFolderController,
                    enabled: !_isCreating,
                    decoration: InputDecoration(
                      hintText: t.favorite.newFolderName,
                      prefixIcon: const Icon(Icons.create_new_folder),
                    ),
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
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _createNewFolder,
                        ),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          else if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_folders.isEmpty)
            const Expanded(child: MyEmptyWidget())
          else if (_isDragMode)
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _folders.length,
                buildDefaultDragHandles: false,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final folder = _folders.removeAt(oldIndex);
                    _folders.insert(newIndex, folder);
                  });
                  _updateFoldersOrder();
                },
                itemBuilder: (context, index) {
                  final folder = _folders[index];
                  return _buildDraggableFolderCard(folder, index, t);
                },
              ),
            )
          else
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),
                itemCount: _folders.length,
                itemBuilder: (context, index) {
                  final folder = _folders[index];
                  return _buildFolderCard(folder, t);
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _newFolderController.dispose();
    super.dispose();
  }
} 
