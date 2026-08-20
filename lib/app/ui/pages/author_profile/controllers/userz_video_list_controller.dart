import 'package:get/get.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/utils/logger_utils.dart';

class UserzVideoListRepository extends ExtendedLoadingMoreBase<Video> {
  final VideoService _videoService = Get.find<VideoService>();
  final String userId;
  final String sortType;

  /// 标签筛选（与 `tags=a,b` 对应，服务端按「同时含有」处理）。
  final List<String> searchTagIds;

  /// 日期筛选，'' / 'YYYY' / 'YYYY-MM'。
  final String searchDate;

  final Function({int? count})? onFetchFinished;

  UserzVideoListRepository({
    required this.userId,
    required this.sortType,
    this.searchTagIds = const [],
    this.searchDate = '',
    this.onFetchFinished,
  });

  @override
  Map<String, dynamic> buildQueryParams(int page, int limit) => {
    'sort': sortType,
    'rating': 'all',
    'user': userId,
    if (searchTagIds.isNotEmpty) 'tags': searchTagIds.join(','),
    if (searchDate.isNotEmpty) 'date': searchDate,
  };

  @override
  Future<Map<String, dynamic>> fetchDataFromSource(
    Map<String, dynamic> params,
    int page,
    int limit,
  ) async {
    final response = await _videoService.fetchVideosByParams(
      page: page,
      limit: limit,
      params: params,
    );
    LogUtils.d(
      '[视频列表Repository] 查询参数: userId: $userId, sort: $sortType, '
      'tags: ${searchTagIds.join(',')}, date: $searchDate, page: $page',
    );
    if (!response.isSuccess || response.data == null) {
      throw Exception(response.message);
    }
    return {'data': response.data!};
  }

  @override
  Future<List<Video>> loadPageData(int pageKey, int pageSize) async {
    final videos = await super.loadPageData(pageKey, pageSize);
    if (pageKey == 0) onFetchFinished?.call(count: requestTotalCount);
    return videos;
  }

  @override
  List<Video> extractDataList(Map<String, dynamic> response) =>
      (response['data'] as PageData<Video>).results;

  @override
  int extractTotalCount(Map<String, dynamic> response) =>
      (response['data'] as PageData<Video>).count;

  @override
  void logError(String message, dynamic error, [StackTrace? stackTrace]) {
    LogUtils.e('加载视频列表失败: $message', error: error, stack: stackTrace);
  }
}
