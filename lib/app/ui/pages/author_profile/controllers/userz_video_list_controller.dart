import 'package:get/get.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';

class UserzVideoListRepository extends LoadingMoreBase<Video> {
  final VideoService _videoService = Get.find<VideoService>();
  final String userId;
  final String sortType;
  final Function({int? count})? onFetchFinished;

  UserzVideoListRepository({
    required this.userId,
    required this.sortType,
    this.onFetchFinished,
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
      final response = await _videoService.fetchVideosByParams(
        page: _pageIndex,
        limit: 20,
        params: {
          'sort': sortType,
          'rating': 'all',
          'user': userId,
        },
      );

      LogUtils.d('[视频列表Repository] 查询参数: userId: $userId, sort: $sortType, page: $_pageIndex');

      if (!response.isSuccess) {
        throw Exception(response.message);
      }

      final videos = response.data!.results;

      if (_pageIndex == 0) {
        clear();
        onFetchFinished?.call(count: response.data!.count);
      }

      for (final video in videos) {
        add(video);
      }

      _hasMore = videos.isNotEmpty;
      _pageIndex++;
      isSuccess = true;
    } catch (exception, stack) {
      isSuccess = false;
      LogUtils.e('加载视频列表失败', error: exception, stack: stack);
    }
    return isSuccess;
  }
}
