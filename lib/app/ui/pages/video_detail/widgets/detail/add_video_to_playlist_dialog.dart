import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/light_play_list.model.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_picker_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:waterfall_flow/waterfall_flow.dart';

/// 加载指示器与状态图标共用的固定占位尺寸——只要行内右侧图标槽位不改高度，
/// WaterfallFlow 就不会因为「点击某项时它高度变了 2px」把后面的卡片重新排到
/// 另一列，进而导致整片列表看起来错位。20 与状态图标 `size: 20` 对齐。
const double _kStatusSlotSize = 20;

class AddVideoToPlayListDialog extends StatefulWidget {
  final String videoId;

  /// 已经拉好的那一份列表。
  ///
  /// 卡片操作菜单开着的时候就为「已加入 N 个播放列表」拉过一次同样的
  /// `/light/playlists`（见 `media_action_menu.dart` 文件头），几秒之内没有再问
  /// 一遍服务端的理由——给了它这里就直接用，连首次的转圈都省了。重试与后续的
  /// 增删照常走网络。
  final List<LightPlaylistModel>? initialPlaylists;

  const AddVideoToPlayListDialog({
    super.key,
    required this.videoId,
    this.initialPlaylists,
  });

  @override
  State<AddVideoToPlayListDialog> createState() =>
      _AddVideoToPlayListDialogState();
}

class _AddVideoToPlayListDialogState extends State<AddVideoToPlayListDialog> {
  final PlayListService _playListService = Get.find<PlayListService>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newPlaylistController = TextEditingController();

  List<LightPlaylistModel> _playlists = [];
  List<LightPlaylistModel> _filteredPlaylists = [];
  bool _isLoading = true;
  String? _error;
  String? _operatingPlaylistId;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    final seeded = widget.initialPlaylists;
    if (seeded != null) {
      // 自己留一份：下面的增删是就地改这张表的。
      _playlists = List.of(seeded);
      _filteredPlaylists = _playlists;
      _isLoading = false;
      return;
    }
    _fetchPlaylists();
  }

  Future<void> _fetchPlaylists() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _playListService.getLightPlaylists(
      videoId: widget.videoId,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.isSuccess && result.data != null) {
          _playlists = result.data!;
          _filteredPlaylists = _playlists;
        } else {
          _error = result.message;
        }
      });
    }
  }

  void _filterPlaylists(String query) {
    setState(() {
      _filteredPlaylists = _playlists
          .where(
            (playlist) =>
                playlist.title.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  Future<void> _togglePlaylist(LightPlaylistModel playlist) async {
    if (_operatingPlaylistId != null) return;

    setState(() => _operatingPlaylistId = playlist.id);

    final result = playlist.added
        ? await _playListService.removeFromPlaylist(
            videoId: widget.videoId,
            playlistId: playlist.id,
          )
        : await _playListService.addToPlaylist(
            videoId: widget.videoId,
            playlistId: playlist.id,
          );

    if (mounted) {
      setState(() {
        _operatingPlaylistId = null;
        if (result.isSuccess) {
          final index = _playlists.indexWhere((p) => p.id == playlist.id);
          if (index != -1) {
            _playlists[index] = LightPlaylistModel(
              id: playlist.id,
              title: playlist.title,
              numVideos: playlist.numVideos + (playlist.added ? -1 : 1),
              added: !playlist.added,
            );
            _filterPlaylists(_searchController.text);
          }
        } else {
          // 显示错误提示
          showGlassToast(
            result.message,
            type: GlassToastType.error,
            position: GlassToastPosition.bottom,
          );
        }
      });
    }
  }

  Future<void> _createNewPlaylist() async {
    if (_newPlaylistController.text.isEmpty || _isCreating) return;

    setState(() => _isCreating = true);

    final result = await _playListService.createPlaylist(
      title: _newPlaylistController.text,
    );

    if (result.isSuccess) {
      _newPlaylistController.clear();
      await _fetchPlaylists();
      // 显示成功提示
      showGlassToast(
        slang.t.common.success,
        type: GlassToastType.success,
        position: GlassToastPosition.bottom,
      );
    } else {
      // 显示错误提示
      showGlassToast(
        result.message,
        type: GlassToastType.error,
        position: GlassToastPosition.bottom,
      );
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
      title: t.common.playList,
      onClose: () => Navigator.of(context).pop(),
      rows: [
        // 搜索
        GlassPickerRow.field(
          child: GlassPickerField(
            controller: _searchController,
            hintText: t.playList.searchPlaylists,
            icon: Icons.search,
            onChanged: _filterPlaylists,
          ),
        ),
        // 新建：玻璃输入 + 主色圆钮
        GlassPickerRow.field(
          child: Row(
            children: [
              Expanded(
                child: GlassPickerField(
                  controller: _newPlaylistController,
                  enabled: !_isCreating,
                  hintText: t.playList.newPlaylistName,
                  icon: Icons.playlist_add,
                  onSubmitted: (_) => _createNewPlaylist(),
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
                      onPressed: _createNewPlaylist,
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
                onPressed: _fetchPlaylists,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(t.common.retry),
              ),
            ],
          ),
        ),
      );
    }
    if (_isLoading && _playlists.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: headerExtent),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_filteredPlaylists.isEmpty) {
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
      itemCount: _filteredPlaylists.length,
      itemBuilder: (context, index) {
        final playlist = _filteredPlaylists[index];
        final bool isOperating = _operatingPlaylistId == playlist.id;
        final bool selected = playlist.added;

        return Material(
          // 用 id 做 key,防止列表重建后 Flutter 按位置错配 Element,导致同一
          // 张卡片在数据刷新瞬间被认成邻居的卡。
          key: ValueKey('playlist_${playlist.id}'),
          color: selected
              ? colorScheme.primaryContainer.withValues(alpha: 0.5)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: isOperating ? null : () => _togglePlaylist(playlist),
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
                          playlist.title,
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
                  // 视频数量标签
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
                      '${t.playList.videos}: ${playlist.numVideos}',
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
    _newPlaylistController.dispose();
    super.dispose();
  }
}
