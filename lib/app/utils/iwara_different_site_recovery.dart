import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:i_iwara/app/models/iwara_site.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 跨站资源的自动纠正。
///
/// 同一套 API（apiq.iwara.tv）同时服务主站与 AI 站，站点由请求头 `x-site` 决定。
/// 用主站模式去请求一个属于 AI 站的资源（反之亦然）时，服务端不会返回内容，而是：
///
/// ```json
/// {"message": "errors.differentSite", "siteId": "iwara_ai"}
/// ```
///
/// 这类失败不是"资源不存在/无权限"，而是"站点选错了"。此时应按 `siteId` 把全局站点
/// 模式切过去并重新请求，而不是把错误直接抛给用户。
///
/// 恢复动作是「**退回首页 → 重建整棵树 → 在新站点重新打开这个资源**」：
/// [AppService.applyGlobalSiteMode] 会把导航复位到首页并重启子树，之后由调用方
/// 通过 [recover] 的 `reopen` 重新 push 自己那张详情页。
///
/// 为什么不是"就地把请求重发一遍"：切站之后路由栈里堆着的全是另一个站点的页面
/// （来源列表、上一张详情页……），留着它们只会让用户在错的站点里继续点下去，又
/// 触发一次切站。而且重建整棵树本来就会把当前页面的 State 连同它正在进行的加载
/// 一起换掉——原地重试的代码根本活不到执行，页面只会永远转圈。所以：栈清掉，
/// 资源重新打开一张干净的页面。
class IwaraDifferentSiteRecovery {
  const IwaraDifferentSiteRecovery._();

  static const String _tag = 'IwaraDifferentSiteRecovery';

  /// 服务端跨站错误的 message 值。
  static const String errorMessage = 'errors.differentSite';

  static const int _maxTrackedResources = 64;

  /// 已经为某个资源自动切过的站点，用于防止 A→B→A 无限切站重启。
  static final Map<String, Set<IwaraSite>> _attemptedSites =
      <String, Set<IwaraSite>>{};

  /// 从异常（[DioException]）、[Response] 或响应体 Map 中解析出资源真正所属的站点。
  /// 不是跨站错误、或 `siteId` 无法识别时返回 null。
  static IwaraSite? resolveTargetSite(Object? error) {
    final data = _responseData(error);
    if (data is! Map) {
      return null;
    }
    if (data['message'] != errorMessage) {
      return null;
    }
    return IwaraSiteUtils.fromSiteId(data['siteId']?.toString());
  }

  static bool isDifferentSiteError(Object? error) =>
      resolveTargetSite(error) != null;

  /// 尝试接管一次跨站失败。
  ///
  /// [resourceKey] 用于去重的资源标识，形如 `video:xxxx` / `image:xxxx`。
  /// [reopen] 在新站点重新打开这个资源（通常是一句 `NaviService.navigateToXxx(id)`），
  /// 会在导航复位到首页、整棵树重建之后执行；不传则只切站、停在首页。
  ///
  /// 返回 true 表示已接管：站点在切、页面在重开，调用方**直接 return**，不要再展示
  /// 错误界面，也不要自己重试（当前这张页面马上就没了）。
  /// 返回 false 表示这不是跨站错误、或已经为该资源切过同一个站点（无法恢复），
  /// 调用方应继续走原有的错误处理。
  static Future<bool> recover(
    Object? error, {
    required String resourceKey,
    void Function()? reopen,
  }) async {
    final targetSite = resolveTargetSite(error);
    if (targetSite == null) {
      return false;
    }

    if (!Get.isRegistered<AppService>()) {
      LogUtils.w('AppService 未注册，无法自动切站: $resourceKey', _tag);
      return false;
    }

    final appService = Get.find<AppService>();
    if (appService.currentSiteMode == targetSite) {
      // 已经在目标站却仍被判为跨站：切站解决不了，交回原错误处理。
      LogUtils.w('当前已是 ${targetSite.name} 站仍返回跨站错误: $resourceKey', _tag);
      return false;
    }

    if (!_markAttempt(resourceKey, targetSite)) {
      LogUtils.w('已为 $resourceKey 切换过 ${targetSite.name} 站，放弃再次切换以避免循环', _tag);
      return false;
    }

    LogUtils.i(
      '检测到跨站资源 $resourceKey，'
      '站点模式 ${appService.currentSiteMode.name} -> ${targetSite.name}',
      _tag,
    );

    // resetNavigation: 把栈清回首页，别把另一个站点的历史页面留在返回路径上。
    // onApplied 在新树的第一帧之后跑，这时 push 进去的是一张全新的详情页。
    await appService.applyGlobalSiteMode(
      targetSite,
      onApplied: reopen == null
          ? null
          : () async {
              LogUtils.i('切站完成，重新打开 $resourceKey', _tag);
              reopen();
            },
    );
    return true;
  }

  /// 资源已经成功加载：清掉为它切站的记录。
  ///
  /// [_attemptedSites] 只是"同一个资源别来回切"的防抖，一旦这次真的把资源打开了，
  /// 这条记录就该作废——否则用户切回原站点后再点同一个视频，会因为"切过一次"而
  /// 拿到错误页而不是自动纠正。
  static void markResolved(String resourceKey) {
    _attemptedSites.remove(resourceKey);
  }

  /// 记录一次切站尝试；若该资源已经切过同一个站点则返回 false。
  static bool _markAttempt(String resourceKey, IwaraSite site) {
    final sites = _attemptedSites.putIfAbsent(resourceKey, () => <IwaraSite>{});
    if (!sites.add(site)) {
      return false;
    }

    // 简单的 FIFO 上限，避免长会话里无限累积。
    while (_attemptedSites.length > _maxTrackedResources) {
      _attemptedSites.remove(_attemptedSites.keys.first);
    }
    return true;
  }

  static dynamic _responseData(Object? error) {
    if (error is DioException) {
      return error.response?.data;
    }
    if (error is Response) {
      return error.data;
    }
    if (error is Map) {
      return error;
    }
    return null;
  }

  @visibleForTesting
  static void clearAttempts() => _attemptedSites.clear();
}
