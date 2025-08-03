import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/video_source.model.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/x_version_calculator_utils.dart';
import 'package:i_iwara/utils/common_utils.dart';

import '../../common/constants.dart';
import 'api_service.dart';

class VideoService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  static VideoService get to => Get.find<VideoService>();

  /// 根据提供的查询参数获取视频列表。
  ///
  /// 此方法向 `/videos` 端点发送带有给定查询参数的 GET 请求，并返回包含视频列表的 `ApiResult`。
  ///
  /// [params] 一个用于过滤视频的查询参数映射。
  /// - `sort` 排序方式。
  /// - `tags` 标签。
  /// - `date` 日期。
  /// - `rating` 内容评级。 general, ecchi
  /// - `user` 用户ID。
  /// - `exclude` 排除的视频ID。
  /// - `subscribed` 是否订阅。
  /// [page] 当前页码。
  /// [limit] 每页数据量。
  ///
  /// 返回一个包含 `Video` 对象列表、消息和状态码的 `ApiResult`。
  Future<ApiResult<PageData<Video>>> fetchVideosByParams({
    Map<String, dynamic> params = const {},
    int page = 0,
    int limit = 20,
    String? url,
  }) async {
    try {
      // [HACK_IMPLEMENT] 如果params里有的值为空字符串，则去掉key
      // 我靠，iwara站的搜索居然连空字符串都用于搜索了，哎
      params = Map<String, dynamic>.from(params)
        ..removeWhere((key, value) => value == '');
      url ??= ApiConstants.videos();
      final response = await _apiService.get(url, queryParameters: {
        ...params,
        'page': page,
        'limit': limit,
      });

      final List<Video> results = (response.data['results'] as List)
          .map((video) => Video.fromJson(video))
          .toList();

      final PageData<Video> pageData = PageData(
        page: response.data['page'],
        limit: response.data['limit'],
        count: response.data['count'],
        results: results,
      );

      return ApiResult.success(data: pageData);
    } catch (e) {
      LogUtils.e('获取视频列表失败', tag: 'VideoService', error: e);
      // 使用CommonUtils.parseExceptionMessage来获取具体的错误信息
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  /// 根据视频ID获取相关视频列表。
  Future<ApiResult<PageData<Video>>> fetchRelatedVideosByVideoId(String mediaId,
      {int page = 0, int limit = 20}) async {
    try {
      return await fetchVideosByParams(
          page: page, limit: limit, url: ApiConstants.relatedVideos(mediaId));
    } catch (e) {
      LogUtils.e('获取相关视频列表失败', tag: 'VideoService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  /// 作者的适配
  Future<ApiResult<PageData<Video>>> fetchAuthorVideos(String userId,
      {required String excludeVideoId, int limit = 6}) async {
    try {
      return await fetchVideosByParams(
        params: {
          'user': userId,
          'exclude': excludeVideoId,
        },
        limit: limit,
      );
    } catch (e) {
      LogUtils.e('获取作者视频列表失败', tag: 'VideoService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  /// 获取给这个视频点赞的用户列表
  Future<ApiResult<PageData<User>>> fetchLikeVideoUsers(String videoId,
      {int page = 0, int limit = 6}) async {
    try {
      final response = await _apiService.get(
        ApiConstants.videoLikes(videoId),
        queryParameters: {'page': page, 'limit': limit},
      );

      final List<User> results = (response.data['results'] as List)
          .map((userJson) => User.fromJson(userJson['user']))
          .toList();

      final PageData<User> pageData = PageData(
        page: response.data['page'],
        limit: response.data['limit'],
        count: response.data['count'],
        results: results,
      );

      return ApiResult.success(data: pageData);
    } catch (e) {
      LogUtils.e('获取视频点赞用户列表失败', tag: 'VideoService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  /// 获取最爱
  Future<ApiResult<PageData<Video>>> fetchFavoriteVideos(
      {int page = 0, int limit = 20}) async {
    try {
      final response = await _apiService
          .get(ApiConstants.favoriteVideos(), queryParameters: {
        'page': page,
        'limit': limit,
      });

      final List<Video> results = (response.data['results'] as List)
          .map((item) => Video.fromJson(item['video']))
          .toList();

      final PageData<Video> pageData = PageData(
        page: response.data['page'],
        limit: response.data['limit'],
        count: response.data['count'],
        results: results,
      );

      return ApiResult.success(data: pageData);
    } catch (e) {
      LogUtils.e('获取最爱视频列表失败', tag: 'VideoService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  /// 取消最爱
  Future<ApiResult<void>> cancelFavoriteVideo(String mediaId) async {
    try {
      await _apiService.delete(ApiConstants.likeVideo(mediaId));
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('取消最爱视频失败', tag: 'VideoService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  /// 设为最爱
  Future<ApiResult<void>> setFavoriteVideo(String mediaId) async {
    try {
      await _apiService.post(ApiConstants.likeVideo(mediaId));
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('设为最爱视频失败', tag: 'VideoService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  /// 点赞视频
  Future<ApiResult<void>> likeVideo(String mediaId) async {
    try {
      await _apiService.post(ApiConstants.likeVideo(mediaId));
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('点赞视频失败', tag: 'VideoService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  /// 取消点赞视频
  Future<ApiResult<void>> unlikeVideo(String mediaId) async {
    try {
      await _apiService.delete(ApiConstants.likeVideo(mediaId));
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('取消点赞视频失败', tag: 'VideoService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  /// 获取视频详情
  Future<Video?> getVideoInfoByVideoId(String? videoId) async {
    if (videoId == null) {
      return null;
    }
    try {
      final response = await _apiService.get(ApiConstants.video(videoId));
      return Video.fromJson(response.data);
    } catch (e) {
      LogUtils.e('获取视频详情失败', tag: 'VideoService', error: e);
      return null;
    }
  }

  /// 获取视频源
  Future<List<VideoSource>> getVideoSourcesBy(String? fileUrl) async {
    if (fileUrl == null) {
      return [];
    }
    try {
      final response = await _apiService.get(fileUrl, headers: {
        'X-Version':
            XVersionCalculatorUtil.calculateXVersion(fileUrl),
      });
      return (response.data as List).map((item) => VideoSource.fromJson(item)).toList();
    } catch (e) {
      LogUtils.e('获取视频源失败', tag: 'VideoService', error: e);
      return [];
    }
  }

  Future<String?> getVideoDownloadUrlByIdAndQuality(String id, String quality) async {
    if (id.isEmpty) {
      return null;
    }
    try {
      Video? videoInfo = await getVideoInfoByVideoId(id);
      if (videoInfo == null) {
        return null;
      }
      List<VideoSource> sources = await getVideoSourcesBy(videoInfo.fileUrl);
      VideoSource? source = sources.firstWhereOrNull((source) => source.name == quality);
      if (source == null) {
        return null;
      }
      return source.download;
    } catch (e) {
      LogUtils.e('获取视频下载链接失败', tag: 'VideoService', error: e);
      return null;
    }
  }
}
