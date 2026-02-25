// api_service.dart
// API 服务 - 处理所有 HTTP 请求，包括 401 处理和网络重试

import 'dart:async';

import 'package:dio/dio.dart' as d_dio;
import 'package:dio/io.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/api_result.model.dart';
import 'package:i_iwara/app/models/iwara_page.model.dart';

import '../../common/constants.dart';
import '../../utils/logger_utils.dart';
import '../ui/pages/popular_media_list/widgets/common_media_list_widgets.dart';
import 'auth_service.dart';
import 'cloudflare_service.dart';
import 'http_client_factory.dart';
import 'package:i_iwara/utils/common_utils.dart';

/// API 服务配置
class ApiServiceConfig {
  /// 请求超时时间
  static const Duration requestTimeout = Duration(seconds: 20);

  /// 最大网络重试次数
  static const int maxNetworkRetries = 2;

  /// 网络重试基础延迟
  static const Duration baseRetryDelay = Duration(milliseconds: 500);

  /// 最大重试延迟
  static const Duration maxRetryDelay = Duration(seconds: 3);
}

/// API 服务
class ApiService extends GetxService {
  static ApiService? _instance;
  late d_dio.Dio _dio;
  final AuthService _authService = Get.find<AuthService>();
  final String _tag = 'ApiService';

  bool _interceptorAdded = false;

  // 等待 token 刷新的请求队列
  final List<_PendingRequest> _pendingRequests = [];
  bool _isProcessingQueue = false;

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
          'x-site': CommonConstants.iwaraSiteHost,
          'Referer': CommonConstants.iwaraBaseUrl,
          'Origin': CommonConstants.iwaraBaseUrl,
        },
      ),
    );

    // 配置 HTTP 客户端适配器（使用共享 HttpClient 实现连接复用）
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: HttpClientFactory.instance.createHttpClient,
    );

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
    return d_dio.InterceptorsWrapper(onRequest: _onRequest, onError: _onError);
  }

  /// 请求拦截
  void _onRequest(
    d_dio.RequestOptions options,
    d_dio.RequestInterceptorHandler handler,
  ) {
    final accessToken = _authService.accessToken;

    // 如果 token 正在刷新中，检查是否需要等待
    final tokenManager = _authService.tokenManager;

    // Check if the request should skip waiting for auth refresh
    final bool skipAuthWait = options.extra['skipAuthWait'] == true;

    if (tokenManager.isRefreshing && _authService.hasToken && !skipAuthWait) {
      LogUtils.d('$_tag Token 正在刷新中，请求 ${options.path} 等待刷新完成');
      _waitForRefreshThenRequest(options, handler);
      return;
    }

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    // 注入 Cloudflare clearance / UA 等信息（如已存在）
    if (Get.isRegistered<CloudflareService>()) {
      try {
        final cf = Get.find<CloudflareService>();
        cf.applyHeadersForRequest(headers: options.headers, uri: options.uri);
      } catch (_) {
        // ignore
      }
    }

    // 标记请求开始时间，用于判断 token 有效性
    options.extra['requestStartTime'] = DateTime.now().millisecondsSinceEpoch;

    if (skipAuthWait) {
      LogUtils.d('$_tag 请求: ${options.method} ${options.path} (跳过鉴权等待)');
    } else {
      LogUtils.d('$_tag 请求: ${options.method} ${options.path}');
    }
    handler.next(options);
  }

  /// 等待 token 刷新完成后发送请求
  Future<void> _waitForRefreshThenRequest(
    d_dio.RequestOptions options,
    d_dio.RequestInterceptorHandler handler,
  ) async {
    try {
      final tokenManager = _authService.tokenManager;
      final result = await tokenManager.refreshAccessToken();

      if (result.success) {
        // 使用新 token 发送请求
        final accessToken = _authService.accessToken;
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        options.extra['requestStartTime'] =
            DateTime.now().millisecondsSinceEpoch;
        LogUtils.d('$_tag Token 刷新完成，继续请求: ${options.path}');
        handler.next(options);
      } else if (result.isAuthError) {
        // 认证错误，拒绝请求
        LogUtils.w('$_tag Token 刷新失败，拒绝请求: ${options.path}');
        handler.reject(
          d_dio.DioException(
            requestOptions: options,
            error: 'Token refresh failed: ${result.errorMessage}',
            type: d_dio.DioExceptionType.unknown,
          ),
        );
      } else {
        // 网络错误，使用现有 token 尝试请求
        final accessToken = _authService.accessToken;
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        options.extra['requestStartTime'] =
            DateTime.now().millisecondsSinceEpoch;
        LogUtils.d('$_tag Token 刷新遇到网络错误，使用现有 token 尝试请求: ${options.path}');
        handler.next(options);
      }
    } catch (e) {
      LogUtils.e('$_tag 等待 token 刷新时出错', error: e);
      handler.reject(
        d_dio.DioException(
          requestOptions: options,
          error: e,
          type: d_dio.DioExceptionType.unknown,
        ),
      );
    }
  }

  /// 错误拦截
  Future<void> _onError(
    d_dio.DioException error,
    d_dio.ErrorInterceptorHandler handler,
  ) async {
    // 处理 Cloudflare 403 质询：拉起 WebView 让用户完成验证后重试一次
    if (Get.isRegistered<CloudflareService>()) {
      try {
        final cf = Get.find<CloudflareService>();
        final options = error.requestOptions;
        final bool alreadyRetried = options.extra['cfRetry'] == true;
        final bool skip = options.extra['skipCfChallenge'] == true;

        if (!skip && !alreadyRetried && cf.isCloudflareChallenge(error)) {
          LogUtils.w('$_tag Cloudflare 403 质询，尝试拉起验证: ${options.uri}', _tag);

          final ok = await cf.ensureVerified(
            triggerUri: options.uri,
            reason: '访问 ${options.uri.host} 需要通过 Cloudflare 验证',
          );

          if (ok) {
            options.extra['cfRetry'] = true;
            try {
              final response = await _dio.fetch(options);
              return handler.resolve(response);
            } catch (e) {
              LogUtils.w('$_tag Cloudflare 验证后重试失败: $e', _tag);
              return handler.next(error);
            }
          }

          return handler.next(error);
        }
      } catch (_) {
        // ignore
      }
    }

    // 处理 401 错误
    if (error.response?.statusCode == 401) {
      final result = await _handle401Error(error);
      if (result != null) {
        return handler.resolve(result);
      }
      return handler.next(error);
    }

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
  Future<d_dio.Response?> _handle401Error(d_dio.DioException error) async {
    final options = error.requestOptions;

    LogUtils.w('$_tag 收到 401 错误: ${options.path}');

    // 如果是 token 刷新请求本身失败，直接处理认证错误
    if (options.path == '/user/token') {
      LogUtils.e('$_tag Token 刷新请求返回 401，需要重新登录');
      await _authService.handleTokenExpired();
      return null;
    }

    // 检查是否有有效的 refresh token
    if (!_authService.hasToken || _authService.isAuthTokenExpired) {
      LogUtils.w('$_tag 没有有效的 refresh token，需要重新登录');
      await _authService.handleTokenExpired();
      return null;
    }

    // 获取 TokenManager
    final tokenManager = _authService.tokenManager;

    // 检查请求时 access token 是否实际有效
    // 如果请求开始时 token 还有效（剩余时间 > 10秒），说明可能是服务器端的问题
    final requestStartTime = options.extra['requestStartTime'] as int?;
    if (requestStartTime != null) {
      final requestTime = DateTime.fromMillisecondsSinceEpoch(requestStartTime);
      // 计算请求开始时 token 是否还有效
      final tokenRemainingAtRequest =
          tokenManager.accessTokenRemainingSeconds +
          DateTime.now().difference(requestTime).inSeconds;

      if (tokenRemainingAtRequest > 10 && !tokenManager.isRefreshing) {
        // Token 应该还有效，可能是服务器问题，直接重试一次
        LogUtils.d(
          '$_tag Token 在请求时应该有效 (剩余 ${tokenRemainingAtRequest}s)，直接重试',
        );
        try {
          final response = await _retryRequest(options);
          return response;
        } catch (e) {
          LogUtils.w('$_tag 直接重试失败: $e');
          // 继续执行刷新逻辑
        }
      }
    }

    // 如果已经有刷新任务在进行，将请求加入等待队列
    if (tokenManager.isRefreshing) {
      LogUtils.d('$_tag Token 刷新中，将请求加入等待队列');
      return _waitForRefreshAndRetry(options);
    }

    // 尝试刷新 token
    LogUtils.d('$_tag 开始刷新 token');
    final refreshResult = await tokenManager.refreshAccessToken();

    if (refreshResult.success) {
      LogUtils.d('$_tag Token 刷新成功，重试请求');

      // 处理等待队列中的请求
      _processQueuedRequests();

      // 重试当前请求
      try {
        final response = await _retryRequest(options);
        return response;
      } catch (e) {
        LogUtils.e('$_tag 刷新后重试失败', error: e);
        // 如果重试仍然失败，可能是其他问题
        if (e is d_dio.DioException && e.response?.statusCode == 401) {
          await _authService.handleTokenExpired();
        }
        return null;
      }
    } else if (refreshResult.isAuthError) {
      LogUtils.w('$_tag Token 刷新失败（认证错误），需要重新登录');
      await _authService.handleTokenExpired();

      // 通知等待队列中的请求失败
      _failQueuedRequests('Token refresh failed');
      return null;
    } else {
      // 网络错误，不清理 token
      LogUtils.w('$_tag Token 刷新失败（网络错误）: ${refreshResult.errorMessage}');
      _failQueuedRequests('Network error during token refresh');
      return null;
    }
  }

  /// 等待 token 刷新完成后重试请求
  Future<d_dio.Response?> _waitForRefreshAndRetry(
    d_dio.RequestOptions options,
  ) async {
    final completer = Completer<d_dio.Response?>();
    _pendingRequests.add(_PendingRequest(options, completer));

    return completer.future;
  }

  /// 处理等待队列中的请求
  void _processQueuedRequests() {
    if (_isProcessingQueue || _pendingRequests.isEmpty) return;

    _isProcessingQueue = true;

    // 取出所有等待中的请求，并发执行
    final pendingCopy = List<_PendingRequest>.from(_pendingRequests);
    _pendingRequests.clear();

    Future.microtask(() async {
      LogUtils.d('$_tag 并发回放 ${pendingCopy.length} 个等待请求');
      await Future.wait(
        pendingCopy.map((pending) async {
          try {
            final response = await _retryRequest(pending.options);
            pending.completer.complete(response);
          } catch (e) {
            LogUtils.e('$_tag 队列请求重试失败', error: e);
            pending.completer.complete(null);
          }
        }),
      );
      _isProcessingQueue = false;
    });
  }

  /// 使等待队列中的请求失败
  void _failQueuedRequests(String reason) {
    LogUtils.d('$_tag 使 ${_pendingRequests.length} 个等待请求失败: $reason');
    for (final pending in _pendingRequests) {
      pending.completer.complete(null);
    }
    _pendingRequests.clear();
  }

  /// 重试请求
  Future<d_dio.Response> _retryRequest(d_dio.RequestOptions options) async {
    // 获取最新的 token
    final accessToken = _authService.accessToken;
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    } else {
      LogUtils.w('$_tag 重试时没有可用的 access token');
      throw d_dio.DioException(
        requestOptions: options,
        error: 'No valid access token for retry',
        type: d_dio.DioExceptionType.unknown,
      );
    }

    LogUtils.d('$_tag 重试请求: ${options.path}');

    return _dio.fetch(options);
  }

  /// 处理网络重试
  Future<d_dio.Response?> _handleNetworkRetry(d_dio.DioException error) async {
    final options = error.requestOptions;

    // 获取当前重试次数
    final currentRetry = options.extra['retryCount'] as int? ?? 0;

    if (currentRetry >= ApiServiceConfig.maxNetworkRetries) {
      LogUtils.w('$_tag 达到最大重试次数 (${ApiServiceConfig.maxNetworkRetries})');
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
      '(${currentRetry + 1}/${ApiServiceConfig.maxNetworkRetries})',
    );

    await Future.delayed(delay);

    // 更新重试次数
    options.extra['retryCount'] = currentRetry + 1;

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

  /// GET 请求
  Future<d_dio.Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    d_dio.CancelToken? cancelToken,
    d_dio.Options? options,
  }) async {
    try {
      // 合并 headers 和 options
      var requestOptions = options ?? d_dio.Options();
      if (headers != null) {
        requestOptions.headers = {...?requestOptions.headers, ...headers};
      }

      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
      );
    } on d_dio.DioException catch (e) {
      GlobalErrorListener.recordDioException(e);
      LogUtils.e('$_tag GET 请求失败: ${e.message}, Path: $path', error: e);
      rethrow;
    }
  }

  /// POST 请求
  Future<d_dio.Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    d_dio.Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on d_dio.DioException catch (e) {
      GlobalErrorListener.recordDioException(e);
      LogUtils.e('$_tag POST 请求失败: ${e.message}', error: e);
      rethrow;
    }
  }

  /// DELETE 请求
  Future<d_dio.Response<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    d_dio.Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on d_dio.DioException catch (e) {
      GlobalErrorListener.recordDioException(e);
      LogUtils.e('$_tag DELETE 请求失败: ${e.message}', error: e);
      rethrow;
    }
  }

  /// PUT 请求
  Future<d_dio.Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    d_dio.Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on d_dio.DioException catch (e) {
      GlobalErrorListener.recordDioException(e);
      LogUtils.e('$_tag PUT 请求失败: ${e.message}', error: e);
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
        options: d_dio.Options(extra: {'skipAuthWait': true}),
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

/// 等待中的请求
class _PendingRequest {
  final d_dio.RequestOptions options;
  final Completer<d_dio.Response?> completer;

  _PendingRequest(this.options, this.completer);
}
