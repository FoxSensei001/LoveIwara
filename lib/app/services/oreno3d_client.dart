import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'
    show InAppWebViewController;
import 'package:get/get.dart' hide Response;
import 'package:i_iwara/utils/logger_utils.dart';
import 'iwara_network_service.dart';
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

  /// 拿不到 WebView 真实 UA 的平台（Windows/Linux）用它。WebView2 是 Chromium，
  /// 报成桌面 Chrome 与它的 JS 指纹对得上。
  static const String _fallbackUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36';

  /// 过盾拿到的 cf_clearance 与 UA 绑定：Dio 与过盾 WebView 必须报同一个 UA，
  /// 否则 cookie 拿回来也不认、每个请求都重新挑战。WebView 用的是请求头里的 UA，
  /// 所以这里让 Dio 报 WebView 自己的默认 UA——手机 WebView 顶着一个 Windows
  /// Chrome 的 UA 本身就是 CF 眼里的可疑指纹。全进程只问一次。
  static Future<String>? _webViewUserAgent;

  static Future<String> _resolveUserAgent() {
    return _webViewUserAgent ??= () async {
      if (!(GetPlatform.isAndroid ||
          GetPlatform.isIOS ||
          GetPlatform.isMacOS)) {
        return _fallbackUserAgent;
      }
      try {
        final ua = await InAppWebViewController.getDefaultUserAgent();
        if (ua.isNotEmpty) return ua;
      } catch (e) {
        LogUtils.w('获取 WebView 默认 UA 失败，退回内置 UA: $e', 'Oreno3dClient');
      }
      return _fallbackUserAgent;
    }();
  }

  late final Dio _dio;

  Oreno3dClient({
    Dio? dio,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Map<String, String>? headers,
    bool interactiveChallenge = true,
  }) {
    _dio = dio ?? Dio();

    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout ?? const Duration(seconds: 30),
      receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
      headers: {
        'User-Agent': _fallbackUserAgent,
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8,ja;q=0.7',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
        ...?headers,
      },
      followRedirects: true,
      maxRedirects: 5,
      validateStatus: (status) => status != null && status < 500,
    );
    _dio.options.persistentConnection = false;

    final hasCustomUserAgent =
        headers?.keys.any((k) => k.toLowerCase() == 'user-agent') ?? false;
    if (!hasCustomUserAgent) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            options.headers['User-Agent'] = await _resolveUserAgent();
            handler.next(options);
          },
        ),
      );
    }

    // 添加拦截器用于调试和错误处理
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 仅记录方法/URL/查询参数；不打印 headers 与 data，避免日志噪音和潜在信息泄漏
          LogUtils.d(
            '🚀 发送请求: ${options.method} ${options.baseUrl}${options.path} query=${options.queryParameters}',
            'Oreno3dClient',
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          // 记录响应信息
          final responseInfo = {
            'statusCode': response.statusCode,
            'url':
                '${response.requestOptions.baseUrl}${response.requestOptions.path}',
            'responseHeaders': response.headers.map,
            'responseSize': response.data?.toString().length ?? 0,
            'duration': response.requestOptions.extra['duration'] ?? 'unknown',
          };
          LogUtils.d(
            '✅ 收到响应: ${response.statusCode} ${response.requestOptions.baseUrl}${response.requestOptions.path}',
            'Oreno3dClient',
          );
          LogUtils.d('响应详情: $responseInfo', 'Oreno3dClient');
          handler.next(response);
        },
        onError: (error, handler) {
          // 记录错误信息
          final errorInfo = {
            'method': error.requestOptions.method,
            'url':
                '${error.requestOptions.baseUrl}${error.requestOptions.path}',
            'statusCode': error.response?.statusCode,
            'errorType': error.type.toString(),
            'errorMessage': error.message,
          };
          LogUtils.e(
            '❌ 请求失败: ${error.requestOptions.method} ${error.requestOptions.baseUrl}${error.requestOptions.path}',
            error: error,
            tag: 'Oreno3dClient',
          );
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
          final startTime =
              response.requestOptions.extra['startTime'] as DateTime?;
          if (startTime != null) {
            final duration = DateTime.now().difference(startTime);
            response.requestOptions.extra['duration'] =
                '${duration.inMilliseconds}ms';
          }
          handler.next(response);
        },
        onError: (error, handler) {
          final startTime =
              error.requestOptions.extra['startTime'] as DateTime?;
          if (startTime != null) {
            final duration = DateTime.now().difference(startTime);
            error.requestOptions.extra['duration'] =
                '${duration.inMilliseconds}ms';
          }
          handler.next(error);
        },
      ),
    );

    // 共用 iwara 那套过盾：共享 CookieJar（cf_clearance 一处拿到全站生效）+
    // 挑战时先无头 WebView 自动过、5 秒没过弹全屏 WebView 让用户手动验证。
    // 此前这里是裸 Dio，撞上挑战只会得到一个「访问被拒绝」。
    // [interactiveChallenge] 为 false（后台任务）时只走无头，过不去也不弹窗。
    if (Get.isRegistered<IwaraNetworkService>()) {
      Get.find<IwaraNetworkService>().registerDio(
        _dio,
        decodeJsonAfterChallenge: false,
        interactiveChallenge: interactiveChallenge,
      );
    } else {
      LogUtils.w('网络服务未就绪，oreno3d 请求不带过盾', 'Oreno3dClient');
    }
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
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        api,
        queryParameters: {
          'keyword': keyword,
          'page': page > 1 ? page : null,
          'sort': sortType.value,
        }..removeWhere((key, value) => value == null),
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200) {
        final htmlContent = response.data as String;
        return Oreno3dHtmlParser.parseSearchResult(
          htmlContent,
          keyword,
          page: page,
        );
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message:
              '${slang.t.oreno3d.errors.requestFailed} ${response.statusCode}',
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
          message:
              '${slang.t.oreno3d.errors.requestFailed} ${response.statusCode}',
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
  Future<String> getVideoDetail(
    String videoUrl, {
    CancelToken? cancelToken,
  }) async {
    try {
      String url = videoUrl;
      if (!url.startsWith('http')) {
        url = url.startsWith('/') ? url : '/$url';
      }

      final response = await _dio.get(url, cancelToken: cancelToken);

      if (response.statusCode == 200) {
        return response.data as String;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message:
              '${slang.t.oreno3d.errors.requestFailed} ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // 如果是取消请求，直接重新抛出，保持 DioException 类型
      if (e.type == DioExceptionType.cancel) {
        rethrow;
      }
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('${slang.t.oreno3d.errors.getVideoDetailError}: $e');
    }
  }

  /// 获取视频详情
  /// [videoId] 视频ID
  Future<Oreno3dVideoDetail?> getVideoDetailParsed(
    String videoId, {
    CancelToken? cancelToken,
  }) async {
    try {
      final htmlContent = await getVideoDetail(
        '/movies/$videoId',
        cancelToken: cancelToken,
      );
      return Oreno3dHtmlParser.parseVideoDetail(htmlContent, videoId);
    } on DioException catch (e) {
      // 如果是取消请求，直接重新抛出，保持 DioException 类型
      if (e.type == DioExceptionType.cancel) {
        rethrow;
      }

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

  /// 拉取详情页，**只有**它指向的 iwara 视频ID 与 [expectedIwaraVideoId] 一致时
  /// 才解析并返回详情；不一致返回 null。
  ///
  /// 用于匹配流程里的候选校验：那一步只需要确认「这条 oreno3d 视频是不是当前这条
  /// iwara 视频」，为一份 86KB 的 HTML 建整棵 DOM（实测 3.56ms/次，手机上更久，
  /// 且在主 isolate）纯属浪费。这里先用正则抠 ID（0.022ms），对上了才解析同一份 HTML。
  ///
  /// 视频不存在（404）时返回 null；其余网络错误按 [getVideoDetail] 的约定抛出。
  Future<Oreno3dVideoDetail?> getVideoDetailIfIwaraIdMatches(
    String videoId,
    String expectedIwaraVideoId, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        '/movies/$videoId',
        cancelToken: cancelToken,
      );

      // 视频被删/ID 不存在：不是错误，只是这条候选不作数。
      if (response.statusCode == 404) return null;
      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message:
              '${slang.t.oreno3d.errors.requestFailed} ${response.statusCode}',
        );
      }

      final htmlContent = response.data as String;
      if (Oreno3dHtmlParser.extractIwaraVideoId(htmlContent) !=
          expectedIwaraVideoId) {
        return null;
      }
      return Oreno3dHtmlParser.parseVideoDetail(htmlContent, videoId);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) rethrow;
      throw _handleDioException(e);
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
      case DioExceptionType.transformTimeout:
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
            return Exception(
              '${slang.t.oreno3d.errors.requestFailed} $statusCode',
            );
        }
      case DioExceptionType.cancel:
        return Exception(slang.t.oreno3d.errors.requestCancelled);
      case DioExceptionType.connectionError:
        return Exception(slang.t.oreno3d.errors.connectionError);
      case DioExceptionType.unknown:
        return Exception(slang.t.oreno3d.errors.networkRequestFailed);
    }
  }

  /// 关闭客户端
  void close({bool force = false}) {
    if (Get.isRegistered<IwaraNetworkService>()) {
      Get.find<IwaraNetworkService>().unregisterDio(_dio);
    }
    _dio.close(force: force);
  }
}
