import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/i18n/strings.g.dart';
// import 'package:i_iwara/utils/logger_utils.dart';

import '../../common/constants.dart';
import 'api_service.dart';

class LightService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  /// 获取轻量论坛帖子标题
  Future<ApiResult<String>> fetchLightForumTitle(String forumId) async {
    try {
      final response = await _apiService.get(ApiConstants.lightForum(forumId));
      return ApiResult.success(data: response.data['title']);
    } catch (e) {
      // LogUtils.e('获取轻量论坛帖子标题失败', tag: 'LightService', error: e);
      return ApiResult.fail(t.errors.failedToFetchData);
    }
  }

  /// 获取轻量图片标题
  Future<ApiResult<String>> fetchLightImageTitle(String imageId) async {
    try {
      final response = await _apiService.get(ApiConstants.lightImage(imageId));
      return ApiResult.success(data: response.data['title']);
    } catch (e) {
      // LogUtils.e('获取轻量图片标题失败', tag: 'LightService', error: e);
      return ApiResult.fail(t.errors.failedToFetchData);
    }
  }

  /// 获取轻量视频标题
  Future<ApiResult<String>> fetchLightVideoTitle(String videoId) async {
    try {
      final response = await _apiService.get(ApiConstants.lightVideo(videoId));
      return ApiResult.success(data: response.data['title']);
    } catch (e) {
      // LogUtils.e('获取轻量视频标题失败', tag: 'LightService', error: e);
      return ApiResult.fail(t.errors.failedToFetchData);
    }
  }

  /// 获取用户资料信息
  /// result: {
  ///   "username": "username",
  ///   "name": "xxx"
  /// }
  Future<ApiResult<Map<String, dynamic>>> fetchLightProfile(String userId) async {
    try {
      final response = await _apiService.get(ApiConstants.lightProfile(userId));
      return ApiResult.success(data: response.data);
    } catch (e) {
      // LogUtils.e('获取用户资料失败', tag: 'LightService', error: e);
      return ApiResult.fail(t.errors.failedToFetchData);
    }
  }

  /// 获取播放列表信息
  Future<ApiResult<String>> fetchPlaylistInfo(String playlistId) async {
    try {
      final response = await _apiService.get(ApiConstants.lightPlaylist(playlistId));
      return ApiResult.success(data: response.data['title']);
    } catch (e) {
      // LogUtils.e('获取播放列表信息失败', tag: 'LightService', error: e);
      return ApiResult.fail(t.errors.failedToFetchData);
    }
  }
} 