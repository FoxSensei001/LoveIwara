import 'package:get/get.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:loading_more_list/loading_more_list.dart';

class PlayListDetailRepository extends LoadingMoreBase<Video> {
  final PlayListService _playListService = Get.find<PlayListService>();
  final String playlistId;

  PlayListDetailRepository({
    required this.playlistId,
  });

  int _pageIndex = 0;
  bool _hasMore = true;
  bool forceRefresh = false;

  @override
  bool get hasMore => _hasMore || forceRefresh;

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    _hasMore = true;
    _pageIndex = 0;
    forceRefresh = !notifyStateChanged;
    final bool result = await super.refresh(notifyStateChanged);
    forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    bool isSuccess = false;
    try {
      final result = await _playListService.getPlaylistVideos(
        playlistId: playlistId,
        page: _pageIndex,
      );

      if (result.isSuccess && result.data != null) {
        if (_pageIndex == 0) {
          clear();
        }

        for (final video in result.data!.results) {
          add(video);
        }

        _hasMore = result.data!.results.isNotEmpty;
        _pageIndex++;
        isSuccess = true;
      }
    } catch (e) {
      isSuccess = false;
    }
    return isSuccess;
  }
}
