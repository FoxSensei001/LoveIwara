import 'package:get/get.dart';
import 'package:i_iwara/app/models/play_list.model.dart';
import 'package:i_iwara/app/services/play_list_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';

class PlayListRepository extends LoadingMoreBase<PlaylistModel> {
  final PlayListService _playListService = Get.find<PlayListService>();
  final String userId;

  PlayListRepository({required this.userId});
  int _pageIndex = 0;
  bool _hasMore = true;
  bool forceRefresh = false;
  @override
  bool get hasMore => _hasMore || forceRefresh;

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    _hasMore = true;
    _pageIndex = 0;
    //force to refresh list when you don't want clear list before request
    //for the case, if your list already has 20 items.
    forceRefresh = !notifyStateChanged;
    final bool result = await super.refresh(notifyStateChanged);
    forceRefresh = false;
    return result;
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
    try {
      //to show loading more clearly, in your app,remove this
      //await Future.delayed(const Duration(milliseconds: 500));
      List<PlaylistModel> feedList = await loadPageData(_pageIndex, 10);

      if (_pageIndex == 0) {
        clear();
      }

      for (final PlaylistModel item in feedList) {
        add(item);
      }

      _hasMore = feedList.isNotEmpty;
      _pageIndex++;
      isSuccess = true;
    } catch (exception, stack) {
      isSuccess = false;
      LogUtils.e('加载播放列表失败',
          error: exception, stack: stack, tag: 'PlayListRepository');
    }
    return isSuccess;
  }
}
