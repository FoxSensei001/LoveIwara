import 'package:get/get.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/utils/loading_more_refresh_guard.dart';

class UserzVideoListRepository extends LoadingMoreBase<Video>
    with LoadingMoreRefreshGuard<Video> {
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
  void resetPagingState() {
    super.resetPagingState(); // 代际自增，作废在途回写
    _hasMore = true;
    _pageIndex = 0;
  }

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    return runGuardedRefresh(() async {
      forceRefresh = !notifyStateChanged;
      try {
        return await super.refresh(notifyStateChanged);
      } finally {
        forceRefresh = false;
      }
    });
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    bool isSuccess = false;
    // 代际 + 页码快照必须在 await 之前取：await 期间可能发生 refresh()，
    // 那样回来的第 N 页会被当成第 0 页写进列表，页码也跟着错位。
    final int generation = currentGeneration;
    final int page = _pageIndex;
    try {
      final response = await _videoService.fetchVideosByParams(
        page: page,
        limit: 20,
        params: {'sort': sortType, 'rating': 'all', 'user': userId},
      );

      LogUtils.d(
        '[视频列表Repository] 查询参数: userId: $userId, sort: $sortType, page: $page',
      );

      if (!response.isSuccess) {
        throw Exception(response.message);
      }

      final videos = response.data!.results;

      // await 期间已被 refresh() 作废 → 丢弃本次结果。必须返回 true：
      // 返回 false 会被 loading_more_list 映射成一个假的错误页。
      if (isStaleGeneration(generation)) {
        return true;
      }

      if (page == 0) {
        clear();
        onFetchFinished?.call(count: response.data!.count);
      }

      for (final video in videos) {
        add(video);
      }

      _hasMore = videos.isNotEmpty;
      _pageIndex = page + 1;
      isSuccess = true;
    } catch (exception, stack) {
      if (isStaleGeneration(generation)) {
        return true;
      }
      isSuccess = false;
      LogUtils.e('加载视频列表失败', error: exception, stack: stack);
    }
    return isSuccess;
  }
}
