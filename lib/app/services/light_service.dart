import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';

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

  /// 获取规则内容
  Future<ApiResult<String>> fetchRule(String id) async {
    try {
      final response = await _apiService.get(ApiConstants.lightRule(id));
      if (response.data == null) {
        return ApiResult.fail(t.errors.failedToFetchData);
      }

      final data = response.data as Map<String, dynamic>;
      final configService = Get.find<ConfigService>();
      String currentLocale = configService.settings[ConfigKey.APPLICATION_LOCALE]?.value ?? 'en';
      if (currentLocale == 'system') {
        currentLocale = CommonUtils.getDeviceLocale();
      }
      String? title;

      // 尝试获取当前语言的标题
      if (currentLocale.startsWith('zh')) {
        title = data['title']?['zh'] ?? data['title']?['en'] ?? '';
      } else if (currentLocale.startsWith('ja')) {
        title = data['title']?['ja'] ?? data['title']?['en'] ?? '';
      }

      // 如果没有找到对应语言的标题，使用英文标题
      title ??= data['title']?['en'] ?? '';

      if (title == null || title.isEmpty) {
        return ApiResult.fail(t.errors.failedToFetchData);
      }

      return ApiResult.success(data: title);
    } catch (e) {
      LogUtils.e('获取规则失败', tag: 'LightService', error: e);
      return ApiResult.fail(t.errors.errorWhileFetching);
    }
  }

} 