import '../controllers/follow_search_controller.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 粉丝列表数据源。
///
/// 继承 [ExtendedLoadingMoreBase]（而不是裸的 LoadingMoreBase）才能同时喂
/// 瀑布流与分页两种模式：分页模式走 `loadPageData()` 直接取某一页。
class FollowersListRepository extends ExtendedLoadingMoreBase<User> {
  final UserService _userService = Get.find();
  final String userId;

  final FollowSearchController search;

  FollowersListRepository(this.userId, {required this.search});

  @override
  void resetPagingState() {
    super.resetPagingState();
    search.reset();
  }

  @override
  Future<Map<String, dynamic>> fetchDataFromSource(
    Map<String, dynamic> params,
    int page,
    int limit,
  ) async {
    final generation = currentGeneration;
    final result = await _userService.fetchFollowers(
      page: page,
      limit: limit,
      userId: userId,
      cancelToken: cancelToken,
    );
    if (result.isSuccess && result.data != null) {
      if (!isStaleGeneration(generation)) search.recordLoaded(result.data!);
      return {'data': result.data!};
    }
    throw Exception(result.message);
  }

  @override
  List<User> extractDataList(Map<String, dynamic> response) =>
      (response['data'] as PageData<User>).results;

  @override
  int extractTotalCount(Map<String, dynamic> response) =>
      (response['data'] as PageData<User>).count;

  @override
  void logError(String message, dynamic error, [StackTrace? stackTrace]) {
    LogUtils.e(
      '加载粉丝列表失败: $message',
      error: error,
      stack: stackTrace,
      tag: 'FollowersListRepository',
    );
  }
}
