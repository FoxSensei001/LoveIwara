import 'package:dio/dio.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import '../models/oreno3d_video.model.dart';
import 'oreno3d_html_parser.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

enum Oreno3dSortType {
  hot('hot'),
  favorites('favorites'),
  latest('latest'),
  popularity('popularity');

  const Oreno3dSortType(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case Oreno3dSortType.hot:
        return slang.t.oreno3d.sortTypes.hot;
      case Oreno3dSortType.favorites:
        return slang.t.oreno3d.sortTypes.favorites;
      case Oreno3dSortType.latest:
        return slang.t.oreno3d.sortTypes.latest;
      case Oreno3dSortType.popularity:
        return slang.t.oreno3d.sortTypes.popularity;
    }
  }
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
          // 记录请求信息
          final requestInfo = {
            'method': options.method,
            'url': '${options.baseUrl}${options.path}',
            'query': options.queryParameters,
            'headers': options.headers,
            'data': options.data,
          };
          LogUtils.i('🚀 发送请求: ${options.method} ${options.baseUrl}${options.path}', 'Oreno3dClient');
          LogUtils.d('请求详情: $requestInfo', 'Oreno3dClient');
          handler.next(options);
        },
        onResponse: (response, handler) {
          // 记录响应信息
          final responseInfo = {
            'statusCode': response.statusCode,
            'url': '${response.requestOptions.baseUrl}${response.requestOptions.path}',
            'responseHeaders': response.headers.map,
            'responseSize': response.data?.toString().length ?? 0,
            'duration': response.requestOptions.extra['duration'] ?? 'unknown',
          };
          LogUtils.i('✅ 收到响应: ${response.statusCode} ${response.requestOptions.baseUrl}${response.requestOptions.path}', 'Oreno3dClient');
          LogUtils.d('响应详情: $responseInfo', 'Oreno3dClient');
          handler.next(response);
        },
        onError: (error, handler) {
          // 记录错误信息
          final errorInfo = {
            'method': error.requestOptions.method,
            'url': '${error.requestOptions.baseUrl}${error.requestOptions.path}',
            'statusCode': error.response?.statusCode,
            'errorType': error.type.toString(),
            'errorMessage': error.message,
          };
          LogUtils.e('❌ 请求失败: ${error.requestOptions.method} ${error.requestOptions.baseUrl}${error.requestOptions.path}', 
            error: error, tag: 'Oreno3dClient');
          LogUtils.d('错误详情: $errorInfo', 'Oreno3dClient');
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

  /// 搜索视频
  /// [keyword] 搜索关键词
  /// [page] 页码，从1开始
  /// [sortType] 排序类型
  /// [api] 搜索API，默认是/search，有 /origins/:originId、/tags/:tagId、/characters/:characterId
  Future<Oreno3dSearchResult> searchVideos({
    required String keyword,
    int page = 1,
    Oreno3dSortType sortType = Oreno3dSortType.hot,
    String api = '/search',
  }) async {
    try {
      final response = await _dio.get(
        api,
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
          message: '${slang.t.oreno3d.errors.requestFailed} ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('${slang.t.oreno3d.errors.searchVideoError}: $e');
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
          message: '${slang.t.oreno3d.errors.requestFailed} ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('${slang.t.oreno3d.errors.getPopularVideoError}: $e');
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
          message: '${slang.t.oreno3d.errors.requestFailed} ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('${slang.t.oreno3d.errors.getVideoDetailError}: $e');
    }
  }

  /// 获取视频详情
  /// [videoId] 视频ID
  Future<Oreno3dVideoDetail?> getVideoDetailParsed(String videoId) async {
    try {
      final htmlContent = await getVideoDetail('/movies/$videoId');
      return Oreno3dHtmlParser.parseVideoDetail(htmlContent, videoId);
    } on DioException catch (e) {
      LogUtils.e(slang.t.oreno3d.messages.getVideoDetailFailed, error: e);

      // 如果是404错误，返回null表示视频不存在
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('${slang.t.oreno3d.errors.parseVideoDetailError}: $e');
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
      throw Exception('${slang.t.oreno3d.errors.downloadFileError}: $e');
    }
  }

  /// 处理Dio异常
  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception(slang.t.oreno3d.errors.connectionTimeout);
      case DioExceptionType.sendTimeout:
        return Exception(slang.t.oreno3d.errors.sendTimeout);
      case DioExceptionType.receiveTimeout:
        return Exception(slang.t.oreno3d.errors.receiveTimeout);
      case DioExceptionType.badCertificate:
        return Exception(slang.t.oreno3d.errors.badCertificate);
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        switch (statusCode) {
          case 404:
            return Exception(slang.t.oreno3d.errors.resourceNotFound);
          case 403:
            return Exception(slang.t.oreno3d.errors.accessDenied);
          case 500:
            return Exception(slang.t.oreno3d.errors.serverError);
          case 503:
            return Exception(slang.t.oreno3d.errors.serviceUnavailable);
          default:
            return Exception('${slang.t.oreno3d.errors.requestFailed} $statusCode');
        }
      case DioExceptionType.cancel:
        return Exception(slang.t.oreno3d.errors.requestCancelled);
      case DioExceptionType.connectionError:
        return Exception(slang.t.oreno3d.errors.connectionError);
      case DioExceptionType.unknown:
      default:
        return Exception(slang.t.oreno3d.errors.networkRequestFailed);
    }
  }

  /// 关闭客户端
  void close({bool force = false}) {
    _dio.close(force: force);
  }

}