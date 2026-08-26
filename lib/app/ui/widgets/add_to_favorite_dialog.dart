import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/favorite/favorite_folder.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_picker_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:waterfall_flow/waterfall_flow.dart';

/// 加载指示器与状态图标共用的固定占位尺寸——只要行内右侧图标槽位不改高度,
/// WaterfallFlow 就不会因为「点击某项时它高度变了 2px」把后面的卡片重新排到
/// 另一列,进而导致整片列表看起来错位。20 与状态图标 `size: 20` 对齐。
const double _kStatusSlotSize = 20;

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
          showGlassToast(
            slang.t.favorite.removeSuccess,
            type: GlassToastType.success,
          );
        }
      } else {
        // 如果不在文件夹中,添加后更新状态
        _itemFolders.add(folder);
        if (mounted) {
          showGlassToast(
            slang.t.favorite.addSuccess,
            type: GlassToastType.success,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showGlassToast(slang.t.favorite.addFailed, type: GlassToastType.error);
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
          showGlassToast(
            slang.t.favorite.createFolderSuccess,
            type: GlassToastType.success,
          );
        }
      } else {
        throw Exception('创建失败');
      }
    } catch (e) {
      if (mounted) {
        showGlassToast(
          slang.t.favorite.createFolderFailed,
          type: GlassToastType.error,
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
    final colorScheme = Theme.of(context).colorScheme;

    return GlassPickerDialog(
      title: t.favorite.localizeFavorite,
      titleActions: [
        GlassIconButton(
          standalone: true,
          icon: const Icon(Icons.folder_open),
          tooltip: t.favorite.myFavorites,
          onPressed: () {
            AppService.tryPop();
            NaviService.navigateToLocalFavoritePage();
          },
        ),
      ],
      rows: [
        // 搜索
        GlassPickerRow.field(
          child: GlassPickerField(
            controller: _searchController,
            hintText: t.favorite.searchFolders,
            icon: Icons.search,
            onChanged: _filterFolders,
          ),
        ),
        // 新建：玻璃输入 + 主色圆钮
        GlassPickerRow.field(
          child: Row(
            children: [
              Expanded(
                child: GlassPickerField(
                  controller: _newFolderController,
                  enabled: !_isCreating,
                  hintText: t.favorite.newFolderName,
                  icon: Icons.create_new_folder_outlined,
                  onSubmitted: (_) => _createNewFolder(),
                ),
              ),
              const SizedBox(width: 10),
              _isCreating
                  ? const SizedBox(
                      width: GlassPickerDialog.fieldRowHeight,
                      height: GlassPickerDialog.fieldRowHeight,
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
                        width: GlassPickerDialog.fieldRowHeight,
                        height: GlassPickerDialog.fieldRowHeight,
                      ),
                    ),
            ],
          ),
        ),
      ],
      bodyBuilder: (context, headerExtent) =>
          _buildBody(context, t, colorScheme, headerExtent),
    );
  }

  Widget _buildBody(
    BuildContext context,
    slang.Translations t,
    ColorScheme colorScheme,
    double headerExtent,
  ) {
    if (_error != null) {
      return Padding(
        padding: EdgeInsets.only(top: headerExtent),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 40, color: colorScheme.error),
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
      );
    }
    if (_isLoading && _folders.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: headerExtent),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_filteredFolders.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: headerExtent),
        child: const Center(child: MyEmptyWidget()),
      );
    }
    return WaterfallFlow.builder(
      // headerExtent 由 GlassPickerDialog 实测下发（已含 8px 尾部留白）：
      // 蒙层的尾巴还会往下压一小段，但走到 header 底缘时已经淡到峰值的两成
      // 出头，首屏条目是从渐变里「溶」出来的，不是被一条硬边切开。
      padding: EdgeInsets.fromLTRB(
        GlassPickerDialog.hPadding,
        headerExtent,
        GlassPickerDialog.hPadding,
        12,
      ),
      gridDelegate: const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: _filteredFolders.length,
      itemBuilder: (context, index) {
        final folder = _filteredFolders[index];
        final bool isOperating = _operatingFolderId == folder.id;
        final bool selected = _itemFolders.any((f) => f.id == folder.id);

        return Material(
          // 用 id 做 key,防止列表重建后 Flutter 按位置错配 Element。
          key: ValueKey('favorite_folder_${folder.id}'),
          color: selected
              ? colorScheme.primaryContainer.withValues(alpha: 0.5)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
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
                      : colorScheme.outlineVariant.withValues(alpha: 0.4),
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
                      // 固定 20x20 槽位:loading / 未选 / 已选三态同尺寸,
                      // 才不会因高度抖动让 WaterfallFlow 重新排列后面的卡片。
                      SizedBox(
                        width: _kStatusSlotSize,
                        height: _kStatusSlotSize,
                        child: isOperating
                            ? const Padding(
                                padding: EdgeInsets.all(1),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                selected
                                    ? Icons.check_circle
                                    : Icons.add_circle_outline,
                                color: selected
                                    ? colorScheme.primary
                                    : colorScheme.outline,
                                size: _kStatusSlotSize,
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 项目数量标签
                  Container(
                    decoration: BoxDecoration(
                      color: selected
                          ? colorScheme.primary.withValues(alpha: 0.12)
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
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _newFolderController.dispose();
    super.dispose();
  }
} 