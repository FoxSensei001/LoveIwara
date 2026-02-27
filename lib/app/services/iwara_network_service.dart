import 'dart:convert';

import 'package:cloudflare_interceptor/cloudflare_interceptor.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:html/parser.dart' show parse;

import '../../utils/logger_utils.dart';

class IwaraNetworkService extends GetxService {
  static const String _tag = 'IwaraNetworkService';

  final CookieJar cookieJar = CookieJar();
  final Set<Dio> _registeredDios = <Dio>{};

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
  void registerDio(Dio dio, {bool accept4xxAsResponse = true}) {
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
    _ensureCloudflareInterceptorIfReady(dio);
    _ensureCloudflarePostSolveRetryInterceptor(dio);
    _ensureCloudflareHtmlToJsonInterceptor(dio);
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

  void _ensureCloudflareInterceptorIfReady(Dio dio, {bool force = false}) {
    if (!hasContext) return;

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
      (i) => i is CloudflareInterceptor,
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
      (i) => i is CloudflareInterceptor,
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
