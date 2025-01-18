import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/favorite/favorite_folder.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/utils/common_utils.dart';
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
          throw Exception('删除失败');
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
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
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
      ),
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
          throw Exception('更新失败');
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

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.favorite.myFavorites),
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
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: _folders.length,
                itemBuilder: (context, index) {
                  final folder = _folders[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      onTap: () => _navigateToFolderDetail(folder.id, folder.title),
                      leading: const Icon(Icons.folder),
                      title: Text(folder.title),
                      subtitle: Text(
                        '${t.favorite.items}: ${folder.itemCount ?? 0}    ${t.favorite.createdAt}: ${CommonUtils.formatFriendlyTimestamp(folder.createdAt)}',
                      ),
                      trailing: folder.id == 'default'
                          ? null
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editFolder(folder),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteFolder(folder),
                                ),
                              ],
                            ),
                    ),
                  );
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