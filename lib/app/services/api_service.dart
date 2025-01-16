// api_service.dart

import 'package:dio/dio.dart' as d_dio;
import 'package:dio/io.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:i_iwara/common/enums/media_enums.dart';
import 'package:i_iwara/i18n/strings.g.dart';
import 'package:oktoast/oktoast.dart';

import '../../common/constants.dart';
import '../../utils/logger_utils.dart';
import 'auth_service.dart';

class ApiService extends GetxService {
  static ApiService? _instance;
  late d_dio.Dio _dio;
  final AuthService _authService = Get.find<AuthService>();
  final String _tag = 'ApiService';

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
      connectTimeout: const Duration(seconds: 45000),
      receiveTimeout: const Duration(seconds: 45000),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36',
        'Accept': 'application/json, text/plain, */*',
        // 'Accept-Language': 'en-US,en;q=0.9',
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
            
        // 检查是否已登录
        if (!_authService.hasToken || !_authService.isAuthenticated) {
          // 如果是需要认证的接口,直接返回错误
          if (_isAuthRequiredPath(options.path)) {
            // 显示友好提示
            showToastWidget(MDToastWidget(
              message: t.errors.pleaseLoginFirst,
              type: MDToastType.warning
            ));
            
            return handler.reject(
              d_dio.DioException(
                requestOptions: options,
                error: 'Authentication required',
                type: d_dio.DioExceptionType.badResponse,
                response: d_dio.Response(
                  statusCode: 401,
                  requestOptions: options,
                  data: {'message': 'Please login first'}
                ),
              ),
            );
          }
          // 非认证接口继续请求
          return handler.next(options);
        }
            
        // 检查 token 是否需要刷新
        if (_authService.isAccessTokenExpired) {
          LogUtils.d('$_tag Token已过期，尝试刷新');
          // 对于特定路径使用静默刷新
          final silent = _isSilentRefreshPath(options.path);
          final success = await _authService.refreshAccessToken(silent: silent);
          if (!success) {
            if (!silent) {
              // 显示友好提示
              showToastWidget(MDToastWidget(
                message: t.errors.sessionExpired,
                type: MDToastType.warning
              ));
            }
            
            return handler.reject(
              d_dio.DioException(
                requestOptions: options,
                error: 'Token refresh failed',
                type: d_dio.DioExceptionType.badResponse,
                response: d_dio.Response(
                  statusCode: 401,
                  requestOptions: options,
                  data: {'message': 'Session expired'}
                ),
              ),
            );
          }
        }
        
        // 添加认证头
        if (_authService.accessToken != null) {
          options.headers['Authorization'] = 'Bearer ${_authService.accessToken}';
        }
        
        return handler.next(options);
      },
      onError: (d_dio.DioException error, handler) async {
        // 处理网络错误
        if (error.type == d_dio.DioExceptionType.connectionTimeout ||
            error.type == d_dio.DioExceptionType.receiveTimeout ||
            error.type == d_dio.DioExceptionType.sendTimeout) {
          showToastWidget(MDToastWidget(
            message: t.errors.networkError,
            type: MDToastType.error
          ));
          return handler.next(error);
        }
        
        // 处理认证相关错误
        if (error.response?.statusCode == 401) {
          // 如果未登录,直接返回错误
          if (!_authService.hasToken || !_authService.isAuthenticated) {
            showToastWidget(MDToastWidget(
              message: t.errors.pleaseLoginFirst,
              type: MDToastType.warning
            ));
            return handler.next(error);
          }

          LogUtils.e('遭遇401错误，尝试刷新token', tag: _tag);
          
          try {
            // 尝试刷新 token
            final success = await _authService.refreshAccessToken();
            if (success) {
              // 重试原请求
              final opts = d_dio.Options(
                method: error.requestOptions.method,
                headers: {
                  ...error.requestOptions.headers,
                  'Authorization': 'Bearer ${_authService.accessToken}'
                },
              );
              
              final cloneReq = await _dio.request(
                error.requestOptions.path,
                options: opts,
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
              );
              return handler.resolve(cloneReq);
            }
            
            // 刷新失败，显示会话过期提示
            showToastWidget(MDToastWidget(
              message: t.errors.sessionExpired,
              type: MDToastType.warning
            ));
          } catch (e) {
            LogUtils.e('刷新token失败', tag: _tag, error: e);
            showToastWidget(MDToastWidget(
              message: t.errors.sessionExpired,
              type: MDToastType.warning
            ));
          }
        } else if (error.response?.statusCode == 403) {
          // 403通常表示权限问题
          if (_authService.isAuthenticated) {
            await _authService.handleTokenExpired();
            showToastWidget(MDToastWidget(
              message: t.errors.noPermission,
              type: MDToastType.error
            ));
          }
        } else {
          // 其他错误显示服务器返回的错误信息
          final message = error.response?.data?['message'] ?? t.errors.unknownError;
          showToastWidget(MDToastWidget(
            message: message,
            type: MDToastType.error
          ));
        }
        
        LogUtils.e('请求失败', tag: _tag, error: error);
        return handler.next(error);
      },
    ));

    return this;
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

  // 判断是否是需要认证的路径
  bool _isAuthRequiredPath(String path) {
    // 这里添加所有需要认证的路径前缀
    final authRequiredPaths = [
      '/user/',
      '/forum/',
      '/comment/',
      '/video/like',
      '/video/follow',
      '/playlist/',
      '/conversation/',
      '/notifications/',
    ];
    
    return authRequiredPaths.any((prefix) => path.startsWith(prefix));
  }

  // 判断是否需要静默刷新的路径
  bool _isSilentRefreshPath(String path) {
    // 这些路径的token刷新不需要显示提示
    final silentPaths = [
      '/user/counts',  // 通知计数
      '/user/notifications',  // 通知列表
      '/user/profile',  // 用户资料
    ];
    
    return silentPaths.any((prefix) => path.startsWith(prefix));
  }

}
