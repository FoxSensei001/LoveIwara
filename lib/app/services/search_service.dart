import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/forum.model.dart';
import 'package:i_iwara/app/models/image.model.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/post.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/oreno3d_video.model.dart';
import 'package:i_iwara/app/models/play_list.model.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

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

  @override
  void onClose() {
    // 释放 oreno3d 客户端的底层 Dio，避免 service 销毁后连接/拦截器泄漏
    _oreno3dClient.close();
    super.onClose();
  }

  /// 通用查询方法
  Future<ApiResult<PageData<T>>> fetchDataByType<T>({
    int page = 0,
    int limit = 20,
    String query = '',
    required String type,
    required T Function(Map<String, dynamic>) fromJson,
    String? sort,
    CancelToken? cancelToken,
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
        cancelToken: cancelToken,
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
      // 请求被取消（快速切换查询/列表被替换）：静默返回，不作为错误展示
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return ApiResult.fail('cancelled');
      }

      // 基于 DioException 的类型分类，而非脆弱的 e.toString().contains 匹配
      String errorMessage = CommonUtils.parseExceptionMessage(e);
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = slang.t.search.searchRequestTimeout;
            break;
          case DioExceptionType.connectionError:
            errorMessage = slang.t.search.searchCannotConnectToServer;
            break;
          case DioExceptionType.badCertificate:
            errorMessage = slang.t.search.searchNetworkError;
            break;
          default:
            if (errorMessage.isEmpty || errorMessage == 'null') {
              errorMessage = slang.t.search.searchFailedPleaseRetry;
            }
        }
      } else if (errorMessage.isEmpty || errorMessage == 'null') {
        errorMessage = slang.t.search.searchFailedPleaseRetry;
      }

      return ApiResult.fail(errorMessage);
    }
  }

  /// 获取视频
  Future<ApiResult<PageData<Video>>> fetchVideoByQuery({
    int page = 0,
    int limit = 20,
    String query = '',
    String? sort,
    CancelToken? cancelToken,
  }) => fetchDataByType<Video>(
    page: page,
    limit: limit,
    query: query,
    type: SearchSegment.video.apiType,
    fromJson: Video.fromJson,
    sort: sort,
    cancelToken: cancelToken,
  );

  /// 获取图库
  Future<ApiResult<PageData<ImageModel>>> fetchImageByQuery({
    int page = 0,
    int limit = 20,
    String query = '',
    String? sort,
    CancelToken? cancelToken,
  }) => fetchDataByType<ImageModel>(
    page: page,
    limit: limit,
    query: query,
    type: SearchSegment.image.apiType,
    fromJson: ImageModel.fromJson,
    sort: sort,
    cancelToken: cancelToken,
  );

  /// 获取用户
  Future<ApiResult<PageData<User>>> fetchUserByQuery({
    int page = 0,
    int limit = 20,
    String query = '',
    String? sort,
    CancelToken? cancelToken,
  }) => fetchDataByType<User>(
    page: page,
    limit: limit,
    query: query,
    type: SearchSegment.user.apiType,
    fromJson: User.fromJson,
    sort: sort,
    cancelToken: cancelToken,
  );

  /// 获取帖子
  Future<ApiResult<PageData<PostModel>>> fetchPostByQuery({
    int page = 0,
    int limit = 20,
    String query = '',
    String? sort,
    CancelToken? cancelToken,
  }) => fetchDataByType<PostModel>(
    page: page,
    limit: limit,
    query: query,
    type: SearchSegment.post.apiType,
    fromJson: PostModel.fromJson,
    sort: sort,
    cancelToken: cancelToken,
  );

  /// 获取论坛
  Future<ApiResult<PageData<ForumThreadModel>>> fetchForumByQuery({
    int page = 0,
    int limit = 20,
    String query = '',
    String? sort,
    CancelToken? cancelToken,
  }) => fetchDataByType<ForumThreadModel>(
    page: page,
    limit: limit,
    query: query,
    type: SearchSegment.forum.apiType,
    fromJson: ForumThreadModel.fromJson,
    sort: sort,
    cancelToken: cancelToken,
  );

  /// 获取论坛帖子回复
  Future<ApiResult<PageData<ThreadCommentModel>>> fetchForumPostsByQuery({
    int page = 0,
    int limit = 20,
    String query = '',
    String? sort,
    CancelToken? cancelToken,
  }) => fetchDataByType<ThreadCommentModel>(
    page: page,
    limit: limit,
    query: query,
    type: SearchSegment.forum_posts.apiType,
    fromJson: ThreadCommentModel.fromJson,
    sort: sort,
    cancelToken: cancelToken,
  );

  /// 获取Oreno3d视频
  Future<ApiResult<PageData<Oreno3dVideo>>> fetchOreno3dByQuery({
    int page = 0,
    int limit = 20,
    String query = '',
    String? sort,
    String? searchType, // 新增搜索类型参数：origin, tag, character
    Map<String, dynamic>? extData, // 新增扩展数据参数
    CancelToken? cancelToken,
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

      // 根据扩展数据或搜索类型确定API端点
      String api = '/search';
      String searchKeyword = query;

      if (extData != null) {
        final type = extData['searchType'] as String?;
        final id = extData['id'] as String?;

        if (type != null && id != null) {
          switch (type) {
            case 'origin':
              api = '/origins/$id';
              searchKeyword = ''; // 特定类型搜索不需要关键词
              break;
            case 'tag':
              api = '/tags/$id';
              searchKeyword = ''; // 特定类型搜索不需要关键词
              break;
            case 'character':
              api = '/characters/$id';
              searchKeyword = ''; // 特定类型搜索不需要关键词
              break;
            default:
              api = '/search';
          }
        }
      } else if (searchType != null && query.isNotEmpty) {
        // 保持向后兼容性
        switch (searchType) {
          case 'origin':
            api = '/origins/$query';
            searchKeyword = '';
            break;
          case 'tag':
            api = '/tags/$query';
            searchKeyword = '';
            break;
          case 'character':
            api = '/characters/$query';
            searchKeyword = '';
            break;
          default:
            api = '/search';
        }
      }

      final result = await _oreno3dClient.searchVideos(
        keyword: searchKeyword,
        page: page + 1, // oreno3d使用1基页码
        sortType: sortType,
        api: api,
        cancelToken: cancelToken,
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
      // 请求被取消时静默返回，不展示错误
      if (e is DioException && e.type == DioExceptionType.cancel) {
        return ApiResult.fail('cancelled');
      }
      return ApiResult.fail('搜索Oreno3d视频失败: $e');
    }
  }

  /// 获取播放列表
  Future<ApiResult<PageData<PlaylistModel>>> fetchPlaylistByQuery({
    int page = 0,
    int limit = 20,
    String query = '',
    String? sort,
    CancelToken? cancelToken,
  }) => fetchDataByType<PlaylistModel>(
    page: page,
    limit: limit,
    query: query,
    type: SearchSegment.playlist.apiType,
    fromJson: PlaylistModel.fromJson,
    sort: sort,
    cancelToken: cancelToken,
  );

  /// 获取Oreno3d视频详情
  Future<Oreno3dVideoDetail?> getOreno3dVideoDetail(
    String videoId, {
    CancelToken? cancelToken,
  }) async {
    try {
      return await _oreno3dClient.getVideoDetailParsed(videoId, cancelToken: cancelToken);
    } catch (e) {
      rethrow;
    }
  }
}
