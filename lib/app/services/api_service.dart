// api_service.dart
// API 服务 - 处理所有 HTTP 请求，包括 401 处理和网络重试

import 'dart:async';

import 'package:dio/dio.dart' as d_dio;
import 'package:dio/io.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/api_failure.model.dart';
import 'package:i_iwara/app/models/api_request_access.model.dart';
import 'package:i_iwara/app/models/iwara_page.model.dart';
import 'package:i_iwara/app/models/iwara_site.dart';

import '../../common/constants.dart';
import '../../utils/logger_utils.dart';
import '../ui/pages/popular_media_list/widgets/common_media_list_widgets.dart';
import 'auth_service.dart';
import 'http_client_factory.dart';
import 'iwara_network_service.dart';
import 'iwara_site_headers.dart';
import 'package:i_iwara/utils/common_utils.dart';

/// API 服务配置
class ApiServiceConfig {
  /// 请求超时时间
  static const Duration requestTimeout = Duration(seconds: 15);

  /// 最大网络重试次数
  static const int maxNetworkRetries = 1;

  /// Token 刷新最大等待时间（避免极端情况下请求卡死）
  static const Duration tokenRefreshMaxWait = Duration(seconds: 15);

  /// 可匿名降级接口在刷新中的最大等待时间
  static const Duration optionalAuthWait = Duration(seconds: 2);

  /// 网络重试基础延迟
  static const Duration baseRetryDelay = Duration(milliseconds: 500);

  /// 最大重试延迟
  static const Duration maxRetryDelay = Duration(seconds: 3);
}

/// API 服务
class ApiService extends GetxService {
  static const String _requestAccessKey = 'requestAccess';
  static const String _requestIdKey = 'requestId';
  static const String _retryCountKey = 'retryCount';
  static const String _maxRetriesKey = 'maxNetworkRetries';
  static const String _anonymousRetryKey = 'anonymous_retry';
  static const String _authRetryKey = 'auth_retry';
  static const String _forceAnonymousKey = 'forceAnonymous';

  /// 这一次请求钉在哪个站（[IwaraSite]），不改全局站点模式。
  ///
  /// 绝大多数请求都该跟着 [AppService.currentSiteMode] 走；只有"资源本身属于
  /// 另一个站"的场合才需要它（见 `PlayListService.getPlaylistVideos` 的跨站回退）。
  static const String _siteOverrideKey = 'iwaraSiteOverride';
  static const String _authRefreshFailedKey = 'auth_refresh_failed';
  static const String _redirectCountKey = 'redirectCount';
  static const int _maxManualRedirects = 5;

  static ApiService? _instance;
  late d_dio.Dio _dio;
  final AuthService _authService = Get.find<AuthService>();
  final String _tag = 'ApiService';

  bool _interceptorAdded = false;

  ApiService._();

  d_dio.Dio get dio => _dio;

  /// 获取单例实例
  static Future<ApiService> getInstance() async {
    _instance ??= await ApiService._().init();
    return _instance!;
  }

  /// 初始化
  Future<ApiService> init() async {
    _dio = d_dio.Dio(
      d_dio.BaseOptions(
        baseUrl: CommonConstants.iwaraApiBaseUrl,
        connectTimeout: ApiServiceConfig.requestTimeout,
        receiveTimeout: ApiServiceConfig.requestTimeout,
        sendTimeout: ApiServiceConfig.requestTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json, text/plain, */*',
        },
      ),
    );

    // Treat all <500 responses as "success" for Dio's pipeline, so:
    // - 401 can be handled in onResponse (single authority)
    // - Cloudflare challenges can be intercepted before bubbling to callers
    _dio.options.validateStatus = (status) => (status ?? 0) < 500;

    // iwara 会用「3xx + JSON body 且不带 Location」来表达业务错误，例如用主站模式
    // 请求 AI 站资源时返回 301 {"message":"errors.differentSite","siteId":"iwara_ai"}。
    // dart:io 的自动重定向遇到这种响应会直接抛 RedirectException 并丢掉 body，
    // 上层只能看到一个无从解释的网络错误（跨站因此永远无法被识别、无法自动切站）。
    // 这里关闭自动跟随，改由 _onResponse 手动跟随「带 Location 的真重定向」。
    _dio.options.followRedirects = false;

    // 配置 HTTP 客户端适配器（使用共享 HttpClient 实现连接复用）
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: HttpClientFactory.instance.createHttpClient,
    );

    // iwrqk-style network stack: CookieJar + Cloudflare challenge handler
    try {
      Get.find<IwaraNetworkService>().registerDio(_dio);
    } catch (e) {
      LogUtils.w('$_tag 网络服务未就绪，跳过 Cloudflare/Cookie 注入: $e');
    }

    if (_interceptorAdded) {
      return this;
    }

    // 添加拦截器
    _dio.interceptors.add(_createInterceptor());
    _interceptorAdded = true;

    return this;
  }

  /// 创建拦截器
  d_dio.InterceptorsWrapper _createInterceptor() {
    return d_dio.InterceptorsWrapper(
      onRequest: _onRequest,
      onResponse: _onResponse,
      onError: _onError,
    );
  }

  ApiRequestAccess _resolveRequestAccess(d_dio.RequestOptions options) {
    final raw = options.extra[_requestAccessKey];
    if (raw is String) {
      return ApiRequestAccess.values.firstWhere(
        (value) => value.name == raw,
        orElse: () => ApiRequestAccess.authRequired,
      );
    }
    return ApiRequestAccess.authRequired;
  }

  bool _shouldAttachAccessToken(
    ApiRequestAccess access,
    String? accessToken,
    d_dio.RequestOptions options,
  ) {
    if (options.extra[_forceAnonymousKey] == true) {
      return false;
    }
    if (!access.sendsAuthenticationByDefault) {
      return false;
    }
    if (accessToken == null) {
      return false;
    }
    if (access == ApiRequestAccess.optionalAuthShortWait &&
        _authService.isAccessTokenActuallyExpired) {
      return false;
    }
    return true;
  }

  bool _isAnonymousFallbackCandidate(d_dio.Response response) {
    if (_resolveRequestAccess(response.requestOptions) !=
        ApiRequestAccess.optionalAuthShortWait) {
      return false;
    }
    if (response.requestOptions.extra[_anonymousRetryKey] == true) {
      return false;
    }
    if (response.statusCode == 401) {
      return true;
    }
    if (response.statusCode != 403) {
      return false;
    }
    final data = response.data;
    if (data is Map<String, dynamic> && data['message'] == 'errors.forbidden') {
      return true;
    }
    // Cloudflare challenge / 无法解析的 403：也尝试匿名回退，避免把 CF 抖动
    // 当成硬 403 抛给用户(N2)。注意 errors.privateVideo 等可解析消息不会命中这里。
    if (response.extra['cloudflare_parse_failed'] == true) {
      return true;
    }
    final cfMitigated = response.headers.value('cf-mitigated');
    if (cfMitigated != null && cfMitigated.contains('challenge')) {
      return true;
    }
    return false;
  }

  void _setAuthorizationHeader(
    d_dio.RequestOptions options,
    String? accessToken,
  ) {
    if (accessToken == null) {
      options.headers.remove('Authorization');
      return;
    }
    options.headers['Authorization'] = 'Bearer $accessToken';
  }

  void _markAuthRefreshFailed(d_dio.RequestOptions options, String reason) {
    options.extra[_authRefreshFailedKey] = true;
    options.extra['authRefreshFailureReason'] = reason;
  }

  d_dio.Options _prepareRequestOptions(
    d_dio.Options? options, {
    Map<String, dynamic>? headers,
    ApiRequestAccess requestAccess = ApiRequestAccess.authRequired,
    int? maxNetworkRetries,
    IwaraSite? site,
  }) {
    final requestOptions = options ?? d_dio.Options();
    requestOptions.extra = {
      ...?requestOptions.extra,
      _requestAccessKey: requestAccess.name,
      _maxRetriesKey: ?maxNetworkRetries,
      _siteOverrideKey: ?site,
    };
    if (headers != null) {
      requestOptions.headers = {...?requestOptions.headers, ...headers};
    }
    return requestOptions;
  }

  /// 请求拦截
  void _onRequest(
    d_dio.RequestOptions options,
    d_dio.RequestInterceptorHandler handler,
  ) {
    final accessToken = _authService.accessToken;
    final tokenManager = _authService.tokenManager;
    // 钉过站的请求走它自己那一档；其余跟全局站点模式。重试路径复制 extra，
    // 所以钉的站在重试里也保得住。
    final siteOverride = options.extra[_siteOverrideKey];
    final site = siteOverride is IwaraSite
        ? siteOverride
        : currentIwaraSiteOrMain();
    final access = _resolveRequestAccess(options);

    final requestId = _ensureRequestId(options);

    // 以 refresh token 为准：access token 可能为空(正在重建)，
    // 仍应等待在途刷新，而非裸发请求导致 401→误登出(#4 配套)。
    if (tokenManager.isRefreshing &&
        _authService.hasRefreshToken &&
        access != ApiRequestAccess.publicOnly) {
      LogUtils.d(
        '$_tag[$requestId] Token 正在刷新中，请求 ${options.path} 等待刷新完成 '
        '(access=${access.name})',
      );
      _waitForRefreshThenRequest(options, handler);
      return;
    }

    options.headers.addAll(site.requestHeaders);

    if (_shouldAttachAccessToken(access, accessToken, options)) {
      _setAuthorizationHeader(options, accessToken);
    } else {
      options.headers.remove('Authorization');
    }

    // 标记请求开始时间，用于判断 token 有效性
    options.extra['requestStartTime'] = DateTime.now().millisecondsSinceEpoch;
    LogUtils.d(
      '$_tag[$requestId] 请求: ${options.method} ${options.path} '
      '(site=${site.name}, access=${access.name}, auth=${options.headers['Authorization'] != null})',
    );
    handler.next(options);
  }

  /// 响应拦截（用于 401 刷新与自动重试）
  Future<void> _onResponse(
    d_dio.Response response,
    d_dio.ResponseInterceptorHandler handler,
  ) async {
    final redirected = await _followRedirectIfNeeded(response);
    if (redirected != null) {
      return handler.resolve(redirected);
    }

    if (_isAnonymousFallbackCandidate(response)) {
      final requestId = _ensureRequestId(response.requestOptions);
      LogUtils.d(
        '$_tag[$requestId] 登录增强请求收到 ${response.statusCode}，回退匿名请求: '
        '${response.requestOptions.path}',
      );
      final anonymousResponse = await _retryWithoutAuthentication(
        response.requestOptions,
      );
      if (anonymousResponse != null) {
        return handler.resolve(anonymousResponse);
      }
    }

    // 处理 401（validateStatus 已放宽到 < 500，因此 401 不会进入 onError）
    if (response.statusCode == 401) {
      final requestId = _ensureRequestId(response.requestOptions);
      final access = _resolveRequestAccess(response.requestOptions);
      if (access == ApiRequestAccess.publicOnly) {
        LogUtils.w(
          '$_tag[$requestId] 公共请求收到 401，直接返回: ${response.requestOptions.path}',
        );
        handler.next(response);
        return;
      }

      final result = await _handle401Request(response.requestOptions);
      if (result != null) {
        return handler.resolve(result);
      }
    }

    handler.next(response);
  }

  /// 手动跟随重定向（[_dio] 已关闭自动跟随，见 [init]）。
  ///
  /// 复刻 dart:io 的跟随语义：GET/HEAD 跟随 301/302/303/307/308，其他方法只跟随
  /// 303/307/308（303 降级为 GET）。**没有 Location 的 3xx 不视为重定向**——iwara
  /// 用它承载 `errors.differentSite` 这类业务错误，必须把 body 原样交给上层。
  ///
  /// 返回 null 表示「不是需要跟随的重定向」，调用方继续原有响应处理。
  Future<d_dio.Response<dynamic>?> _followRedirectIfNeeded(
    d_dio.Response response,
  ) async {
    final statusCode = response.statusCode ?? 0;
    if (statusCode < 300 || statusCode >= 400) {
      return null;
    }

    final options = response.requestOptions;
    final method = options.method.toUpperCase();
    if (!_shouldFollowRedirect(method, statusCode)) {
      return null;
    }

    final location = response.headers.value('location')?.trim();
    if (location == null || location.isEmpty) {
      return null;
    }

    final requestId = _ensureRequestId(options);
    final redirectCount = options.extra[_redirectCountKey] as int? ?? 0;
    if (redirectCount >= _maxManualRedirects) {
      LogUtils.w(
        '$_tag[$requestId] 重定向次数超过 $_maxManualRedirects，停止跟随: ${options.path}',
      );
      return null;
    }

    final Uri target;
    try {
      target = options.uri.resolve(location);
    } catch (e) {
      LogUtils.w('$_tag[$requestId] 无法解析重定向目标: $location ($e)');
      return null;
    }

    // 303 语义：非 GET/HEAD 请求跟随时降级为 GET。
    final nextMethod =
        (statusCode == 303 && method != 'GET' && method != 'HEAD')
        ? 'GET'
        : method;

    LogUtils.d(
      '$_tag[$requestId] 跟随重定向 $statusCode: ${options.uri} -> $target',
    );

    try {
      return await _dio.fetch<dynamic>(
        options.copyWith(
          method: nextMethod,
          path: target.toString(),
          // Location 已经是完整目标，原 queryParameters 不能再拼一次。
          queryParameters: <String, dynamic>{},
          extra: {...options.extra, _redirectCountKey: redirectCount + 1},
        ),
      );
    } catch (e) {
      LogUtils.w('$_tag[$requestId] 跟随重定向失败: $target ($e)');
      return null;
    }
  }

  bool _shouldFollowRedirect(String method, int statusCode) {
    if (method == 'GET' || method == 'HEAD') {
      return statusCode == 301 ||
          statusCode == 302 ||
          statusCode == 303 ||
          statusCode == 307 ||
          statusCode == 308;
    }
    return statusCode == 303 || statusCode == 307 || statusCode == 308;
  }

  /// 等待 token 刷新完成后发送请求
  Future<void> _waitForRefreshThenRequest(
    d_dio.RequestOptions options,
    d_dio.RequestInterceptorHandler handler,
  ) async {
    final requestId = _ensureRequestId(options);
    final access = _resolveRequestAccess(options);
    final waitTimeout = access == ApiRequestAccess.optionalAuthShortWait
        ? ApiServiceConfig.optionalAuthWait
        : ApiServiceConfig.tokenRefreshMaxWait;

    try {
      final tokenManager = _authService.tokenManager;
      final refreshStartAt = DateTime.now();
      final result = await tokenManager.refreshAccessToken().timeout(
        waitTimeout,
      );
      final refreshCostMs = DateTime.now()
          .difference(refreshStartAt)
          .inMilliseconds;
      LogUtils.d(
        '$_tag[$requestId] 等待刷新完成: '
        'success=${result.success}, authError=${result.isAuthError}, '
        'cost=${refreshCostMs}ms, access=${access.name}',
      );

      // 等待期间请求可能已被取消：此时不得再调用 handler，避免违反 Dio
      // "handler 不可重复完成" 契约(N4)。
      if (options.cancelToken?.isCancelled ?? false) {
        LogUtils.d('$_tag[$requestId] 等待刷新期间请求已取消: ${options.path}');
        handler.reject(
          d_dio.DioException(
            requestOptions: options,
            type: d_dio.DioExceptionType.cancel,
            message: 'Request cancelled while waiting for token refresh',
          ),
        );
        return;
      }

      if (result.success) {
        _setAuthorizationHeader(options, _authService.accessToken);
        options.extra['requestStartTime'] =
            DateTime.now().millisecondsSinceEpoch;
        LogUtils.d('$_tag[$requestId] Token 刷新完成，继续请求: ${options.path}');
        handler.next(options);
      } else {
        if (access == ApiRequestAccess.optionalAuthShortWait) {
          LogUtils.d('$_tag[$requestId] Token 刷新未成功，匿名继续请求: ${options.path}');
          _continueRequestAnonymously(options, handler);
          return;
        }

        _rejectDueToRefreshFailure(
          options,
          handler,
          result.isAuthError ? 'refresh_auth_failed' : 'refresh_network_failed',
        );
      }
    } on TimeoutException catch (_) {
      if (access == ApiRequestAccess.optionalAuthShortWait) {
        LogUtils.w('$_tag[$requestId] 等待 token 刷新超时，匿名继续请求: ${options.path}');
        _continueRequestAnonymously(options, handler);
        return;
      }
      _rejectDueToRefreshFailure(options, handler, 'refresh_wait_timeout');
    } catch (e) {
      LogUtils.e('$_tag[$requestId] 等待 token 刷新时出错', error: e);
      if (access == ApiRequestAccess.optionalAuthShortWait) {
        _continueRequestAnonymously(options, handler);
        return;
      }
      _rejectDueToRefreshFailure(options, handler, 'refresh_wait_exception');
    }
  }

  void _continueRequestAnonymously(
    d_dio.RequestOptions options,
    d_dio.RequestInterceptorHandler handler,
  ) {
    options.extra[_forceAnonymousKey] = true;
    options.extra[_requestAccessKey] = ApiRequestAccess.publicOnly.name;
    options.headers.remove('Authorization');
    options.extra['requestStartTime'] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  void _rejectDueToRefreshFailure(
    d_dio.RequestOptions options,
    d_dio.RequestInterceptorHandler handler,
    String reason,
  ) {
    _markAuthRefreshFailed(options, reason);
    handler.reject(
      d_dio.DioException(
        requestOptions: options,
        type: d_dio.DioExceptionType.unknown,
        message: 'Authentication refresh failed before request',
        error: StateError('auth_refresh_failed:$reason'),
      ),
    );
  }

  String _ensureRequestId(d_dio.RequestOptions options) {
    final existing = options.extra[_requestIdKey];
    if (existing is String && existing.isNotEmpty) {
      return existing;
    }
    final requestId = DateTime.now().microsecondsSinceEpoch.toString();
    options.extra[_requestIdKey] = requestId;
    return requestId;
  }

  /// 错误拦截
  Future<void> _onError(
    d_dio.DioException error,
    d_dio.ErrorInterceptorHandler handler,
  ) async {
    // NOTE: 401 is handled in onResponse as the single authority, because
    // validateStatus is relaxed to accept all <500 responses.

    // 处理网络错误 - 重试逻辑
    if (_isNetworkError(error)) {
      final retryResult = await _handleNetworkRetry(error);
      if (retryResult != null) {
        return handler.resolve(retryResult);
      }
    }

    handler.next(error);
  }

  /// 处理 401 错误
  Future<d_dio.Response?> _handle401Request(
    d_dio.RequestOptions options,
  ) async {
    final requestId = _ensureRequestId(options);
    final access = _resolveRequestAccess(options);
    LogUtils.w(
      '$_tag[$requestId] 收到 401 响应: ${options.method} ${options.path}',
    );

    // Avoid infinite loops: only attempt refresh+retry once per request.
    if (options.extra[_authRetryKey] == true) {
      LogUtils.w('$_tag[$requestId] 401 已重试过一次（跳过再次刷新）: ${options.path}');
      return null;
    }

    if (access == ApiRequestAccess.optionalAuthShortWait) {
      return _retryWithoutAuthentication(options);
    }

    // 如果是 token 刷新请求本身失败，直接处理认证错误
    if (options.path == '/user/token') {
      LogUtils.e('$_tag[$requestId] Token 刷新请求返回 401，需要重新登录');
      await _authService.handleTokenExpired();
      return null;
    }

    // 检查是否有有效的 refresh token（不要求 access token 也在：
    // access 可能为空但 refresh 有效，应尝试刷新而非直接登出）(#4 配套)。
    if (!_authService.hasRefreshToken || _authService.isAuthTokenExpired) {
      LogUtils.w('$_tag[$requestId] 没有有效的 refresh token，需要重新登录');
      await _authService.handleTokenExpired();
      return null;
    }

    // 获取 TokenManager
    final tokenManager = _authService.tokenManager;

    // 尝试刷新 token
    LogUtils.d('$_tag[$requestId] 开始刷新 token');
    final refreshStartAt = DateTime.now();
    try {
      final refreshResult = await tokenManager.refreshAccessToken().timeout(
        ApiServiceConfig.tokenRefreshMaxWait,
      );
      final refreshCostMs = DateTime.now()
          .difference(refreshStartAt)
          .inMilliseconds;
      LogUtils.d(
        '$_tag[$requestId] Token 刷新完成: '
        'success=${refreshResult.success}, '
        'authError=${refreshResult.isAuthError}, '
        'cost=${refreshCostMs}ms',
      );

      if (refreshResult.success) {
        LogUtils.d('$_tag[$requestId] Token 刷新成功，重试请求');

        // 重试当前请求
        try {
          final retryOptions = options.copyWith(
            extra: {
              ...options.extra,
              _authRetryKey: true,
              _requestIdKey: requestId,
            },
          );
          final response = await _retryRequest(retryOptions);
          return response;
        } catch (e) {
          LogUtils.e('$_tag[$requestId] 刷新后重试失败', error: e);
          // 如果重试仍然失败，可能是其他问题
          if (e is d_dio.DioException && e.response?.statusCode == 401) {
            await _authService.handleTokenExpired();
          }
          return null;
        }
      } else if (refreshResult.isAuthError) {
        LogUtils.w('$_tag[$requestId] Token 刷新失败（认证错误），需要重新登录');
        _markAuthRefreshFailed(options, 'refresh_auth_failed_after_401');
        await _authService.handleTokenExpired();
        return null;
      } else {
        // 网络错误，不清理 token
        LogUtils.w(
          '$_tag[$requestId] Token 刷新失败（网络错误）: ${refreshResult.errorMessage}',
        );
        _markAuthRefreshFailed(options, 'refresh_network_failed_after_401');
        return null;
      }
    } on TimeoutException catch (_) {
      LogUtils.w('$_tag[$requestId] Token 刷新超时，放弃本次 401 自动恢复: ${options.path}');
      _markAuthRefreshFailed(options, 'refresh_timeout_after_401');
      return null;
    }
  }

  /// 重试请求
  Future<d_dio.Response<dynamic>> _retryRequest(
    d_dio.RequestOptions options,
  ) async {
    final requestId = _ensureRequestId(options);
    // 获取最新的 token
    final accessToken = _authService.accessToken;
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    } else {
      LogUtils.w('$_tag[$requestId] 重试时没有可用的 access token');
      throw d_dio.DioException(
        requestOptions: options,
        error: 'No valid access token for retry',
        type: d_dio.DioExceptionType.unknown,
      );
    }

    LogUtils.d('$_tag[$requestId] 重试请求: ${options.path}');
    final response = await _dio.fetch<dynamic>(options);
    _throwIfNotSuccess(response);
    return response;
  }

  Future<d_dio.Response<dynamic>?> _retryWithoutAuthentication(
    d_dio.RequestOptions options,
  ) async {
    final requestId = _ensureRequestId(options);
    if (options.extra[_anonymousRetryKey] == true) {
      return null;
    }

    try {
      final retryOptions = options.copyWith(
        headers: {...options.headers}..remove('Authorization'),
        extra: {
          ...options.extra,
          _anonymousRetryKey: true,
          _forceAnonymousKey: true,
          _requestAccessKey: ApiRequestAccess.publicOnly.name,
          _requestIdKey: requestId,
        },
      );
      LogUtils.d('$_tag[$requestId] 匿名重试请求: ${options.path}');
      final response = await _dio.fetch<dynamic>(retryOptions);
      return response;
    } catch (error) {
      LogUtils.w('$_tag[$requestId] 匿名重试失败: ${options.path} ($error)');
      return null;
    }
  }

  /// 处理网络重试
  Future<d_dio.Response?> _handleNetworkRetry(d_dio.DioException error) async {
    final options = error.requestOptions;

    // 仅对幂等方法做网络重试：POST/PUT/PATCH/DELETE 在 send/receive 超时后
    // 可能已被服务端处理，重试会导致重复提交(点赞/评论/关注等)(N1)。
    final method = options.method.toUpperCase();
    const idempotentMethods = {'GET', 'HEAD', 'OPTIONS'};
    if (!idempotentMethods.contains(method)) {
      LogUtils.d('$_tag 非幂等方法($method)不做网络重试，避免重复提交');
      return null;
    }

    // 获取当前重试次数
    final currentRetry = options.extra[_retryCountKey] as int? ?? 0;
    final maxRetries =
        options.extra[_maxRetriesKey] as int? ??
        ApiServiceConfig.maxNetworkRetries;

    if (currentRetry >= maxRetries) {
      LogUtils.w('$_tag 达到最大重试次数 ($maxRetries)');
      return null;
    }

    // 计算延迟时间（指数退避）
    final delayMs =
        ApiServiceConfig.baseRetryDelay.inMilliseconds *
        (1 << currentRetry); // 2^retry
    final delay = Duration(
      milliseconds: delayMs.clamp(
        0,
        ApiServiceConfig.maxRetryDelay.inMilliseconds,
      ),
    );

    LogUtils.d(
      '$_tag 网络错误，${delay.inMilliseconds}ms 后重试 '
      '(${currentRetry + 1}/$maxRetries)',
    );

    await Future.delayed(delay);

    // 更新重试次数
    options.extra[_retryCountKey] = currentRetry + 1;

    // 更新 token（可能在等待期间刷新了）
    final accessToken = _authService.accessToken;
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    try {
      final response = await _dio.fetch(options);
      return response;
    } on d_dio.DioException catch (retryError) {
      // 如果重试仍然失败，检查是否需要继续重试
      if (_isNetworkError(retryError)) {
        return _handleNetworkRetry(retryError);
      }
      // 其他错误（如 401、500）不继续网络重试
      rethrow;
    }
  }

  /// 判断是否为网络错误（应该重试的错误）
  bool _isNetworkError(d_dio.DioException e) {
    switch (e.type) {
      case d_dio.DioExceptionType.connectionTimeout:
      case d_dio.DioExceptionType.sendTimeout:
      case d_dio.DioExceptionType.receiveTimeout:
      case d_dio.DioExceptionType.connectionError:
        return true;
      case d_dio.DioExceptionType.unknown:
        // 检查是否为网络相关异常
        final error = e.error;
        if (error != null) {
          final errorStr = error.toString().toLowerCase();
          // 证书错误不重试：重试也只会再次失败(N-low)。
          if (errorStr.contains('certificate') ||
              errorStr.contains('cert_') ||
              errorStr.contains('tls_')) {
            return false;
          }
          if (errorStr.contains('handshake') ||
              errorStr.contains('socket') ||
              errorStr.contains('connection') ||
              errorStr.contains('network') ||
              errorStr.contains('reset')) {
            return true;
          }
        }
        return false;
      default:
        return false;
    }
  }

  /// 处理认证错误
  Future<void> handleAuthError() async {
    await _authService.handleTokenExpired();
  }

  void _throwIfNotSuccess(d_dio.Response response) {
    if (response.extra['cloudflare_parse_failed'] == true) {
      throw d_dio.DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: d_dio.DioExceptionType.unknown,
        message: 'Cloudflare challenge solved but response parsing failed',
      );
    }

    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      throw d_dio.DioException.badResponse(
        statusCode: statusCode,
        requestOptions: response.requestOptions,
        response: response,
      );
    }
  }

  d_dio.Response<T> _castResponse<T>(d_dio.Response<dynamic> response) {
    return d_dio.Response<T>(
      data: response.data as T?,
      headers: response.headers,
      requestOptions: response.requestOptions,
      statusCode: response.statusCode,
      isRedirect: response.isRedirect,
      redirects: response.redirects,
      statusMessage: response.statusMessage,
      extra: response.extra,
    );
  }

  /// GET 请求
  Future<d_dio.Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    d_dio.CancelToken? cancelToken,
    d_dio.Options? options,
    ApiRequestAccess requestAccess = ApiRequestAccess.authRequired,
    int? maxNetworkRetries,
    IwaraSite? site,
  }) async {
    try {
      final requestOptions = _prepareRequestOptions(
        options,
        headers: headers,
        requestAccess: requestAccess,
        maxNetworkRetries: maxNetworkRetries,
        site: site,
      );

      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
      );
      _throwIfNotSuccess(response);
      return _castResponse<T>(response);
    } on d_dio.DioException catch (e) {
      GlobalErrorListener.recordDioException(e);
      final failure = ApiFailureResolver.resolve(e);
      LogUtils.e(
        '$_tag GET 请求失败: ${e.message}, Path: $path, '
        'kind=${failure.kind.name}, status=${failure.statusCode}',
        error: e,
      );
      rethrow;
    }
  }

  /// POST 请求
  Future<d_dio.Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    d_dio.CancelToken? cancelToken,
    d_dio.Options? options,
    ApiRequestAccess requestAccess = ApiRequestAccess.authRequired,
    int? maxNetworkRetries,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: _prepareRequestOptions(
          options,
          requestAccess: requestAccess,
          maxNetworkRetries: maxNetworkRetries,
        ),
      );
      _throwIfNotSuccess(response);
      return _castResponse<T>(response);
    } on d_dio.DioException catch (e) {
      GlobalErrorListener.recordDioException(e);
      final failure = ApiFailureResolver.resolve(e);
      LogUtils.e(
        '$_tag POST 请求失败: ${e.message}, kind=${failure.kind.name}, '
        'status=${failure.statusCode}',
        error: e,
      );
      rethrow;
    }
  }

  /// DELETE 请求
  Future<d_dio.Response<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    d_dio.CancelToken? cancelToken,
    d_dio.Options? options,
    ApiRequestAccess requestAccess = ApiRequestAccess.authRequired,
    int? maxNetworkRetries,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: _prepareRequestOptions(
          options,
          requestAccess: requestAccess,
          maxNetworkRetries: maxNetworkRetries,
        ),
      );
      _throwIfNotSuccess(response);
      return _castResponse<T>(response);
    } on d_dio.DioException catch (e) {
      GlobalErrorListener.recordDioException(e);
      final failure = ApiFailureResolver.resolve(e);
      LogUtils.e(
        '$_tag DELETE 请求失败: ${e.message}, kind=${failure.kind.name}, '
        'status=${failure.statusCode}',
        error: e,
      );
      rethrow;
    }
  }

  /// PUT 请求
  Future<d_dio.Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    d_dio.CancelToken? cancelToken,
    d_dio.Options? options,
    ApiRequestAccess requestAccess = ApiRequestAccess.authRequired,
    int? maxNetworkRetries,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: _prepareRequestOptions(
          options,
          requestAccess: requestAccess,
          maxNetworkRetries: maxNetworkRetries,
        ),
      );
      _throwIfNotSuccess(response);
      return _castResponse<T>(response);
    } on d_dio.DioException catch (e) {
      GlobalErrorListener.recordDioException(e);
      final failure = ApiFailureResolver.resolve(e);
      LogUtils.e(
        '$_tag PUT 请求失败: ${e.message}, kind=${failure.kind.name}, '
        'status=${failure.statusCode}',
        error: e,
      );
      rethrow;
    }
  }

  /// 获取全站公告（sitewide announcement）
  Future<ApiResult<IwaraPageModel>> fetchSitewideAnnouncement() async {
    try {
      final response = await get(
        '/page/sitewide-announcement',
        headers: const {
          'accept': 'application/json',
          'content-type': 'application/json',
          'cache-control': 'no-cache',
          'pragma': 'no-cache',
        },
        requestAccess: ApiRequestAccess.publicOnly,
      );

      if (response.data is! Map<String, dynamic>) {
        return ApiResult.fail('Invalid response data type: ${response.data}');
      }

      return ApiResult.success(
        data: IwaraPageModel.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      LogUtils.e('获取全站公告失败', tag: _tag, error: e);
      final errorMessage = CommonUtils.parseExceptionMessage(e);
      return ApiResult.fail(errorMessage, exception: e);
    }
  }
}
