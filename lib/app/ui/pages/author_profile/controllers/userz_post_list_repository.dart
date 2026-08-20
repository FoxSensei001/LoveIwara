import 'package:get/get.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/services/post_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/media_list_view.dart';
import 'package:i_iwara/utils/logger_utils.dart';

class UserzPostListRepository extends ExtendedLoadingMoreBase<PostModel> {
  final PostService _postService = Get.find<PostService>();
  final String userId;
  UserzPostListRepository({required this.userId});

  @override
  Future<Map<String, dynamic>> fetchDataFromSource(
    Map<String, dynamic> params,
    int page,
    int limit,
  ) async {
    final result = await _postService.fetchUserPostList(
      userId,
      page: page,
      limit: limit,
    );
    if (!result.isSuccess || result.data == null) {
      throw Exception(result.message);
    }
    return {'data': result.data!};
  }

  @override
  List<PostModel> extractDataList(Map<String, dynamic> response) =>
      (response['data'] as PageData<PostModel>).results;

  @override
  int extractTotalCount(Map<String, dynamic> response) =>
      (response['data'] as PageData<PostModel>).count;

  @override
  void logError(String message, dynamic error, [StackTrace? stackTrace]) {
    LogUtils.e(
      '加载作者帖子列表失败: $message',
      error: error,
      stack: stackTrace,
      tag: 'UserzPostListRepository',
    );
  }
}
