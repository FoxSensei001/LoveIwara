import 'package:dio/dio.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import '../models/iwara_status.model.dart';
import 'iwara_status_html_parser.dart';

class IwaraStatusClient {
  static const String baseUrl = 'https://status.iwara.tv';
  late final Dio _dio;

  IwaraStatusClient({
    Dio? dio,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Map<String, String>? headers,
  }) {
    _dio = dio ?? Dio();
        
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout ?? const Duration(seconds: 15),
      receiveTimeout: receiveTimeout ?? const Duration(seconds: 15),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
        ...?headers,
      },
      followRedirects: true,
      maxRedirects: 5,
      validateStatus: (status) => status != null && status < 500,
    );
    _dio.options.persistentConnection = false;

    // 添加拦截器用于调试和错误处理
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          LogUtils.d('🚀 发送请求: ${options.method} ${options.baseUrl}${options.path}', 'IwaraStatusClient');
          handler.next(options);
        },
        onResponse: (response, handler) {
          LogUtils.d('✅ 收到响应: ${response.statusCode} ${response.requestOptions.baseUrl}${response.requestOptions.path}', 'IwaraStatusClient');
          handler.next(response);
        },
        onError: (error, handler) {
          LogUtils.e('❌ 请求失败: ${error.requestOptions.method} ${error.requestOptions.baseUrl}${error.requestOptions.path}', 
            error: error, tag: 'IwaraStatusClient');
          handler.next(error);
        },
      ),
    );

    // 添加请求时间拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.extra['startTime'] = DateTime.now();
          handler.next(options);
        },
        onResponse: (response, handler) {
          final startTime = response.requestOptions.extra['startTime'] as DateTime?;
          if (startTime != null) {
            final duration = DateTime.now().difference(startTime);
            response.requestOptions.extra['duration'] = '${duration.inMilliseconds}ms';
          }
          handler.next(response);
        },
        onError: (error, handler) {
          final startTime = error.requestOptions.extra['startTime'] as DateTime?;
          if (startTime != null) {
            final duration = DateTime.now().difference(startTime);
            error.requestOptions.extra['duration'] = '${duration.inMilliseconds}ms';
          }
          handler.next(error);
        },
      ),
    );
  }

  /// 获取 distribution 页面状态
  /// [page] 页面类型，默认为 'distribution'
  Future<IwaraStatusPage> getDistributionStatus({String page = 'distribution'}) async {
    try {
      final response = await _dio.get(
        '/',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        final htmlContent = response.data as String;
        return IwaraStatusHtmlParser.parseDistributionPage(htmlContent);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: '请求失败 ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('获取状态页面失败: $e');
    }
  }

  /// Handles Dio exceptions, translating them into more readable messages.
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Connection timed out');
      case DioExceptionType.sendTimeout:
        return Exception('Send timed out');
      case DioExceptionType.receiveTimeout:
        return Exception('Receive timed out');
      case DioExceptionType.badCertificate:
        return Exception('Certificate error');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        switch (statusCode) {
          case 404:
            return Exception('Resource not found');
          case 403:
            return Exception('Access denied');
          case 500:
            return Exception('Server error');
          case 503:
            return Exception('Service unavailable');
          default:
            return Exception('Request failed with status $statusCode');
        }
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      case DioExceptionType.connectionError:
        return Exception('Connection error');
      case DioExceptionType.unknown:
        return Exception('Network request failed');
    }
  }

  /// 关闭客户端
  void close({bool force = false}) {
    _dio.close(force: force);
  }
}
