import 'package:get/get.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/video_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';

class SubscriptionVideoRepository extends LoadingMoreBase<Video> {
  final VideoService _videoService = Get.find<VideoService>();
  final String userId;
  SubscriptionVideoRepository({required this.userId, this.maxLength = 300});
  int _pageIndex = 0;
  bool _hasMore = true;
  bool forceRefresh = false;
  @override
  bool get hasMore => (_hasMore && length < maxLength) || forceRefresh;
  final int maxLength;

  @override
  Future<bool> refresh([bool notifyStateChanged = false]) async {
    _hasMore = true;
    _pageIndex = 0;
    forceRefresh = !notifyStateChanged;
    final bool result = await super.refresh(notifyStateChanged);
    forceRefresh = false;
    return result;
  }

  Future<List<Video>> loadPageData(int pageKey, int pageSize) async {
    final params = <String, dynamic>{
      if (userId.isNotEmpty) 'user': userId,
      if (userId.isEmpty) 'subscribed': true,
    };

    final result = await _videoService.fetchVideosByParams(
      params: params,
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
      List<Video> feedList = await loadPageData(_pageIndex, 20);

      if (_pageIndex == 0) {
        clear();
      }

      for (final Video item in feedList) {
        add(item);
      }

      _hasMore = feedList.isNotEmpty;
      _pageIndex++;
      isSuccess = true;
    } catch (exception, stack) {
      isSuccess = false;
      LogUtils.e('加载订阅视频列表失败',
          error: exception, stack: stack, tag: 'SubscriptionVideoRepository');
    }
    return isSuccess;
  }
} 