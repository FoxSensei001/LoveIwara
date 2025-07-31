import 'package:dio/dio.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import '../models/oreno3d_video.model.dart';
import 'oreno3d_html_parser.dart';

enum Oreno3dSortType {
  hot('hot', '急上昇'),
  favorites('favorites', '高評価'),
  latest('latest', '新着'),
  popularity('popularity', '人気');

  const Oreno3dSortType(this.value, this.displayName);
  final String value;
  final String displayName;
}

class Oreno3dClient {
  static const String baseUrl = 'https://oreno3d.com';
  late final Dio _dio;

  Oreno3dClient({
    Dio? dio,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Map<String, String>? headers,
  }) {
    _dio = dio ?? Dio();
    
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout ?? const Duration(seconds: 30),
      receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8,ja;q=0.7',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
        ...?headers,
      },
      followRedirects: true,
      maxRedirects: 5,
      validateStatus: (status) => status != null && status < 500,
    );

    // 添加拦截器用于调试和错误处理
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) {
          LogUtils.e('请求 ereno3d 错误', error: error, tag: 'Oreno3dClient');
          handler.next(error);
        },
      ),
    );
  }

  /// 搜索视频
  /// [keyword] 搜索关键词
  /// [page] 页码，从1开始
  /// [sortType] 排序类型
  Future<Oreno3dSearchResult> searchVideos({
    required String keyword,
    int page = 1,
    Oreno3dSortType sortType = Oreno3dSortType.hot,
  }) async {
    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {
          'keyword': keyword,
          'page': page > 1 ? page : null,
          'sort': sortType.value,
        }..removeWhere((key, value) => value == null),
      );

      if (response.statusCode == 200) {
        final htmlContent = response.data as String;
        return Oreno3dHtmlParser.parseSearchResult(htmlContent, keyword, page: page);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: '请求失败，状态码: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('搜索视频时发生未知错误: $e');
    }
  }

  /// 获取热门视频列表
  Future<Oreno3dSearchResult> getPopularVideos({
    int page = 1,
    Oreno3dSortType sortType = Oreno3dSortType.hot,
  }) async {
    try {
      final response = await _dio.get(
        '/movies',
        queryParameters: {
          'page': page > 1 ? page : null,
          'sort': sortType.value,
        }..removeWhere((key, value) => value == null),
      );

      if (response.statusCode == 200) {
        final htmlContent = response.data as String;
        return Oreno3dHtmlParser.parseSearchResult(htmlContent, '', page: page);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: '请求失败，状态码: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('获取热门视频时发生未知错误: $e');
    }
  }

  /// 获取视频详情页面HTML
  /// [videoUrl] 视频URL或路径
  Future<String> getVideoDetail(String videoUrl) async {
    try {
      String url = videoUrl;
      if (!url.startsWith('http')) {
        url = url.startsWith('/') ? url : '/$url';
      }

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        return response.data as String;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: '请求失败，状态码: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('获取视频详情时发生未知错误: $e');
    }
  }

  /// 下载图片或文件
  /// [url] 文件URL
  /// [savePath] 保存路径
  /// [onReceiveProgress] 下载进度回调
  Future<void> downloadFile({
    required String url,
    required String savePath,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      String downloadUrl = url;
      if (!url.startsWith('http')) {
        downloadUrl = url.startsWith('/') ? '$baseUrl$url' : '$baseUrl/$url';
      }

      await _dio.download(
        downloadUrl,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('下载文件时发生未知错误: $e');
    }
  }

  /// 处理Dio异常
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('连接超时，请检查网络连接');
      case DioExceptionType.sendTimeout:
        return Exception('发送请求超时');
      case DioExceptionType.receiveTimeout:
        return Exception('接收响应超时');
      case DioExceptionType.badCertificate:
        return Exception('证书验证失败');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        switch (statusCode) {
          case 404:
            return Exception('请求的资源不存在');
          case 403:
            return Exception('访问被拒绝，可能需要验证或权限');
          case 500:
            return Exception('服务器内部错误');
          case 503:
            return Exception('サービス暂时不可用');
          default:
            return Exception('请求失败，状态码: $statusCode');
        }
      case DioExceptionType.cancel:
        return Exception('请求已取消');
      case DioExceptionType.connectionError:
        return Exception('网络连接错误，请检查网络设置');
      case DioExceptionType.unknown:
      default:
        return Exception('网络请求失败: ${e.message}');
    }
  }

  /// 关闭客户端
  void close({bool force = false}) {
    _dio.close(force: force);
  }

}