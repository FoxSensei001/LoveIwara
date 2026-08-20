import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/favorite/favorite_folder.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/favorite_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/edge_fade_scrim.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:waterfall_flow/waterfall_flow.dart';

// 头部各行的显式尺寸——列表要用 paddingTop 让出这些高度,让内容可以从
// header 背后滚过去。padding + 44 圆钮/输入框 = 每行实际占位。
const double _kPickerTitleRowHeight = 16 + 44 + 4;
const double _kPickerSearchRowHeight = 8 + 44;
const double _kPickerCreateRowHeight = 10 + 44;
const double _kPickerHeaderTailSpacing = 8;
const double _kPickerHeaderExtent = _kPickerTitleRowHeight +
    _kPickerSearchRowHeight +
    _kPickerCreateRowHeight +
    _kPickerHeaderTailSpacing;

/// header 蒙层「淡出段」的高度:比 `GlassTokens.headerFadeExtent`(56)短很多,
/// 因为弹窗四周有 clip,过长的半透明淡出会把第一排卡片糊上一层白;20 只作为
/// 「卡片钻进 header 背后」的过渡带,列表首屏起始位置放在这段之后,视觉上就
/// 不会看到蒙层压在卡片上。
const double _kPickerHeaderFadeExtent = 20;

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
        child: Stack(
          children: [
            // 主体:列表铺满整个区域,用 paddingTop 让出 header 高度,让内容
            // 可以从上方玻璃 header 背后滚过去(液态玻璃改造:与首页/作者页/搜索页
            // 统一使用 GlassHeaderOverlay 同款 Stack + EdgeFadeScrim.top 模式)。
            Positioned.fill(child: _buildBody(context, t, colorScheme)),
            // 顶部渐变蒙层:header 高度区间恒定不透明,再向下平滑淡出,让底层列表
            // 滚到 header 附近时自然「溶」进边缘。
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: EdgeFadeScrim.top(
                height: _kPickerHeaderExtent + _kPickerHeaderFadeExtent,
                solidExtent: _kPickerHeaderExtent,
              ),
            ),
            // 顶部玻璃控件行:标题 / 我的收藏入口 / 关闭钮 / 搜索 / 新建。
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // 标题行:标题 + 我的收藏入口 + 玻璃关闭圆钮
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.favorite.localizeFavorite,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
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
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    slang.Translations t,
    ColorScheme colorScheme,
  ) {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: _kPickerHeaderExtent),
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
      return const Padding(
        padding: EdgeInsets.only(top: _kPickerHeaderExtent),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_filteredFolders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: _kPickerHeaderExtent),
        child: Center(child: MyEmptyWidget()),
      );
    }
    return WaterfallFlow.builder(
      // paddingTop 落在渐变蒙层完全淡出之后,让第一排卡片不会被 header 的
      // 半透明淡出段糊住(向上滚动时卡片会经过淡出段自然溶进 header)。
      padding: const EdgeInsets.fromLTRB(
        12,
        _kPickerHeaderExtent + _kPickerHeaderFadeExtent,
        12,
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