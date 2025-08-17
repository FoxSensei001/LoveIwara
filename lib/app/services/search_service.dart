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
      // 保留原始错误信息而不是使用通用消息
      String errorMessage;
      
      // 使用CommonUtils.parseExceptionMessage来统一处理错误信息
      errorMessage = CommonUtils.parseExceptionMessage(e);
      
      // 如果还是空或者null，提供默认错误信息
      if (errorMessage.isEmpty || errorMessage == 'null') {
        if (e.toString().contains('HandshakeException')) {
          errorMessage = '网络连接失败，请检查网络设置或稍后重试';
        } else if (e.toString().contains('SocketException')) {
          errorMessage = '无法连接到服务器，请检查网络连接';
        } else if (e.toString().contains('TimeoutException')) {
          errorMessage = '请求超时，请稍后重试';
        } else {
          errorMessage = '搜索失败，请稍后重试';
        }
      }
      
      return ApiResult.fail(errorMessage);
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
    type: SearchSegment.video.apiType,
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
    type: SearchSegment.image.apiType,
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
    type: SearchSegment.user.apiType,
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
    type: SearchSegment.post.apiType,
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
    type: SearchSegment.forum.apiType,
    fromJson: ForumThreadModel.fromJson,
  );

  /// 获取Oreno3d视频
  Future<ApiResult<PageData<Oreno3dVideo>>> fetchOreno3dByQuery({
    int page = 0,
    int limit = 20,
    String query = '',
    String? sort,
    String? searchType, // 新增搜索类型参数：origin, tag, character
    Map<String, dynamic>? extData, // 新增扩展数据参数
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

  /// 获取播放列表
  Future<ApiResult<PageData<PlaylistModel>>> fetchPlaylistByQuery({
    int page = 0,
    int limit = 20,
    String query = '',
  }) => fetchDataByType<PlaylistModel>(
    page: page,
    limit: limit,
    query: query,
    type: SearchSegment.playlist.apiType,
    fromJson: PlaylistModel.fromJson,
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
