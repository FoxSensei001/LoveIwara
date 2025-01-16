// api_service.dart

import 'dart:async';
import 'dart:collection';

import 'package:dio/dio.dart' as d_dio;
import 'package:dio/io.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/i18n/strings.g.dart';

import '../../common/constants.dart';
import '../../utils/logger_utils.dart';
import 'auth_service.dart';
import 'message_service.dart';

// 自定义Queue类
class _TokenQueue {
  final Queue<Future Function()> _queue = Queue();
  bool _processing = false;
  static const int maxQueueSize = 100;

  Future<T> add<T>(Future<T> Function() task) async {
    if (_queue.length >= maxQueueSize) {
      throw Exception('Token refresh queue is full');
    }

    final completer = Completer<T>();
    
    Future<void> executeTask() async {
      try {
        final result = await task();
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    }

    _queue.add(executeTask);

    if (!_processing) {
      _processing = true;
      while (_queue.isNotEmpty) {
        final nextTask = _queue.removeFirst();
        await nextTask();
      }
      _processing = false;
    }

    return completer.future;
  }
}

class ApiService extends GetxService {
  static ApiService? _instance;
  late d_dio.Dio _dio;
  final AuthService _authService = Get.find<AuthService>();
  final MessageService _messageService = Get.find<MessageService>();
  final String _tag = 'ApiService';
  
  // 重试相关配置
  static const int maxRetries = 3;
  static const Duration baseRetryDelay = Duration(seconds: 1);
  static const Duration requestTimeout = Duration(seconds: 45);

  // 队列定义
  final _TokenQueue _refreshQueue = _TokenQueue();
  
  // token刷新的URL
  static const String _tokenRefreshUrl = '/user/token';

  // 构造函数返回的是同一个
  ApiService._();

  d_dio.Dio get dio => _dio;

  // 获取实例的静态方法
  static Future<ApiService> getInstance() async {
    _instance ??= await ApiService._().init();
    return _instance!;
  }

  Future<ApiService> init() async {
    _dio = d_dio.Dio(d_dio.BaseOptions(
      baseUrl: CommonConstants.iwaraApiBaseUrl,
      connectTimeout: requestTimeout,
      receiveTimeout: requestTimeout,
      sendTimeout: requestTimeout,
      headers: {
        'Content-Type': 'application/json',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36',
        'Accept': 'application/json, text/plain, */*',
        'Connection': 'keep-alive',
        'Referer': CommonConstants.iwaraApiBaseUrl,
      },
    ));

    // 修改拦截器
    _dio.interceptors.add(d_dio.InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (CommonConstants.enableR18) {
          // do nothing
        } else {
          options.queryParameters = {
            ...options.queryParameters,
            'rating': MediaRating.GENERAL.value
          };
        }

        LogUtils.d(
            '请求: Method: ${options.method} Path: ${options.path} Params: ${options.queryParameters} Body: ${options.data}',
            _tag);
            
        // 如果是刷新token的请求，使用auth token
        if (options.path == _tokenRefreshUrl) {
          if (_authService.authToken != null) {
            options.headers['Authorization'] = 'Bearer ${_authService.authToken}';
            return handler.next(options);
          } else {
            return handler.reject(
              d_dio.DioException(
                requestOptions: options,
                error: 'No auth token available',
                type: d_dio.DioExceptionType.badResponse,
              ),
            );
          }
        }
            
        // 其他请求检查access token
        if (_authService.hasToken) {
          final accessToken = await _getValidAccessToken();
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
            return handler.next(options);
          }
        }
        
        // 无token或获取失败
        if (options.headers.containsKey('Authorization')) {
          options.headers.remove('Authorization');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        try {
          if (_authService.hasToken && 
              response.requestOptions.path != _tokenRefreshUrl &&
              _authService.isAccessTokenExpired) {
            bool success = await _refreshQueue.add(() async {
              var requestToken = response.requestOptions.headers["Authorization"] as String?;
              var currentToken = _authService.accessToken;

              if (!_isSameToken(requestToken, currentToken)) {
                // token不同，可能是其他请求已经刷新过了
                return true;
              }

              // 再次检查是否过期（可能在队列中等待时已被其他请求刷新）
              if (_authService.isAccessTokenExpired) {
                final refreshSuccess = await _authService.refreshAccessToken();
                if (refreshSuccess) {
                  response.requestOptions.headers["Authorization"] = 
                      "Bearer ${_authService.accessToken}";
                  return true;
                }
                return false;
              }
              return true;
            });

            if (success) {
              return handler.resolve(await _retryRequest(response.requestOptions));
            }
          }
        } catch (e) {
          LogUtils.e('Token刷新失败', tag: _tag, error: e);
          _handleGeneralError(d_dio.DioException(
            requestOptions: response.requestOptions,
            error: e.toString(),
          ));
        }
        return handler.next(response);
      },
      onError: (d_dio.DioException error, handler) async {
        // 处理网络错误
        if (error.type == d_dio.DioExceptionType.connectionTimeout ||
            error.type == d_dio.DioExceptionType.receiveTimeout ||
            error.type == d_dio.DioExceptionType.sendTimeout) {
          _handleNetworkError(error);
          return handler.next(error);
        }
        
        switch (error.response?.statusCode) {
          case 401: // Unauthorized - 未认证或认证已过期
            // 如果是刷新token的请求失败，直接返回
            if (error.requestOptions.path == _tokenRefreshUrl) {
              _handleAuthError(error);
              return handler.next(error);
            }

            if (_authService.hasToken) {
              try {
                bool success = await _refreshQueue.add(() async {
                  var requestToken = error.requestOptions.headers["Authorization"] as String?;
                  var currentToken = _authService.accessToken;

                  if (!_isSameToken(requestToken, currentToken)) {
                    return true;
                  }

                  if (_authService.isAccessTokenExpired) {
                    return await _authService.refreshAccessToken();
                  }
                  return true;
                });

                if (success) {
                  return handler.resolve(await _retryRequest(error.requestOptions));
                }
              } catch (e) {
                LogUtils.e('Token刷新失败', tag: _tag, error: e);
              }
            }
            
            _handleAuthError(error);
            break;
            
          case 403: // Forbidden - 已认证但无权限
            LogUtils.e('$_tag 遇到403错误（无权限访问）', error: error);
            _handleForbiddenError(error);
            break;
            
          default:
            _handleGeneralError(error);
        }
        
        return handler.next(error);
      },
    ));

    return this;
  }

  // 获取有效的access token
  Future<String?> _getValidAccessToken() async {
    if (_authService.isAuthTokenExpired) {
      await _authService.handleTokenExpired();
      return null;
    }

    if (_authService.isAccessTokenExpired) {
      final success = await _refreshQueue.add(() => _authService.refreshAccessToken());
      if (!success) return null;
    }

    return _authService.accessToken;
  }

  // 重试请求
  Future<d_dio.Response<T>> _retryRequest<T>(d_dio.RequestOptions options, {int currentRetry = 0}) async {
    try {
      final opts = d_dio.Options(
        method: options.method,
        headers: options.headers,
        sendTimeout: requestTimeout,
        receiveTimeout: requestTimeout,
      );
      
      return await _dio.request<T>(
        options.path,
        options: opts,
        data: options.data,
        queryParameters: options.queryParameters,
      );
    } catch (e) {
      if (currentRetry < maxRetries - 1) {
        // 计算递增的重试延迟
        final delay = baseRetryDelay * (currentRetry + 1);
        await Future.delayed(delay);
        return _retryRequest(options, currentRetry: currentRetry + 1);
      }
      rethrow;
    }
  }

  // 处理认证错误
  void _handleAuthError(d_dio.DioException error) {
    final message = error.response?.data?['message'];
    switch (message) {
      case 'errors.tokenExpired':
        _messageService.showMessage(
          t.errors.sessionExpired,
          MDToastType.warning,
        );
        break;
      case 'errors.invalidToken':
        _messageService.showMessage(
          'Invalid token',
          MDToastType.warning,
        );
        break;
      default:
        if (!_authService.hasToken) {
          _messageService.showMessage(
            t.errors.pleaseLoginFirst,
            MDToastType.warning,
          );
        } else {
          _messageService.showMessage(
            t.errors.sessionExpired,
            MDToastType.warning,
          );
        }
    }
  }

  // 处理权限错误
  void _handleForbiddenError(d_dio.DioException error) {
    final message = error.response?.data?['message'];
    switch (message) {
      case 'errors.premiumRequired':
        _messageService.showMessage(
          'Premium required',
          MDToastType.warning,
        );
        break;
      case 'errors.accountSuspended':
        _messageService.showMessage(
          'Account suspended',
          MDToastType.error,
        );
        break;
      default:
        _messageService.showMessage(
          t.errors.noPermission,
          MDToastType.warning,
        );
    }
  }

  // 处理网络错误
  void _handleNetworkError(d_dio.DioException error) {
    if (error.type == d_dio.DioExceptionType.connectionTimeout) {
      _messageService.showMessage(
        'Connection timeout',
        MDToastType.error,
      );
    } else if (error.type == d_dio.DioExceptionType.receiveTimeout) {
      _messageService.showMessage(
        'Receive timeout',
        MDToastType.error,
      );
    } else {
      _messageService.showMessage(
        t.errors.networkError,
        MDToastType.error,
      );
    }
  }

  // 处理一般错误
  void _handleGeneralError(d_dio.DioException error) {
    final message = error.response?.data?['message'] ?? t.errors.unknownError;
    _messageService.showMessage(
      message,
      MDToastType.error,
    );
  }

  Future<d_dio.Response<T>> get<T>(String path,
      {Map<String, dynamic>? queryParameters,
      Map<String, dynamic>? headers}) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: d_dio.Options(headers: headers),
      );
    } on d_dio.DioException catch (e) {
      LogUtils.e('GET请求失败: ${e.message}, Path: $path', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<d_dio.Response<T>> post<T>(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post<T>(path,
          data: data, queryParameters: queryParameters);
    } on d_dio.DioException catch (e) {
      LogUtils.e('POST请求失败: ${e.message}', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<d_dio.Response<T>> delete<T>(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.delete<T>(path, queryParameters: queryParameters);
    } on d_dio.DioException catch (e) {
      LogUtils.e('DELETE请求失败: ${e.message}', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<d_dio.Response<T>> put<T>(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.put<T>(path,
          data: data, queryParameters: queryParameters);
    } on d_dio.DioException catch (e) {
      LogUtils.e('PUT请求失败: ${e.message}', tag: _tag, error: e);
      rethrow;
    }
  }

  // resetProxy
  void resetProxy() {
    _dio.httpClientAdapter = IOHttpClientAdapter();
  }

  // token比较方法
  bool _isSameToken(String? token1, String? token2) {
    if (token1 == null || token2 == null) return false;
    
    // 移除Bearer前缀进行比较
    final t1 = token1.replaceFirst('Bearer ', '').trim();
    final t2 = token2.replaceFirst('Bearer ', '').trim();
    
    return t1 == t2;
  }

}
