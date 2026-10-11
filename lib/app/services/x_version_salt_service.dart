import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as d_dio;
import 'package:get/get.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/x_version_calculator_utils.dart';

import 'config_service.dart';
import 'http_client_factory.dart';

/// 视频源签名（X-Version）盐值的自动更新。
///
/// 盐值写死在官网前端的 `main.<hash>.js` 里，官方换过盐（2026-02 那次，
/// 所有人都要等发新版才能正常看视频）。
///
/// ⛔ 盐值不对时文件服务器**不报错**：照样返回 200，只是清单里只剩
/// 360 / preview 两档（没有签名时也一样）。用户看到的是「清晰度只剩 360」，
/// 代码里没有异常可抓。
///
/// 所以这里把「签过名的清单里没有 Source」当成盐值失效的信号：拉官网首页
/// 找到 main.js，从中提取盐值，变了就保存并重签重发一次。
class XVersionSaltService {
  XVersionSaltService._();

  static final XVersionSaltService instance = XVersionSaltService._();

  static const String _tag = 'XVersionSaltService';

  /// 两次检查官网之间的最短间隔，避免连着打开几个缺 Source 的视频时反复请求
  static const Duration _minCheckInterval = Duration(minutes: 10);

  static const Duration _requestTimeout = Duration(seconds: 30);

  static final RegExp _mainScriptPattern = RegExp(
    r'''src=["'](/main\.[0-9a-f]+\.js)["']''',
  );

  /// 前端计算签名的那一句形如 `"_"+e.expires+"_<salt>"`
  static final RegExp _saltPattern = RegExp(
    r'"_"\+[\w$.]+expires\+"_([A-Za-z0-9]{16,})"',
  );

  bool _loaded = false;
  DateTime? _lastCheckAt;
  Future<bool>? _refreshing;

  /// 带 X-Version 请求视频源清单。
  ///
  /// [send] 用给定的请求头发出请求。结果像是签名失效时，从官网更新盐值后
  /// 重发一次；盐值没变或更新失败就原样返回第一次的结果，行为与以前一致。
  Future<d_dio.Response<dynamic>> requestVideoSources(
    String fileUrl,
    Future<d_dio.Response<dynamic>> Function(Map<String, dynamic> headers) send,
  ) async {
    _ensureLoaded();
    final usedSalt = XVersionCalculatorUtil.salt;
    final response = await send(_headersFor(fileUrl));
    if (!looksUnsigned(response.data)) return response;

    // 并发的另一个请求可能已经把盐值换掉了，那就直接用新盐值重发
    if (XVersionCalculatorUtil.salt == usedSalt && !await refreshFromSite()) {
      return response;
    }
    LogUtils.i('签名盐值已更新，重新请求视频源', _tag);
    return send(_headersFor(fileUrl));
  }

  /// 从官网前端提取盐值，盐值有变化时返回 true。并发调用共用同一次请求。
  Future<bool> refreshFromSite() {
    return _refreshing ??= _refresh().whenComplete(() => _refreshing = null);
  }

  Map<String, dynamic> _headersFor(String fileUrl) => {
    'X-Version': XVersionCalculatorUtil.calculateXVersion(fileUrl),
  };

  void _ensureLoaded() {
    if (_loaded) return;
    _loaded = true;
    final config = _config;
    if (config == null) return;
    final saved = config[ConfigKey.X_VERSION_SALT];
    if (saved is String && isValidSalt(saved)) {
      XVersionCalculatorUtil.salt = saved;
    }
  }

  Future<bool> _refresh() async {
    _ensureLoaded();
    final now = DateTime.now();
    final last = _lastCheckAt;
    if (last != null && now.difference(last) < _minCheckInterval) {
      return false;
    }
    _lastCheckAt = now;

    try {
      final site = Uri.parse(CommonConstants.iwaraBaseUrl);
      final script = extractMainScriptPath(await _getString(site));
      if (script == null) {
        LogUtils.w('官网首页里没找到 main.js，跳过盐值更新', _tag);
        return false;
      }

      final config = _config;
      // 前端没换版本，盐值就不会变，省掉一次上 MB 的下载
      if (config != null && config[ConfigKey.X_VERSION_SALT_SCRIPT] == script) {
        return false;
      }

      final salt = extractSalt(await _getString(site.resolve(script)));
      if (salt == null) {
        LogUtils.w('main.js 里没找到签名盐值: $script', _tag);
        return false;
      }

      final changed = salt != XVersionCalculatorUtil.salt;
      XVersionCalculatorUtil.salt = salt;
      if (config != null) {
        await config.setSetting(ConfigKey.X_VERSION_SALT, salt);
        await config.setSetting(ConfigKey.X_VERSION_SALT_SCRIPT, script);
      }
      if (changed) {
        LogUtils.i('签名盐值已从官网更新（$script）', _tag);
      }
      return changed;
    } catch (e) {
      LogUtils.e('从官网更新签名盐值失败', tag: _tag, error: e);
      return false;
    }
  }

  ConfigService? get _config =>
      Get.isRegistered<ConfigService>() ? Get.find<ConfigService>() : null;

  Future<String> _getString(Uri uri) async {
    final client = HttpClientFactory.instance.createHttpClient();
    final request = await client.getUrl(uri).timeout(_requestTimeout);
    try {
      final response = await request.close().timeout(_requestTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        await response.drain<void>().catchError((_) {});
        throw HttpException('Request failed: ${response.statusCode}', uri: uri);
      }
      return await response
          .transform(utf8.decoder)
          .join()
          .timeout(_requestTimeout);
    } on TimeoutException {
      request.abort();
      rethrow;
    }
  }

  /// 签过名的清单一定带 Source（原档）；盐值不对时服务器只给 360 / preview。
  /// 空清单（转码中等情况）不算。
  static bool looksUnsigned(Object? data) {
    if (data is! List || data.isEmpty) return false;
    return !data.any((item) => item is Map && item['name'] == 'Source');
  }

  static bool isValidSalt(String salt) =>
      RegExp(r'^[A-Za-z0-9]{16,}$').hasMatch(salt);

  /// 从官网首页 HTML 里找出 `/main.<hash>.js`
  static String? extractMainScriptPath(String html) =>
      _mainScriptPattern.firstMatch(html)?.group(1);

  /// 从 main.js 里提取签名盐值
  static String? extractSalt(String js) =>
      _saltPattern.firstMatch(js)?.group(1);
}
