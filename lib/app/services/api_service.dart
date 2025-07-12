// api_service.dart

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:http/http.dart' as http;
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

// 自定义异常类
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

// 自定义响应类
class ApiResponse<T> {
  final int statusCode;
  final T data;
  final Map<String, String> headers;

  ApiResponse({
    required this.statusCode,
    required this.data,
    required this.headers,
  });
}

class ApiService extends GetxService {
  static ApiService? _instance;
  late http.Client _client;
  final AuthService _authService = Get.find<AuthService>();
  final MessageService _messageService = Get.find<MessageService>();
  final String _tag = 'ApiService';
  
  // 重试相关配置
  static const int maxRetries = 3;
  static const Duration baseRetryDelay = Duration(seconds: 1);
  static const Duration requestTimeout = Duration(seconds: 45);

  // 队列定义
  final _TokenQueue _refreshQueue = _TokenQueue();
  
  // 默认请求头
  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'User-Agent': 'Mozilla/5.0 (Linux; Android 12; Pixel 6 Build/SD1A.210817.023; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/94.0.4606.71 Mobile Safari/537.36',
    'Accept': 'application/json, text/plain, */*',
    'Origin': 'https://www.iwara.tv',
    'Referer': 'https://www.iwara.tv/',
    'Accept-Language': 'en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7',
    'Connection': 'keep-alive',
  };

  // 构造函数返回的是同一个
  ApiService._();

  http.Client get client => _client;

  // 获取实例的静态方法
  static Future<ApiService> getInstance() async {
    _instance ??= await ApiService._().init();
    return _instance!;
  }

  Future<ApiService> init() async {
    _client = http.Client();
    return this;
  }

  // 构建完整的URL
  String _buildUrl(String path) {
    if (path.startsWith('http')) {
      return path;
    }
    return '${CommonConstants.iwaraApiBaseUrl}$path';
  }

  // 构建请求头
  Map<String, String> _buildHeaders({Map<String, String>? additionalHeaders}) {
    final headers = Map<String, String>.from(_defaultHeaders);
    
    // 添加认证头
    final accessToken = _authService.accessToken;
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    
    // 添加额外的头
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    
    return headers;
  }

  // 处理HTTP响应
  Future<ApiResponse<T>> _handleResponse<T>(http.Response response) async {
    LogUtils.d('ApiService: 响应状态码: ${response.statusCode}');
    
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw ApiException('认证失败', statusCode: response.statusCode);
    }
    
    if (response.statusCode >= 400) {
      String errorMessage = '请求失败';
      try {
        final errorData = json.decode(response.body);
        errorMessage = errorData['message'] ?? errorMessage;
      } catch (e) {
        // 如果解析失败，使用默认错误消息
      }
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
    
    T data;
    if (T == String) {
      data = response.body as T;
    } else {
      try {
        data = json.decode(response.body) as T;
      } catch (e) {
        throw ApiException('响应解析失败: $e');
      }
    }
    
    return ApiResponse<T>(
      statusCode: response.statusCode,
      data: data,
      headers: response.headers,
    );
  }

  // 执行请求并处理认证错误
  Future<ApiResponse<T>> _executeRequest<T>(
    Future<http.Response> Function() request,
    String path,
  ) async {
    try {
      final response = await request().timeout(requestTimeout);
      return await _handleResponse<T>(response);
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        LogUtils.e('ApiService: 认证错误 ${e.statusCode}');
        
        // 如果是刷新token的请求失败，直接处理认证错误
        if (path == '/user/token') {
          await handleAuthError();
          rethrow;
        }

        final result = await _refreshQueue.add(() async {
          return await _authService.refreshAccessToken();
        });
        
        if (result) {
          try {
            // 重新执行请求
            final retryResponse = await request().timeout(requestTimeout);
            return await _handleResponse<T>(retryResponse);
          } catch (e) {
            LogUtils.e('重试请求失败', error: e);
            await handleAuthError();
            rethrow;
          }
        } else {
          await handleAuthError();
          rethrow;
        }
      }
      rethrow;
    } catch (e) {
      LogUtils.e('请求执行失败: $path', error: e);
      rethrow;
    }
  }

  // 处理认证错误
  Future<void> handleAuthError() async {
    // 清理token和用户状态
    await _authService.handleTokenExpired();
  }

  Future<ApiResponse<T>> get<T>(String path,
      {Map<String, dynamic>? queryParameters,
      Map<String, String>? headers}) async {
    try {
      final url = _buildUrl(path);
      final uri = Uri.parse(url);
      final finalUri = queryParameters != null 
          ? uri.replace(queryParameters: queryParameters.map((k, v) => MapEntry(k, v.toString())))
          : uri;
      
      LogUtils.d('ApiService: GET请求: $finalUri');
      
      return await _executeRequest<T>(
        () => _client.get(finalUri, headers: _buildHeaders(additionalHeaders: headers)),
        path,
      );
    } catch (e) {
      LogUtils.e('GET请求失败: $path', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<ApiResponse<T>> post<T>(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Map<String, String>? headers}) async {
    try {
      final url = _buildUrl(path);
      final uri = Uri.parse(url);
      final finalUri = queryParameters != null 
          ? uri.replace(queryParameters: queryParameters.map((k, v) => MapEntry(k, v.toString())))
          : uri;
      
      LogUtils.d('ApiService: POST请求: $finalUri');
      
      String? body;
      if (data != null) {
        if (data is String) {
          body = data;
        } else {
          body = json.encode(data);
        }
      }
      
      return await _executeRequest<T>(
        () => _client.post(finalUri, headers: _buildHeaders(additionalHeaders: headers), body: body),
        path,
      );
    } catch (e) {
      LogUtils.e('POST请求失败: $path', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<ApiResponse<T>> delete<T>(String path,
      {Map<String, dynamic>? queryParameters, Map<String, String>? headers}) async {
    try {
      final url = _buildUrl(path);
      final uri = Uri.parse(url);
      final finalUri = queryParameters != null 
          ? uri.replace(queryParameters: queryParameters.map((k, v) => MapEntry(k, v.toString())))
          : uri;
      
      LogUtils.d('ApiService: DELETE请求: $finalUri');
      
      return await _executeRequest<T>(
        () => _client.delete(finalUri, headers: _buildHeaders(additionalHeaders: headers)),
        path,
      );
    } catch (e) {
      LogUtils.e('DELETE请求失败: $path', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<ApiResponse<T>> put<T>(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Map<String, String>? headers}) async {
    try {
      final url = _buildUrl(path);
      final uri = Uri.parse(url);
      final finalUri = queryParameters != null 
          ? uri.replace(queryParameters: queryParameters.map((k, v) => MapEntry(k, v.toString())))
          : uri;
      
      LogUtils.d('ApiService: PUT请求: $finalUri');
      
      String? body;
      if (data != null) {
        if (data is String) {
          body = data;
        } else {
          body = json.encode(data);
        }
      }
      
      return await _executeRequest<T>(
        () => _client.put(finalUri, headers: _buildHeaders(additionalHeaders: headers), body: body),
        path,
      );
    } catch (e) {
      LogUtils.e('PUT请求失败: $path', tag: _tag, error: e);
      rethrow;
    }
  }

  // 重置代理 - HTTP包的代理设置需要在HttpClient层面处理
  void resetProxy() {
    // HTTP包的代理设置通过HttpOverrides.global处理
    // 这里保留方法以保持兼容性
    LogUtils.d('ApiService: 代理重置 - HTTP包通过HttpOverrides.global处理');
  }

  // token比较方法
  bool _isSameToken(String? token1, String? token2) {
    if (token1 == null || token2 == null) return false;
    
    // 移除Bearer前缀进行比较
    final t1 = token1.replaceFirst('Bearer ', '').trim();
    final t2 = token2.replaceFirst('Bearer ', '').trim();
    
    return t1 == t2;
  }

  @override
  void onClose() {
    _client.close();
    super.onClose();
  }
}
