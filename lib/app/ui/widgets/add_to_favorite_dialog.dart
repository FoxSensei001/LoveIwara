import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/favorite/favorite_folder.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

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
                child: ListView.builder(
                  itemCount: _filteredFolders.length,
                  itemBuilder: (context, index) {
                    final folder = _filteredFolders[index];
                    final bool isOperating = _operatingFolderId == folder.id;
                    final bool isInFolder = _itemFolders.any((f) => f.id == folder.id);
                    
                    return ListTile(
                      title: Text(folder.title),
                      subtitle: Text('${t.favorite.items}: ${folder.itemCount ?? 0}'),
                      trailing: SizedBox(
                        width: 24,
                        height: 24,
                        child: isOperating
                            ? const CircularProgressIndicator(
                                strokeWidth: 2,
                              )
                            : Icon(
                                isInFolder
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                              ),
                      ),
                      onTap: isOperating ? null : () => _toggleFolder(folder),
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