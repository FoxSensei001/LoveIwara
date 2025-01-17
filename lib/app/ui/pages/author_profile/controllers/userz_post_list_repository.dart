import 'package:get/get.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/services/post_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:loading_more_list/loading_more_list.dart';

class UserzPostListRepository extends LoadingMoreBase<PostModel> {
  final PostService _postService = Get.find<PostService>();
  final String userId;
  UserzPostListRepository({required this.userId, this.maxLength = 300});
  
  int _pageIndex = 0;
  bool _hasMore = true;
  bool forceRefresh = false;
  final int maxLength;

  @override
  bool get hasMore => (_hasMore && length < maxLength) || forceRefresh;

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
      final result = await _postService.fetchUserPostList(
        userId,
        page: _pageIndex,
        limit: 10,
      );

      if (!result.isSuccess) {
        throw Exception(result.message);
      }

      if (_pageIndex == 0) {
        clear();
      }

      final posts = result.data?.results ?? [];
      for (final post in posts) {
        add(post);
      }

      _hasMore = posts.isNotEmpty;
      _pageIndex++;
      isSuccess = true;
    } catch (exception, stack) {
      isSuccess = false;
      LogUtils.e('加载作者帖子列表失败',
          error: exception, stack: stack, tag: 'UserzPostListRepository');
    }
    return isSuccess;
  }
} 