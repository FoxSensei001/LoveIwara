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
/// 模式切过去并重新加载当前页面，而不是把错误直接抛给用户。
///
/// 切站走 [AppService.applyGlobalSiteMode]（`resetNavigation: false`）：它会重建
/// 应用子树，当前 go_router 路由栈随之重建，详情页会以新的站点模式重新发起请求。
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
  ///
  /// 返回 true 表示已切换站点并触发重载，调用方应立即返回、不要再展示错误界面；
  /// 返回 false 表示这不是跨站错误、或已经为该资源切过同一个站点（无法恢复），
  /// 调用方应继续走原有的错误处理。
  static Future<bool> recover(
    Object? error, {
    required String resourceKey,
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

    await appService.applyGlobalSiteMode(targetSite, resetNavigation: false);
    return true;
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
