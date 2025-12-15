import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/favorite/favorite_folder.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:waterfall_flow/waterfall_flow.dart';

class AddToFavoriteDialog extends StatefulWidget {
  final String itemId;
  final Function(String folderId) onAdd;

  const AddToFavoriteDialog({
    super.key,
    required this.itemId,
    required this.onAdd,
  });

  @override
  State<AddToFavoriteDialog> createState() => _AddToFavoriteDialogState();
}

class _AddToFavoriteDialogState extends State<AddToFavoriteDialog> {
  final FavoriteService _favoriteService = Get.find<FavoriteService>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newFolderController = TextEditingController();

  List<FavoriteFolder> _folders = [];
  List<FavoriteFolder> _filteredFolders = [];
  List<FavoriteFolder> _itemFolders = [];
  bool _isLoading = true;
  String? _error;
  String? _operatingFolderId;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final folders = await _favoriteService.getAllFolders();
      final itemFolders = await _favoriteService.getItemFolders(widget.itemId);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _folders = folders;
          _filteredFolders = folders;
          _itemFolders = itemFolders;
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

  void _filterFolders(String query) {
    setState(() {
      _filteredFolders = _folders
          .where((folder) =>
              folder.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _toggleFolder(FavoriteFolder folder) async {
    if (_operatingFolderId != null) return;

    setState(() => _operatingFolderId = folder.id);

    try {
      final isInFolder = _itemFolders.any((f) => f.id == folder.id);
      await widget.onAdd(folder.id);
      
      if (isInFolder) {
        // 如果已在文件夹中,移除后更新状态
        _itemFolders.removeWhere((f) => f.id == folder.id);
        if (mounted) {
          showToastWidget(
            MDToastWidget(
              message: slang.t.favorite.removeSuccess,
              type: MDToastType.success,
            ),
          );
        }
      } else {
        // 如果不在文件夹中,添加后更新状态
        _itemFolders.add(folder);
        if (mounted) {
          showToastWidget(
            MDToastWidget(
              message: slang.t.favorite.addSuccess,
              type: MDToastType.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showToastWidget(
          MDToastWidget(
            message: slang.t.favorite.addFailed,
            type: MDToastType.error,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _operatingFolderId = null);
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
        await _fetchData();
        if (mounted) {
          showToastWidget(
            MDToastWidget(
              message: slang.t.favorite.createFolderSuccess,
              type: MDToastType.success,
            ),
          );
        }
      } else {
        throw Exception('创建失败');
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

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 800,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: t.favorite.searchFolders,
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: _filterFolders,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.folder_open),
                    tooltip: t.favorite.myFavorites,
                    onPressed: () {
                      AppService.tryPop();
                      NaviService.navigateToLocalFavoritePage();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => AppService.tryPop()
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newFolderController,
                      enabled: !_isCreating,
                      decoration: InputDecoration(
                        hintText: t.favorite.newFolderName,
                      ),
                    ),
                  ),
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
            const SizedBox(height: 8),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else if (_isLoading && _folders.isEmpty)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filteredFolders.isEmpty)
              const Expanded(child: MyEmptyWidget())
            else
              Expanded(
                child: WaterfallFlow.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _filteredFolders.length,
                  itemBuilder: (context, index) {
                    final folder = _filteredFolders[index];
                    final bool isOperating = _operatingFolderId == folder.id;
                    final bool isInFolder = _itemFolders.any((f) => f.id == folder.id);

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isInFolder
                              ? const Color(0xFF2196F3)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: isOperating ? null : () => _toggleFolder(folder),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 标题和状态图标
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      folder.title,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isOperating)
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  else if (isInFolder)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF2196F3),
                                      size: 20,
                                    )
                                  else
                                    const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // 项目数量标签
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2196F3)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFF2196F3)
                                        .withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Text(
                                  '${t.favorite.items}: ${folder.itemCount ?? 0}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF2196F3),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _newFolderController.dispose();
    super.dispose();
  }
} 