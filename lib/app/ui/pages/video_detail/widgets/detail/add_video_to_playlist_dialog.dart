import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/light_play_list.model.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:oktoast/oktoast.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

class AddVideoToPlayListDialog extends StatefulWidget {
  final String videoId;

  const AddVideoToPlayListDialog({
    super.key,
    required this.videoId,
  });

  @override
  State<AddVideoToPlayListDialog> createState() => _AddVideoToPlayListDialogState();
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
          .where((playlist) =>
              playlist.title.toLowerCase().contains(query.toLowerCase()))
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
          showToastWidget(
            MDToastWidget(
              message: result.message,
              type: MDToastType.error,
            ),
            position: ToastPosition.bottom,
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
      showToastWidget(
        MDToastWidget(
          message: slang.t.common.success,
          type: MDToastType.success,
        ),
        position: ToastPosition.bottom,
      );
    } else {
      // 显示错误提示
      showToastWidget(
        MDToastWidget(
          message: result.message,
          type: MDToastType.error,
        ),
        position: ToastPosition.bottom,
      );
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
            // 标题行：标题 + 玻璃关闭圆钮
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t.common.playList,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GlassIconButton(
                    standalone: true,
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
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
                    hint: t.playList.searchPlaylists,
                    icon: Icons.search,
                  ),
                  onChanged: _filterPlaylists,
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
                        controller: _newPlaylistController,
                        enabled: !_isCreating,
                        decoration: _fieldDecoration(
                          context,
                          hint: t.playList.newPlaylistName,
                          icon: Icons.playlist_add,
                        ),
                        onSubmitted: (_) => _createNewPlaylist(),
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
                          onPressed: _createNewPlaylist,
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
                        onPressed: _fetchPlaylists,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(t.common.retry),
                      ),
                    ],
                  ),
                ),
              )
            else if (_isLoading && _playlists.isEmpty)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filteredPlaylists.isEmpty)
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
                  itemCount: _filteredPlaylists.length,
                  itemBuilder: (context, index) {
                    final playlist = _filteredPlaylists[index];
                    final bool isOperating = _operatingPlaylistId == playlist.id;
                    final bool selected = playlist.added;

                    return Material(
                      color: selected
                          ? colorScheme.primaryContainer.withValues(alpha: 0.5)
                          : colorScheme.surfaceContainerHighest.withValues(
                              alpha: 0.45,
                            ),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: isOperating
                            ? null
                            : () => _togglePlaylist(playlist),
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
                              // 视频数量标签
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
    _newPlaylistController.dispose();
    super.dispose();
  }
}