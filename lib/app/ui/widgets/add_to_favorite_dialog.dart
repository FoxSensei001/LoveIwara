import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/favorite/favorite_folder.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
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

  /// 玻璃胶囊输入框容器：半透明底色 + 细描边，与全局玻璃控件一致。
  Widget _buildGlassField(BuildContext context, {required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: GlassTokens.fill(colorScheme),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: GlassTokens.stroke(colorScheme), width: 0.6),
      ),
      child: child,
    );
  }

  InputDecoration _fieldDecoration(
    BuildContext context, {
    required String hint,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      prefixIcon: Icon(icon, color: colorScheme.onSurfaceVariant),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 800,
        ),
        child: Column(
          children: [
            // 标题行：标题 + 我的收藏入口 + 玻璃关闭圆钮
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t.favorite.localizeFavorite,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GlassIconButton(
                    standalone: true,
                    icon: const Icon(Icons.folder_open),
                    tooltip: t.favorite.myFavorites,
                    onPressed: () {
                      AppService.tryPop();
                      NaviService.navigateToLocalFavoritePage();
                    },
                  ),
                  const SizedBox(width: 8),
                  GlassIconButton(
                    standalone: true,
                    icon: const Icon(Icons.close),
                    onPressed: () => AppService.tryPop(),
                  ),
                ],
              ),
            ),
            // 搜索
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _buildGlassField(
                context,
                child: TextField(
                  controller: _searchController,
                  decoration: _fieldDecoration(
                    context,
                    hint: t.favorite.searchFolders,
                    icon: Icons.search,
                  ),
                  onChanged: _filterFolders,
                ),
              ),
            ),
            // 新建：玻璃输入 + 主色圆钮
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildGlassField(
                      context,
                      child: TextField(
                        controller: _newFolderController,
                        enabled: !_isCreating,
                        decoration: _fieldDecoration(
                          context,
                          hint: t.favorite.newFolderName,
                          icon: Icons.create_new_folder_outlined,
                        ),
                        onSubmitted: (_) => _createNewFolder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _isCreating
                      ? const SizedBox(
                          width: 44,
                          height: 44,
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : IconButton.filled(
                          onPressed: _createNewFolder,
                          icon: const Icon(Icons.add),
                          constraints: const BoxConstraints.tightFor(
                            width: 44,
                            height: 44,
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (_error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 40,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.tonalIcon(
                        onPressed: _fetchData,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(slang.t.common.retry),
                      ),
                    ],
                  ),
                ),
              )
            else if (_isLoading && _folders.isEmpty)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filteredFolders.isEmpty)
              const Expanded(child: Center(child: MyEmptyWidget()))
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
                    final bool selected =
                        _itemFolders.any((f) => f.id == folder.id);

                    return Material(
                      color: selected
                          ? colorScheme.primaryContainer.withValues(alpha: 0.5)
                          : colorScheme.surfaceContainerHighest.withValues(
                              alpha: 0.45,
                            ),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: isOperating ? null : () => _toggleFolder(folder),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? colorScheme.primary
                                  : colorScheme.outlineVariant.withValues(
                                      alpha: 0.4,
                                    ),
                              width: selected ? 1.4 : 0.8,
                            ),
                          ),
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
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        height: 1.25,
                                        color: colorScheme.onSurface,
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
                                  else if (selected)
                                    Icon(
                                      Icons.check_circle,
                                      color: colorScheme.primary,
                                      size: 20,
                                    )
                                  else
                                    Icon(
                                      Icons.add_circle_outline,
                                      color: colorScheme.outline,
                                      size: 20,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // 项目数量标签
                              Container(
                                decoration: BoxDecoration(
                                  color: selected
                                      ? colorScheme.primary.withValues(
                                          alpha: 0.12,
                                        )
                                      : colorScheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Text(
                                  '${t.favorite.items}: ${folder.itemCount ?? 0}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? colorScheme.primary
                                        : colorScheme.onSurfaceVariant,
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