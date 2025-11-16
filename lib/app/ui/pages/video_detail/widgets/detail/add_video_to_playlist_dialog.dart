import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/light_play_list.model.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/ui/widgets/empty_widget.dart';
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
                        hintText: t.playList.searchPlaylists,
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: _filterPlaylists,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
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
                      controller: _newPlaylistController,
                      enabled: !_isCreating,
                      decoration: InputDecoration(
                        hintText: t.playList.newPlaylistName,
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
                            onPressed: _createNewPlaylist,
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _fetchPlaylists,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: Text(t.common.retry),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              )
            else if (_isLoading && _playlists.isEmpty)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filteredPlaylists.isEmpty)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const MyEmptyWidget(),
                    const SizedBox(height: 8),
                    if (_playlists.isEmpty)
                      Text(
                        'No playlists available',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              )
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
                    
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: playlist.added 
                              ? const Color(0xFF2196F3) 
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: isOperating ? null : () => _togglePlaylist(playlist),
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
                                      playlist.title,
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
                                  else if (playlist.added)
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
                              // 视频数量标签
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
                                  '${t.playList.videos}: ${playlist.numVideos}',
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
    _newPlaylistController.dispose();
    super.dispose();
  }
} 