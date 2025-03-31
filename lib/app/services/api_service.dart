// api_service.dart

import 'dart:async';
import 'dart:collection';

import 'package:dio/dio.dart' as d_dio;
import 'package:dio/io.dart';
import 'package:get/get.dart';

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
    LogUtils.d('TokenQueue: 添加任务到队列，当前队列长度: ${_queue.length}');
    if (_queue.length >= maxQueueSize) {
      throw Exception('Token refresh queue is full');
    }

    final completer = Completer<T>();
    
    Future<void> executeTask() async {
      try {
        LogUtils.d('TokenQueue: 开始执行队列任务');
        final result = await task();
        completer.complete(result);
        LogUtils.d('TokenQueue: 队列任务执行完成');
      } catch (e) {
        LogUtils.e('TokenQueue: 队列任务执行失败', error: e);
        completer.completeError(e);
      }
    }

    _queue.add(executeTask);

    if (!_processing) {
      _processing = true;
      LogUtils.d('TokenQueue: 队列开始处理，队列长度: ${_queue.length}');
      while (_queue.isNotEmpty) {
        final nextTask = _queue.removeFirst();
        await nextTask();
      }
      _processing = false;
      LogUtils.d('TokenQueue: 队列处理完成');
    } else {
      LogUtils.d('TokenQueue: 队列正在处理中，新任务已添加到队列');
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
  
  bool _interceptorAdded = false;

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

    if (_interceptorAdded) {
      return this;
    }

    // 修改拦截器
    _dio.interceptors.add(d_dio.InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = _authService.accessToken;
        LogUtils.d('ApiService: 拦截器处理请求: ${options.path}, params: ${options.queryParameters}');
        
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
          LogUtils.e('ApiService: 认证错误 ${error.response?.statusCode}');
          
          // 如果是刷新token的请求失败，直接处理认证错误
          if (error.requestOptions.path == '/user/token') {
            await handleAuthError();
            return handler.next(error);
          }

          final result = await _refreshQueue.add(() async {
            return await _authService.refreshAccessToken();
          });
          
          if (result) {
            try {
              final response = await _retryRequest(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              LogUtils.e('重试请求失败', error: e);
              await handleAuthError();
            }
          } else {
            await handleAuthError();
          }
        }
        return handler.next(error);
      },
    ));

    _interceptorAdded = true;
    return this;
  }

  // 重试请求
  Future<d_dio.Response<T>> _retryRequest<T>(d_dio.RequestOptions options) async {
    LogUtils.d('ApiService: 开始重试请求: ${options.path}');
    
    // 获取最新的 token
    final accessToken = _authService.accessToken;
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    
    LogUtils.d('ApiService: 重试请求 Headers: ${options.headers}');
    
    return _dio.fetch<T>(options..copyWith(
      baseUrl: options.baseUrl,
      // 确保使用原始请求的所有参数
      queryParameters: options.queryParameters,
      data: options.data,
      // 其他参数保持不变
    ));
  }

  // 处理认证错误
  Future<void> handleAuthError() async {
    // 清理token和用户状态
    await _authService.handleTokenExpired();
  }

  Future<d_dio.Response<T>> get<T>(String path,
      {Map<String, dynamic>? queryParameters,
      Map<String, dynamic>? headers,
      d_dio.CancelToken? cancelToken}) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: d_dio.Options(headers: headers),
        cancelToken: cancelToken,
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
