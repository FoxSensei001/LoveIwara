import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/light_play_list.model.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/play_list.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';

class PlayListService extends GetxService {
  final ApiService apiService = Get.find<ApiService>();

  // 创建播放列表
  Future<ApiResult<void>> createPlaylist({required String title}) async {
    try {
      await apiService.post('/playlists', data: {'title': title});
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('创建播放列表失败', tag: 'PlayListService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  // 编辑播放列表标题
  Future<ApiResult<void>> editPlaylistTitle({
    required String playlistId,
    required String title,
  }) async {
    try {
      await apiService.put('/playlist/$playlistId', data: {'title': title});
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('编辑播放列表标题失败', tag: 'PlayListService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  // 获取播放列表
  Future<ApiResult<PageData<PlaylistModel>>> getPlaylists({
    required String userId,
    required int page,
    int limit = 20,
  }) async {
    try {
      final response = await apiService.get('/playlists', 
        queryParameters: {
          'user': userId,
          'page': page,
          'limit': limit,
        }
      );
      
      final PageData<PlaylistModel> pageData = PageData(
        page: response.data['page'],
        limit: response.data['limit'],
        count: response.data['count'],
        results: (response.data['results'] as List)
          .map((playlistModel) => PlaylistModel.fromJson(playlistModel))
          .toList(),
      );
      return ApiResult.success(data: pageData);
    } catch (e) {
      LogUtils.e('获取播放列表失败', tag: 'PlayListService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  // 获取轻量播放列表
  // 此接口会一次性返回所有的播放列表
  // 根据视频id获取播放列表，{@link LightPlaylistModel#added} 为 true 表示已添加到播放列表
  Future<ApiResult<List<LightPlaylistModel>>> getLightPlaylists({required String videoId}) async {
    try {
      final response = await apiService.get('/light/playlists', queryParameters: {'id': videoId});
      return ApiResult.success(data: (response.data as List).map((playlistModel) => LightPlaylistModel.fromJson(playlistModel)).toList());
    } catch (e) {
      LogUtils.e('获取轻量播放列表失败', tag: 'PlayListService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  // 获取播放列表名称
  Future<ApiResult<String>> getPlaylistName({required String playlistId}) async {
    try {
      final response = await apiService.get('/playlist/$playlistId');
      return ApiResult.success(data: response.data['playlist']['title']);
    } catch (e) {
      LogUtils.e('获取播放列表名称失败', tag: 'PlayListService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  // 添加视频到播放列表
  Future<ApiResult<void>> addToPlaylist({
    required String videoId,
    required String playlistId,
  }) async {
    try {
      await apiService.post('/playlist/$playlistId/$videoId');
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('添加视频到播放列表失败', tag: 'PlayListService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  // 从播放列表移除视频
  Future<ApiResult<void>> removeFromPlaylist({
    required String videoId,
    required String playlistId,
  }) async {
    try {
      await apiService.delete('/playlist/$playlistId/$videoId');
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('从播放列表移除视频失败', tag: 'PlayListService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  // 获取播放列表的视频
  Future<ApiResult<PageData<Video>>> getPlaylistVideos({
    required String playlistId,
    int page = 0,
    int limit = 32,
  }) async {
    try {
      final response = await apiService.get(
        '/playlist/$playlistId', 
        queryParameters: {
          'page': page,
          'limit': limit,
        }
      );
      
      final PageData<Video> pageData = PageData(
        page: response.data['page'],
        limit: response.data['limit'],
        count: response.data['count'],
        results: (response.data['results'] as List)
          .map((video) => Video.fromJson(video))
          .toList(),
      );

      return ApiResult.success(data: pageData);
    } catch (e) {
      LogUtils.e('获取播放列表视频失败', tag: 'PlayListService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  // 删除此播放列表
  Future<ApiResult<void>> deletePlaylist({required String playlistId}) async {
    try {
      await apiService.delete('/playlist/$playlistId');
      return ApiResult.success();
    } catch (e) {
      LogUtils.e('删除播放列表失败', tag: 'PlayListService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }
}
