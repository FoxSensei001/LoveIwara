import 'package:dio/dio.dart' show DioException;
import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/light_play_list.model.dart';
import 'package:i_iwara/app/models/page_data.model.dart';
import 'package:i_iwara/app/models/play_list.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/models/video.model.dart';
import 'package:i_iwara/app/models/iwara_site.dart';
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/app/services/iwara_site_headers.dart';
import 'package:i_iwara/app/utils/iwara_different_site_recovery.dart';
import 'package:i_iwara/utils/common_utils.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 一张播放列表的名称与主人。
typedef PlaylistInfo = ({String title, User? user});

class PlayListService extends GetxService {
  final ApiService apiService = Get.find<ApiService>();

  /// 某个播放列表**实际属于**哪个站。
  ///
  /// 一次跨站回退成功之后记在这里，后面翻页就直接钉那个站，不用每页都先撞一次
  /// 404。会话级缓存，超量按先进先出丢。
  final Map<String, IwaraSite> _playlistSiteHints = <String, IwaraSite>{};
  static const int _maxSiteHints = 64;

  void _rememberPlaylistSite(String playlistId, IwaraSite site) {
    _playlistSiteHints[playlistId] = site;
    while (_playlistSiteHints.length > _maxSiteHints) {
      _playlistSiteHints.remove(_playlistSiteHints.keys.first);
    }
  }

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
      final response = await apiService.get(
        '/playlists',
        queryParameters: {'user': userId, 'page': page, 'limit': limit},
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
  Future<ApiResult<List<LightPlaylistModel>>> getLightPlaylists({
    required String videoId,
  }) async {
    try {
      final response = await apiService.get(
        '/light/playlists',
        queryParameters: {'id': videoId},
      );
      return ApiResult.success(
        data: (response.data as List)
            .map((playlistModel) => LightPlaylistModel.fromJson(playlistModel))
            .toList(),
      );
    } catch (e) {
      LogUtils.e('获取轻量播放列表失败', tag: 'PlayListService', error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  /// 获取播放列表的名称与**主人**。走的是同一条 `/playlist/{id}`，跨站那条坑
  /// 一模一样（见 [getPlaylistVideos]），回退逻辑共用。
  ///
  /// 主人是给「接着看」用的：从第三个人的播放列表进来时，那张列表既不属于我
  /// 也不属于这条视频的作者，抽屉要靠它开出「他人的播放列表」那一条
  /// （见 `PlaylistPlaybackQueue.owner`）。服务端没给 user 就为 null，
  /// **不影响名称**——名称拿得到就算成功。
  Future<ApiResult<PlaylistInfo>> getPlaylistInfo({
    required String playlistId,
  }) async {
    try {
      final info = await _withPlaylistSiteFallback(playlistId, (site) async {
        final response = await apiService.get(
          '/playlist/$playlistId',
          site: site,
        );
        final playlist = response.data['playlist'] as Map<String, dynamic>;
        final rawUser = playlist['user'];
        return (
          title: playlist['title'] as String,
          user: rawUser is Map<String, dynamic>
              ? User.fromJson(rawUser)
              : null,
        );
      });
      return ApiResult.success(data: info);
    } catch (e) {
      LogUtils.e(
        '获取播放列表信息失败（${_statusOf(e)}，body=${_bodyOf(e)}）',
        tag: 'PlayListService',
        error: e,
      );
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

  /// 获取播放列表的视频。
  ///
  /// # ⛔ 播放列表是**按站**存的，而列表接口不是
  ///
  /// `/light/playlists` 会把用户的播放列表全都列出来，但 `/playlist/{id}` 只在
  /// 该列表所属的那个站下才有——用另一个站的 `x-site` 去取，服务端**只回一个
  /// 404**（不是那条明说的 `errors.differentSite`）。表现就是：在 AI 站看视频
  /// 时，从「接着看」里挑一张自己在主站建的播放列表，永远是"加载失败，点击
  /// 重试"（2026-08-29 真机报障）。
  ///
  /// 所以这里在 404 时**换另一个站再试一次**：成功就把这张列表属于哪个站记下来
  /// （[_playlistSiteHints]），后面翻页直接钉过去。两站都取不到才算真失败，
  /// 并且交回**第一次**的错误——那才是用户当前站点下的真实情况。
  ///
  /// ⚠️ 跨站取回来的条目是另一个站的视频，点开会触发既有的
  /// [IwaraDifferentSiteRecovery]（切站 + 重开）。那是这个 App 一直以来处理跨站
  /// 资源的方式，不是这里新引入的。
  Future<ApiResult<PageData<Video>>> getPlaylistVideos({
    required String playlistId,
    int page = 0,
    int limit = 32,
  }) async {
    try {
      final pageData = await _withPlaylistSiteFallback(
        playlistId,
        (site) => _requestPlaylistVideos(
          playlistId,
          page: page,
          limit: limit,
          site: site,
        ),
      );
      return ApiResult.success(data: pageData);
    } catch (e) {
      // ⛔ 把响应体也记下来：跨站、被删、无权限在状态码上分不开，
      // 只有服务端那句 message 能把它们分开。
      LogUtils.e(
        '获取播放列表视频失败（${_statusOf(e)}，body=${_bodyOf(e)}）',
        tag: 'PlayListService',
        error: e,
      );
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }

  /// 先按当前站（或已记下的那个站）请求；只回了个 404 就换另一个站再试一次。
  ///
  /// 成功后把这张播放列表属于哪个站记进 [_playlistSiteHints]，后面翻页直接钉
  /// 过去、不用每页先撞一次 404。两站都不行就抛**第一次**的错误——那才是用户
  /// 当前站点下的真实情况。
  Future<T> _withPlaylistSiteFallback<T>(
    String playlistId,
    Future<T> Function(IwaraSite? site) request,
  ) async {
    final IwaraSite? hint = _playlistSiteHints[playlistId];
    final IwaraSite preferred = hint ?? currentIwaraSiteOrMain();
    try {
      // 没有提示时不钉站，跟着全局站点模式走（绝大多数情况就是对的那个）。
      final result = await request(hint);
      _rememberPlaylistSite(playlistId, preferred);
      return result;
    } catch (e) {
      if (!IwaraDifferentSiteRecovery.mayBeWrongSite(e)) rethrow;
      final IwaraSite fallback = preferred == IwaraSite.main
          ? IwaraSite.ai
          : IwaraSite.main;
      LogUtils.w(
        '播放列表 $playlistId 在 ${preferred.shortLabel} 站取不到'
            '（${_statusOf(e)}），改用 ${fallback.shortLabel} 站再试一次',
        'PlayListService',
      );
      try {
        final result = await request(fallback);
        _rememberPlaylistSite(playlistId, fallback);
        LogUtils.i(
          '播放列表 $playlistId 属于 ${fallback.shortLabel} 站，已改钉该站',
          'PlayListService',
        );
        return result;
      } catch (fallbackError) {
        LogUtils.w(
          '播放列表 $playlistId 在 ${fallback.shortLabel} 站同样取不到'
              '（${_statusOf(fallbackError)}）',
          'PlayListService',
        );
        rethrow;
      }
    }
  }

  Future<PageData<Video>> _requestPlaylistVideos(
    String playlistId, {
    required int page,
    required int limit,
    IwaraSite? site,
  }) async {
    final response = await apiService.get(
      '/playlist/$playlistId',
      queryParameters: {'page': page, 'limit': limit},
      site: site,
    );
    return PageData(
      page: response.data['page'],
      limit: response.data['limit'],
      count: response.data['count'],
      results: (response.data['results'] as List)
          .map((video) => Video.fromJson(video))
          .toList(),
    );
  }

  String _statusOf(Object? error) {
    final status = error is DioException ? error.response?.statusCode : null;
    return status == null ? '无状态码' : 'status=$status';
  }

  /// 响应体截一小段进日志——完整 body 可能很大，且没必要。
  String _bodyOf(Object? error) {
    final data = error is DioException ? error.response?.data : null;
    if (data == null) return '空';
    final text = data.toString();
    return text.length > 200 ? '${text.substring(0, 200)}…' : text;
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
