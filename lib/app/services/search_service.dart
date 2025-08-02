import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/oreno3d_video.model.dart';
import 'package:i_iwara/app/ui/pages/search/search_dialog.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart';

import 'api_service.dart';
import 'oreno3d_client.dart';

class SearchService extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  late final Oreno3dClient _oreno3dClient;

  @override
  void onInit() {
    super.onInit();
    _oreno3dClient = Oreno3dClient();
  }

  /// 通用查询方法
  Future<ApiResult<PageData<T>>> fetchDataByType<T>({
    int page = 0,
    int limit = 20,
    String query = '',
    required String type,
    required T Function(Map<String, dynamic>) fromJson,
    String? sort,
  }) async {
    try {
      final queryParameters = {
        'query': query,
        'page': page,
        'limit': limit,
        'type': type,
      };
      
      // 如果提供了 sort 参数，添加到查询参数中
      if (sort != null && sort.isNotEmpty) {
        queryParameters['sort'] = sort;
      }

      final response = await _apiService.get(
        ApiConstants.search(),
        queryParameters: queryParameters,
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
    String? sort,
  }) => fetchDataByType<Video>(
    page: page,
    limit: limit,
    query: query,
    type: SearchSegment.video.name,
    fromJson: Video.fromJson,
    sort: sort,
  );

  /// 获取图库
  Future<ApiResult<PageData<ImageModel>>> fetchImageByQuery({
    int page = 0,
    int limit = 20,
    String query = '',
    String? sort,
  }) => fetchDataByType<ImageModel>(
    page: page,
    limit: limit,
    query: query,
    type: SearchSegment.image.name,
    fromJson: ImageModel.fromJson,
    sort: sort,
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

  /// 获取Oreno3d视频
  Future<ApiResult<PageData<Oreno3dVideo>>> fetchOreno3dByQuery({
    int page = 0,
    int limit = 20,
    String query = '',
    String? sort,
  }) async {
    try {
      // 将排序类型转换为Oreno3dSortType
      Oreno3dSortType sortType = Oreno3dSortType.hot;
      if (sort != null) {
        switch (sort) {
          case 'hot':
            sortType = Oreno3dSortType.hot;
            break;
          case 'favorites':
            sortType = Oreno3dSortType.favorites;
            break;
          case 'latest':
            sortType = Oreno3dSortType.latest;
            break;
          case 'popularity':
            sortType = Oreno3dSortType.popularity;
            break;
          default:
            sortType = Oreno3dSortType.hot;
        }
      }

      final result = await _oreno3dClient.searchVideos(
        keyword: query,
        page: page + 1, // oreno3d使用1基页码
        sortType: sortType,
      );

      return ApiResult.success(
        data: PageData<Oreno3dVideo>(
          page: page,
          limit: limit,
          count: result.totalPages * limit, // 估算总数
          results: result.videos,
        ),
      );
    } catch (e) {
      return ApiResult.fail('搜索Oreno3d视频失败: $e');
    }
  }

  /// 获取Oreno3d视频详情
  Future<Oreno3dVideoDetail?> getOreno3dVideoDetail(String videoId) async {
    try {
      return await _oreno3dClient.getVideoDetailParsed(videoId);
    } catch (e) {
      rethrow;
    }
  }
}
