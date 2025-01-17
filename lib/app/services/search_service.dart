import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart';

import 'api_service.dart';

class SearchService extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  /// 通用查询方法
  Future<ApiResult<PageData<T>>> fetchDataByType<T>({
    int page = 0,
    int limit = 20,
    String query = '',
    required String type,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.search(),
        queryParameters: {
          'query': query,
          'page': page,
          'limit': limit,
          'type': type,
        },
      );

      final pageData = response.data;
      final List<T> results = (pageData['results'] as List)
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();

      return ApiResult.success(
        data: PageData<T>(
          page: pageData['page'],
          limit: pageData['limit'],
          count: pageData['count'],
          results: results,
        ),
      );
    } catch (e) {
      return ApiResult.fail(t.errors.failedToFetchData);
    }
  }

  /// 获取视频
  Future<ApiResult<PageData<Video>>> fetchVideoByQuery({
    int page = 0,
    int limit = 20,
    String query = '',
  }) => fetchDataByType<Video>(
    page: page,
    limit: limit,
    query: query,
    type: SearchSegment.video.name,
    fromJson: Video.fromJson,
  );

  /// 获取图库
  Future<ApiResult<PageData<ImageModel>>> fetchImageByQuery({
    int page = 0,
    int limit = 20,
    String query = '',
  }) => fetchDataByType<ImageModel>(
    page: page,
    limit: limit,
    query: query,
    type: SearchSegment.image.name,
    fromJson: ImageModel.fromJson,
  );

  /// 获取用户
  Future<ApiResult<PageData<User>>> fetchUserByQuery({
    int page = 0,
    int limit = 20,
    String query = '',
  }) => fetchDataByType<User>(
    page: page,
    limit: limit,
    query: query,
    type: SearchSegment.user.name,
    fromJson: User.fromJson,
  );

  /// 获取帖子
  Future<ApiResult<PageData<PostModel>>> fetchPostByQuery({
    int page = 0,
    int limit = 20,
    String query = '',
  }) => fetchDataByType<PostModel>(
    page: page,
    limit: limit,
    query: query,
    type: SearchSegment.post.name,
    fromJson: PostModel.fromJson,
  );

  /// 获取论坛
  Future<ApiResult<PageData<ForumThreadModel>>> fetchForumByQuery({
    int page = 0,
    int limit = 20,
    String query = '',
  }) => fetchDataByType<ForumThreadModel>(
    page: page,
    limit: limit,
    query: query,
    type: SearchSegment.forum.name,
    fromJson: ForumThreadModel.fromJson,
  );
}
