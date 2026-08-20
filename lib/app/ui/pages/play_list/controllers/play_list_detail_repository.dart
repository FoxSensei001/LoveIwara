import 'package:get/get.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 播放列表详情的视频数据源。
///
/// 走 [ExtendedLoadingMoreBase] 是为了拿到 `loadPageData` / `requestTotalCount`
/// 这套分页契约——[MediaListView] 的分页模式依赖它，普通 `LoadingMoreBase`
/// 只能跑瀑布流。
class PlayListDetailRepository extends ExtendedLoadingMoreBase<Video> {
  final PlayListService _playListService = Get.find<PlayListService>();
  final String playlistId;

  PlayListDetailRepository({required this.playlistId});

  @override
  Future<Map<String, dynamic>> fetchDataFromSource(
    Map<String, dynamic> params,
    int page,
    int limit,
  ) async {
    final result = await _playListService.getPlaylistVideos(
      playlistId: playlistId,
      page: page,
      limit: limit,
    );
    if (result.isSuccess && result.data != null) {
      return {'data': result.data!};
    }
    throw Exception(result.message);
  }

  @override
  List<Video> extractDataList(Map<String, dynamic> response) =>
      (response['data'] as PageData<Video>).results;

  @override
  int extractTotalCount(Map<String, dynamic> response) =>
      (response['data'] as PageData<Video>).count;

  @override
  void logError(String message, dynamic error, [StackTrace? stackTrace]) {
    LogUtils.e(
      '加载播放列表视频失败: $message',
      error: error,
      stack: stackTrace,
      tag: 'PlayListDetailRepository',
    );
  }
}
