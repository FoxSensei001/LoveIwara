import 'package:get/get.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/user_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 关注列表数据源。
///
/// 继承 [ExtendedLoadingMoreBase]（而不是裸的 LoadingMoreBase）才能同时喂
/// 瀑布流与分页两种模式：分页模式走 `loadPageData()` 直接取某一页。
class FollowingListRepository extends ExtendedLoadingMoreBase<User> {
  final UserService _userService = Get.find();
  final String userId;

  FollowingListRepository(this.userId);

  @override
  Future<Map<String, dynamic>> fetchDataFromSource(
    Map<String, dynamic> params,
    int page,
    int limit,
  ) async {
    final result = await _userService.fetchFollowingUsers(
      page: page,
      limit: limit,
      userId: userId,
    );
    if (result.isSuccess && result.data != null) {
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
      '加载关注列表失败: $message',
      error: error,
      stack: stackTrace,
      tag: 'FollowingListRepository',
    );
  }
}
