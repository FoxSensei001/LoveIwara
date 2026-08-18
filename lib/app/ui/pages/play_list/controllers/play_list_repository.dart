import 'package:get/get.dart';
import 'package:i_iwara/app/models/play_list.model.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:i_iwara/utils/loading_more_refresh_guard.dart';

class PlayListRepository extends LoadingMoreBase<PlaylistModel>
    with LoadingMoreRefreshGuard<PlaylistModel> {
  final PlayListService _playListService = Get.find<PlayListService>();
  final String userId;

  PlayListRepository({required this.userId});
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

  Future<List<PlaylistModel>> loadPageData(int pageKey, int pageSize) async {
    final result = await _playListService.getPlaylists(
      userId: userId,
      page: pageKey,
      limit: pageSize,
    );

    if (result.isSuccess && result.data != null) {
      return result.data!.results;
    }

    throw Exception('加载失败');
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    bool isSuccess = false;
    // 代际 + 页码快照必须在 await 之前取：await 期间可能发生 refresh()，
    // 那样回来的第 N 页会被当成第 0 页写进列表，页码也跟着错位。
    final int generation = currentGeneration;
    final int page = _pageIndex;
    try {
      //to show loading more clearly, in your app,remove this
      //await Future.delayed(const Duration(milliseconds: 500));
      List<PlaylistModel> feedList = await loadPageData(page, 10);

      // await 期间已被 refresh() 作废 → 丢弃本次结果。必须返回 true：
      // 返回 false 会被 loading_more_list 映射成一个假的错误页。
      if (isStaleGeneration(generation)) {
        return true;
      }

      if (page == 0) {
        clear();
      }

      for (final PlaylistModel item in feedList) {
        add(item);
      }

      _hasMore = feedList.isNotEmpty;
      _pageIndex = page + 1;
      isSuccess = true;
    } catch (exception, stack) {
      if (isStaleGeneration(generation)) {
        return true;
      }
      isSuccess = false;
      LogUtils.e(
        '加载播放列表失败',
        error: exception,
        stack: stack,
        tag: 'PlayListRepository',
      );
    }
    return isSuccess;
  }
}
