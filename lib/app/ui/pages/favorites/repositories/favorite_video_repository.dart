import 'package:get/get.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 最爱视频列表数据源。
///
/// 继承 [ExtendedLoadingMoreBase] 而不是裸的 LoadingMoreBase：分页模式要靠
/// `loadPageData` 直接取某一页，只有这个基类提供（顺带白拿代际防竞态、
/// 错误消息透传与统一的刷新守卫）。
class FavoriteVideoRepository extends ExtendedLoadingMoreBase<Video> {
  final VideoService _videoService = Get.find<VideoService>();

  @override
  Future<Map<String, dynamic>> fetchDataFromSource(
    Map<String, dynamic> params,
    int page,
    int limit,
  ) async {
    final result = await _videoService.fetchFavoriteVideos(
      page: page,
      limit: limit,
    );
    if (!result.isSuccess || result.data == null) {
      throw Exception(result.message);
    }
    return {'data': result.data!};
  }

  @override
  List<Video> extractDataList(Map<String, dynamic> response) =>
      (response['data'] as PageData<Video>).results;

  @override
  int extractTotalCount(Map<String, dynamic> response) =>
      (response['data'] as PageData<Video>).count;

  @override
  void logError(String message, dynamic error, [StackTrace? stackTrace]) {
    LogUtils.e('加载最爱视频列表失败: $message', error: error, stack: stackTrace);
  }
}
