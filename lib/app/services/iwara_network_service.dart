import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:cloudflare_interceptor/cloudflare_interceptor.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as iaw;
import 'package:get/get.dart' hide Response;
import 'package:html/parser.dart' show parse;

import '../../utils/logger_utils.dart';

class IwaraNetworkService extends GetxService {
  static const String _tag = 'IwaraNetworkService';

  // 全站点共享同一个 CookieJar：iwara.tv 与 iwara.ai 是同一账号/后端
  // (同一 API host apiq.iwara.tv，x-site 仅作内容过滤/展示)，因此共享
  // cookie 与 Authorization 是有意为之、正确的；不需要按站点分区(N3)。
  final CookieJar cookieJar = CookieJar();
  final Set<Dio> _registeredDios = <Dio>{};

  /// 只许无头过盾、永不弹窗的 Dio（后台任务用）。它们不挂 [CloudflareInterceptor]，
  /// [setContext] 之后也不补挂。
  final Set<Dio> _headlessOnlyDios = <Dio>{};

  BuildContext? _context;

  bool _loggedCloudflareUnsupported = false;

  bool get _supportsCloudflareChallenge => !GetPlatform.isLinux;

  /// Whether we can show a Cloudflare challenge dialog now.
  ///
  /// Note: `cloudflare_interceptor` depends on `flutter_inappwebview`, which
  /// does not support Linux. On Linux we always return false to avoid
  /// attempting to solve challenges with a WebView.
  bool get hasContext =>
      _context?.mounted == true && _supportsCloudflareChallenge;

  /// Register a [Dio] instance to enable:
  /// - Shared CookieJar (Cloudflare clearance, session cookies)
  /// - Cloudflare challenge solving (requires [setContext], not supported on Linux)
  /// - Post-solve retry to fetch real API response (WebView request may miss auth headers)
  ///
  /// Args:
  ///   dio: The dio instance to register.
  ///   accept4xxAsResponse: When true, treat all <500 responses as "success"
  ///     for Dio's pipeline so Cloudflare challenges can be intercepted in
  ///     [CloudflareInterceptor.onResponse].
  ///   decodeJsonAfterChallenge: 过盾后 WebView 交回的是整页 HTML，iwara API
  ///     要从 `<pre>` 里抠 JSON；oreno3d 这类本身就吃 HTML 的站点传 false，
  ///     否则页面会被当成「JSON 解析失败」清成 null。
  ///   interactiveChallenge: false 时只在后台用无头 WebView 自动过盾，过不去就
  ///     把挑战原样交还调用方，**绝不弹全屏验证页**。给用户没有主动发起的后台
  ///     请求用（例如视频详情页的 oreno3d 匹配），免得看着视频突然被验证页盖住。
  void registerDio(
    Dio dio, {
    bool accept4xxAsResponse = true,
    bool decodeJsonAfterChallenge = true,
    bool interactiveChallenge = true,
  }) {
    if (_registeredDios.add(dio)) {
      LogUtils.d('$_tag registerDio: ${dio.hashCode}');
    }

    if (accept4xxAsResponse) {
      dio.options.validateStatus = (status) => (status ?? 0) < 500;
    }

    _ensureCookieManager(dio);

    if (!_supportsCloudflareChallenge) {
      _logCloudflareUnsupportedOnce();
    }
    if (interactiveChallenge) {
      _ensureCloudflareInterceptorIfReady(dio);
    } else {
      _headlessOnlyDios.add(dio);
      _ensureHeadlessCloudflareInterceptor(dio);
    }
    _ensureCloudflarePostSolveRetryInterceptor(dio);
    if (decodeJsonAfterChallenge) {
      _ensureCloudflareHtmlToJsonInterceptor(dio);
    }
  }

  /// 短命的 Dio（用完就 close 的那种）必须注销，否则 [_registeredDios] 只进不出。
  void unregisterDio(Dio dio) {
    _headlessOnlyDios.remove(dio);
    if (_registeredDios.remove(dio)) {
      LogUtils.d('$_tag unregisterDio: ${dio.hashCode}');
    }
  }

  /// Provide a mounted UI [BuildContext] for Cloudflare challenge dialog.
  void setContext(BuildContext context) {
    if (!context.mounted) {
      LogUtils.w('$_tag setContext called with unmounted context, ignored');
      return;
    }
    if (_context == context) return;
    _context = context;

    LogUtils.d('$_tag setContext: mounted=${context.mounted}');

    if (!_supportsCloudflareChallenge) {
      _logCloudflareUnsupportedOnce();
      return;
    }

    for (final dio in _registeredDios) {
      _ensureCloudflareInterceptorIfReady(dio, force: true);
    }
  }

  void _logCloudflareUnsupportedOnce() {
    if (_loggedCloudflareUnsupported) return;
    _loggedCloudflareUnsupported = true;
    LogUtils.w(
      '$_tag Linux 平台暂不支持 Cloudflare 过盾（cloudflare_interceptor），已禁用挑战处理',
    );
  }

  void _ensureCookieManager(Dio dio) {
    // Replace to ensure all requests share the same cookie jar.
    dio.interceptors.removeWhere((i) => i is CookieManager);

    // Keep Dio's built-in interceptor at the head of the chain.
    final insertIndex = dio.interceptors.isNotEmpty ? 1 : 0;
    dio.interceptors.insert(insertIndex, CookieManager(cookieJar));
  }

  void _ensureHeadlessCloudflareInterceptor(Dio dio) {
    if (!_supportsCloudflareChallenge) return;
    if (dio.interceptors.any((i) => i is _HeadlessCloudflareInterceptor)) {
      return;
    }
    final cookieManagerIndex = dio.interceptors.indexWhere(
      (i) => i is CookieManager,
    );
    dio.interceptors.insert(
      cookieManagerIndex == -1
          ? dio.interceptors.length
          : cookieManagerIndex + 1,
      _HeadlessCloudflareInterceptor(cookieJar),
    );
  }

  void _ensureCloudflareInterceptorIfReady(Dio dio, {bool force = false}) {
    if (!hasContext) return;
    if (_headlessOnlyDios.contains(dio)) return;

    final hasInterceptor = dio.interceptors.any(
      (i) => i is CloudflareInterceptor,
    );
    if (hasInterceptor && !force) return;

    dio.interceptors.removeWhere((i) => i is CloudflareInterceptor);

    final cookieManagerIndex = dio.interceptors.indexWhere(
      (i) => i is CookieManager,
    );
    final insertIndex = cookieManagerIndex == -1
        ? dio.interceptors.length
        : cookieManagerIndex + 1;

    dio.interceptors.insert(
      insertIndex,
      CloudflareInterceptor(dio: dio, cookieJar: cookieJar, context: _context!),
    );
  }

  void _ensureCloudflarePostSolveRetryInterceptor(Dio dio) {
    if (dio.interceptors.any(
      (i) => i is _CloudflarePostSolveRetryInterceptor,
    )) {
      return;
    }

    // Put it right after CloudflareInterceptor if present; otherwise after CookieManager.
    final cfIndex = dio.interceptors.indexWhere(
      (i) => i is CloudflareInterceptor || i is _HeadlessCloudflareInterceptor,
    );
    final cookieManagerIndex = dio.interceptors.indexWhere(
      (i) => i is CookieManager,
    );
    final insertIndex = cfIndex != -1
        ? cfIndex + 1
        : cookieManagerIndex != -1
        ? cookieManagerIndex + 1
        : dio.interceptors.length;

    dio.interceptors.insert(
      insertIndex,
      _CloudflarePostSolveRetryInterceptor(dio),
    );
  }

  void _ensureCloudflareHtmlToJsonInterceptor(Dio dio) {
    if (dio.interceptors.any((i) => i is _CloudflareHtmlToJsonInterceptor)) {
      return;
    }

    final cfIndex = dio.interceptors.indexWhere(
      (i) => i is CloudflareInterceptor || i is _HeadlessCloudflareInterceptor,
    );
    final postSolveIndex = dio.interceptors.indexWhere(
      (i) => i is _CloudflarePostSolveRetryInterceptor,
    );
    final cookieManagerIndex = dio.interceptors.indexWhere(
      (i) => i is CookieManager,
    );
    final insertIndex = postSolveIndex != -1
        ? postSolveIndex + 1
        : cfIndex != -1
        ? cfIndex + 1
        : cookieManagerIndex != -1
        ? cookieManagerIndex + 1
        : dio.interceptors.length;

    dio.interceptors.insert(
      insertIndex,
      const _CloudflareHtmlToJsonInterceptor(),
    );
  }
}

/// 只用无头 WebView 过盾，永不弹窗。
///
/// 与 [CloudflareInterceptor] 的差别：那个 5 秒没过就弹全屏验证页；这个等到
/// [_timeout] 还没过就放弃，把原挑战响应交给下游（调用方照常按 403 处理）。
/// 过盾成功的产物与它一致——WebView 的 cookie 写进共享 [CookieJar]、
/// 响应标 `extra['cloudflare'] = true`——所以后面的 post-solve 重试照常生效。
class _HeadlessCloudflareInterceptor extends Interceptor {
  _HeadlessCloudflareInterceptor(this._cookieJar);

  static const Duration _timeout = Duration(seconds: 20);

  final CookieJar _cookieJar;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final cfMitigated = response.headers['cf-mitigated'];
    final method = response.requestOptions.method.toUpperCase();
    if (cfMitigated == null ||
        !cfMitigated.contains('challenge') ||
        (method != 'GET' && method != 'HEAD')) {
      handler.next(response);
      return;
    }

    final html = await _solve(response.requestOptions);
    if (html == null) {
      LogUtils.w(
        'IwaraNetworkService 无头过盾未通过，放弃（不弹窗）: ${response.requestOptions.uri}',
      );
      handler.next(response);
      return;
    }
    handler.next(
      Response(
        requestOptions: response.requestOptions,
        data: html,
        statusCode: 200,
        extra: {'cloudflare': true},
      ),
    );
  }

  /// 判定页面还是不是挑战页。标题取自 HTML 本身：`getTitle()` 在首个 loadStop
  /// 可能还是空串（macOS 实测），空标题一律当没过——曾因此把挑战页当成真页面交回。
  static bool _looksLikeChallenge(String html) {
    if (html.contains('_cf_chl_opt') || html.contains('challenge-platform')) {
      return true;
    }
    final title = (parse(html).querySelector('title')?.text ?? '')
        .trim()
        .toLowerCase();
    return title.isEmpty ||
        title.contains('cloudflare') ||
        title.contains('just a moment') ||
        title.contains('verification required');
  }

  Future<String?> _solve(RequestOptions options) async {
    final completer = Completer<String?>();
    final uri = iaw.WebUri.uri(options.uri);
    final userAgent = options.headers['user-agent'] as String?;

    final webView = iaw.HeadlessInAppWebView(
      initialSettings: iaw.InAppWebViewSettings(userAgent: userAgent),
      initialUrlRequest: iaw.URLRequest(url: uri),
      onLoadStop: (controller, url) async {
        if (completer.isCompleted) return;
        try {
          final html = await controller.getHtml();
          // 挑战页先 loadStop 一次，JS 过完再跳一次真页面：只认后者。
          if (html == null || _looksLikeChallenge(html)) return;
          final cookieUrl = url ?? uri;
          final cookies = await iaw.CookieManager.instance().getCookies(
            url: cookieUrl,
          );
          await _cookieJar.saveFromResponse(
            cookieUrl,
            cookies.map((c) {
              final cookie = io.Cookie(c.name, '${c.value}')
                ..domain = c.domain
                ..path = c.path ?? '/'
                ..secure = c.isSecure ?? false
                ..httpOnly = c.isHttpOnly ?? false;
              if (c.expiresDate != null) {
                cookie.expires = DateTime.fromMillisecondsSinceEpoch(
                  c.expiresDate!,
                );
              }
              return cookie;
            }).toList(),
          );
          if (!completer.isCompleted) completer.complete(html);
        } catch (e) {
          LogUtils.w('IwaraNetworkService 无头过盾读取页面失败: $e');
        }
      },
    );

    try {
      await webView.run();
      return await completer.future.timeout(_timeout, onTimeout: () => null);
    } catch (e) {
      LogUtils.w('IwaraNetworkService 无头过盾启动失败: $e');
      return null;
    } finally {
      await webView.dispose();
    }
  }
}

class _CloudflarePostSolveRetryInterceptor extends Interceptor {
  _CloudflarePostSolveRetryInterceptor(this._dio);

  final Dio _dio;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response.extra['cloudflare'] != true) {
      handler.next(response);
      return;
    }

    // Avoid infinite loop: only retry once per request.
    if (response.requestOptions.extra['cf_retry'] == true) {
      handler.next(response);
      return;
    }

    final method = response.requestOptions.method.toUpperCase();
    if (method != 'GET' && method != 'HEAD') {
      handler.next(response);
      return;
    }

    try {
      final retryOptions = response.requestOptions.copyWith(
        extra: {...response.requestOptions.extra, 'cf_retry': true},
      );
      final retryResponse = await _dio.fetch<dynamic>(retryOptions);
      handler.next(retryResponse);
    } catch (_) {
      // If retry fails, fall back to the WebView-returned response.
      handler.next(response);
    }
  }
}

class _CloudflareHtmlToJsonInterceptor extends Interceptor {
  const _CloudflareHtmlToJsonInterceptor();

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.extra['cloudflare'] != true || response.data is! String) {
      handler.next(response);
      return;
    }

    final decoded = _tryToJson(response.data as String);
    if (decoded == null) {
      response.extra['cloudflare_parse_failed'] = true;
      response.data = null;
    } else {
      response.data = decoded;
    }

    handler.next(response);
  }

  dynamic _tryToJson(String data) {
    final trimmed = data.trim();
    if (trimmed.isEmpty) return null;

    // Some WebViews may return plain JSON as-is.
    if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
        (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
      try {
        return jsonDecode(trimmed);
      } catch (_) {
        // continue
      }
    }

    // Most often it's an HTML page with a <pre>{json}</pre>.
    try {
      final document = parse(trimmed);
      final pre = document.querySelector('pre');
      if (pre != null) {
        final jsonString = pre.text.trim();
        if (jsonString.isEmpty) return null;
        return jsonDecode(jsonString);
      }
    } catch (_) {
      // ignore
    }

    return null;
  }
}
