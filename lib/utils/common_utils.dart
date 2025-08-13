import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:i_iwara/app/models/video_source.model.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:path_provider/path_provider.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import '../app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:path/path.dart' as p;

class CommonUtils {
  /// 格式化Duration 为 mm:ss 或 hh:mm:ss（适用于超过1小时的视频）
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    // 如果时长超过1小时，添加小时显示
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  /// 进入全屏
  /// toVerticalScreen: 是否进入竖屏全屏（仅IOS Android有效）
  static Future<void> defaultEnterNativeFullscreen({
    bool toVerticalScreen = false,
  }) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await Future.wait([
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.immersiveSticky,
            overlays: [],
          ),
          SystemChrome.setPreferredOrientations(
            toVerticalScreen
                ? [DeviceOrientation.portraitUp]
                : [
                    DeviceOrientation.landscapeLeft,
                    DeviceOrientation.landscapeRight,
                  ],
          ),
        ]);
      } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        // 此处使用media_kit_video的MethodChannel，
        await const MethodChannel(
          'com.alexmercerind/media_kit_video',
        ).invokeMethod('Utils.EnterNativeFullscreen');
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  /// 将videoSources转换成videoResolutions
  static List<VideoResolution> convertVideoSourcesToResolutions(
    List<VideoSource>? videoSources, {
    filterPreview = false,
  }) {
    // VideoSource#src#view 是视频播放源
    final List<VideoResolution> videoResolutions = [];
    if (videoSources == null) {
      return videoResolutions;
    }

    for (final VideoSource videoSource in videoSources) {
      if (videoSource.src != null && videoSource.src!.view != null) {
        if (filterPreview) {
          if (videoSource.name == 'preview') {
            continue;
          }
        }
        videoResolutions.add(
          VideoResolution(
            label: videoSource.name ?? '',
            url: 'https:${videoSource.src!.view}',
          ),
        );
      }
    }

    return videoResolutions;
  }

  /// 根据清晰度标签查找对应的视频源
  static String? findUrlByResolutionTag(
    List<VideoResolution>? videoResolutions,
    String? resolutionTag,
  ) {
    if (videoResolutions == null || videoResolutions.isEmpty) {
      return null;
    }

    if (resolutionTag == null || resolutionTag.isEmpty) {
      return videoResolutions.first.url;
    }

    // 如果videoResolutions非空，先挑出第一个作为兜底
    String fallbackUrl = '';
    String fallbackLabel = '';
    if (videoResolutions.isNotEmpty) {
      fallbackUrl = videoResolutions.first.url;
      fallbackLabel = videoResolutions.first.label;
    }

    return videoResolutions
        .firstWhere(
          (element) =>
              element.label.toLowerCase() == resolutionTag.toLowerCase(),
          orElse: () => VideoResolution(label: fallbackLabel, url: fallbackUrl),
        )
        .url;
  }

  /// 格式化时间为人性化显示
  static String formatFriendlyTimestamp(DateTime? timestamp) {
    if (timestamp == null) {
      return '';
    }
    final t = slang.t;
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return t.common.justNow;
    } else if (difference.inHours < 1) {
      return t.common.minutesAgo(num: difference.inMinutes);
    } else if (difference.inDays < 1) {
      return t.common.hoursAgo(num: difference.inHours);
    } else if (difference.inDays < 7) {
      return t.common.daysAgo(num: difference.inDays);
    } else {
      return "${timestamp.year}-${_twoDigits(timestamp.month)}-${_twoDigits(timestamp.day)} "
          "${_twoDigits(timestamp.hour)}:${_twoDigits(timestamp.minute)}";
    }
  }

  /// 辅助方法，将数字补齐为两位
  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  /// 格式化数字为千、万，如果不是中文则返回外国人用的数字格式 1.5k.... 依旧是保留小数点后两位
  /// @param num 数字
  /// @return 格式化后的数字字符串
  static String formatFriendlyNumber(int? num) {
    if (num == null) {
      return '';
    }
    String formatNumber(double n) {
      String s = n.toStringAsFixed(2);
      if (s.endsWith('.00')) {
        return s.substring(0, s.length - 3);
      } else if (s.endsWith('0')) {
        return s.substring(0, s.length - 1);
      } else {
        return s;
      }
    }

    if (slang.LocaleSettings.currentLocale.languageCode == 'zh') {
      if (num < 1000) {
        return num.toString();
      } else if (num < 10000) {
        double result = num / 1000;
        return '${formatNumber(result)}千';
      } else if (num < 100000000) {
        double result = num / 10000;
        return '${formatNumber(result)}万';
      } else {
        double result = num / 100000000;
        return '${formatNumber(result)}亿';
      }
    } else {
      if (num < 1000) {
        return num.toString();
      } else if (num < 1000000) {
        double result = num / 1000;
        return '${formatNumber(result)}k';
      } else if (num < 1000000000) {
        double result = num / 1000000;
        return '${formatNumber(result)}M';
      } else {
        double result = num / 1000000000;
        return '${formatNumber(result)}B';
      }
    }
  }

  /// 获取应用目录（外部存储优先，回退到内部存储）
  static Future<Directory> getAppDirectory({String pathSuffix = ''}) async {
    Directory directory;

    try {
      // 优先使用外部存储目录（Android: /storage/emulated/0/Android/data/包名/files）
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        directory = externalDir;
      } else {
        // 回退到内部存储目录
        directory = await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      // 如果外部存储获取失败，使用内部存储
      LogUtils.w('获取外部存储失败，使用内部存储', 'CommonUtils');
      directory = await getApplicationDocumentsDirectory();
    }

    // join 上 applicationName
    final path = p.join(
      directory.path,
      CommonConstants.applicationName,
      pathSuffix,
    );
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// 获取内部应用专用目录
  static Future<Directory> getInternalAppDirectory({String pathSuffix = ''}) async {
    final directory = await getApplicationDocumentsDirectory();
    // join 上 applicationName
    final path = p.join(
      directory.path,
      CommonConstants.applicationName,
      pathSuffix,
    );
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// 获取外部应用专用目录
  static Future<Directory?> getExternalAppDirectory({String pathSuffix = ''}) async {
    try {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir == null) return null;

      // join 上 applicationName
      final path = p.join(
        externalDir.path,
        CommonConstants.applicationName,
        pathSuffix,
      );
      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    } catch (e) {
      LogUtils.e('获取外部应用专用目录失败', tag: 'CommonUtils', error: e);
      return null;
    }
  }

  /// 获取文件扩展名
  static String getFileExtension(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      return path.substring(path.lastIndexOf('.') + 1).toLowerCase();
    } catch (e) {
      LogUtils.e('获取文件扩展名失败', tag: 'CommonUtils', error: e);
      return 'unknown';
    }
  }

  static String getDeviceLocale() {
    final locale = Get.deviceLocale?.languageCode ?? 'en';
    switch (locale) {
      case 'zh':
        return 'zh-CN';
      case 'zh-HK':
      case 'zh-TW':
        return 'zh-TW';
    }
    return locale;
  }

  /// 获取视频链接的过期时间
  static DateTime? getVideoLinkExpireTime(String videoLink) {
    final uri = Uri.parse(videoLink);
    final expires = uri.queryParameters['expires'];
    if (expires == null) {
      return null;
    }
    return DateTime.parse(expires);
  }

  // 通过path来格式化uri
  static String formatSavePathUriByPath(String path) {
    if (path.isEmpty) return '';

    try {
      // 统一处理路径分隔符
      String formattedPath = path;
      if (Platform.isWindows) {
        // Windows系统：统一使用反斜杠，处理可能混合的正斜杠
        formattedPath = path.replaceAll('/', '\\');
        // 处理可能的多个连续反斜杠
        formattedPath = formattedPath.replaceAll(RegExp(r'\\+'), '\\');
        // 处理Windows路径中的特殊字符
        formattedPath = formattedPath.replaceAll(RegExp(r'[<>"|?*]'), '_');
      } else {
        // Unix系统（Linux/macOS）：统一使用正斜杠
        formattedPath = path.replaceAll('\\', '/');
        // 处理可能的多个连续正斜杠
        formattedPath = formattedPath.replaceAll(RegExp(r'/+'), '/');
      }

      // 处理空格和其他特殊字符
      formattedPath = formattedPath
          .replaceAll(RegExp(r'\s+'), '_') // 空白字符替换为下划线
          .replaceAll(RegExp(r'_{2,}'), '_'); // 多个连续下划线替换为单个

      // 检查文件是否已存在，如果存在则自动重命名
      formattedPath = _generateUniqueFilePath(formattedPath);

      return formattedPath;
    } catch (e) {
      LogUtils.e('格式化URI失败', tag: 'CommonUtils', error: e);
      return path;
    }
  }

  /// 生成唯一的文件路径，如果文件已存在则自动添加序号
  static String _generateUniqueFilePath(String originalPath) {
    File file = File(originalPath);
    
    // 如果文件不存在，直接返回原路径
    if (!file.existsSync()) {
      return originalPath;
    }

    // 分离目录、文件名和扩展名
    String directory = p.dirname(originalPath);
    String fileName = p.basenameWithoutExtension(originalPath);
    String extension = p.extension(originalPath);

    int counter = 1;
    String newPath;
    
    // 循环查找可用的文件名
    do {
      String newFileName = '$fileName($counter)';
      newPath = p.join(directory, '$newFileName$extension');
      file = File(newPath);
      counter++;
    } while (file.existsSync());

    return newPath;
  }

  static String formatDate(DateTime start) {
    return '${start.year}-${_twoDigits(start.month)}-${_twoDigits(start.day)}';
  }

  // 根据屏幕宽度计算卡片宽度
  static double calculateCardWidth(double screenWidth) {
    if (screenWidth <= 600) {
      // 窄屏设备，显示2列
      return screenWidth / 2 - 8;
    } else if (screenWidth <= 900) {
      // 中等屏幕，显示3列
      return screenWidth / 3 - 12;
    } else if (screenWidth <= 1200) {
      // 较大屏幕，显示4列
      return screenWidth / 4 - 16;
    } else {
      // 大屏幕，显示5列
      return screenWidth / 5 - 20;
    }
  }

  /// 分析网络错误并返回用户友好的错误消息
  static String parseExceptionMessage(dynamic error) {
    final bool isDesktop = Platform.isMacOS || Platform.isWindows || Platform.isLinux;

    String withDesktopHint(String msg) => isDesktop ? '$msg${slang.t.common.parseExceptionDestopHint}' : msg;

    String extractPort(String message) {
      final match = RegExp(r'Invalid port (\d+)').firstMatch(message);
      return match != null ? match.group(1) ?? '' : '';
    }

    if (error is DioException) {
      final String errorMessage = error.message ?? error.error?.toString() ?? '';
      final statusCode = error.response?.statusCode;

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return withDesktopHint('${slang.t.errors.network.basicPrefix}${slang.t.errors.network.requestTimeout}');
        case DioExceptionType.badResponse:
          return statusCode != null
              ? withDesktopHint('${slang.t.errors.network.basicPrefix}${slang.t.errors.network.serverError} ($statusCode)')
              : withDesktopHint('${slang.t.errors.network.basicPrefix}${slang.t.errors.network.unexpectedError}');
        case DioExceptionType.cancel:
          // return withDesktopHint('请求已取消');
          return withDesktopHint('${slang.t.errors.network.basicPrefix}${slang.t.errors.network.requestCanceled}');
        case DioExceptionType.connectionError:
          if (errorMessage.contains('Invalid port')) {
            final port = extractPort(errorMessage);
            return port.isNotEmpty
                ? withDesktopHint('${slang.t.errors.network.basicPrefix}${slang.t.errors.network.invalidPort}: $port')
                : withDesktopHint('${slang.t.errors.network.basicPrefix}${slang.t.errors.network.proxyPortError}');
          }
          if (errorMessage.contains('Connection refused')) {
            return withDesktopHint('${slang.t.errors.network.basicPrefix}${slang.t.errors.network.connectionRefused}');
          }
          if (errorMessage.contains('Network is unreachable')) {
            return withDesktopHint('${slang.t.errors.network.basicPrefix}${slang.t.errors.network.networkUnreachable}');
          }
          if (errorMessage.contains('No route to host')) {
            return withDesktopHint('${slang.t.errors.network.basicPrefix}${slang.t.errors.network.noRouteToHost}');
          }
          return withDesktopHint('${slang.t.errors.network.basicPrefix}${slang.t.errors.network.connectionFailed}');
        case DioExceptionType.unknown:
          if (errorMessage.contains('Invalid port')) {
            final port = extractPort(errorMessage);
            return port.isNotEmpty
                ? withDesktopHint('${slang.t.errors.network.basicPrefix}${slang.t.errors.network.invalidPort}: $port')
                : withDesktopHint('${slang.t.errors.network.basicPrefix}${slang.t.errors.network.proxyPortError}');
          }
          if (errorMessage.contains('HandshakeException') || errorMessage.contains('Connection terminated during handshake')) {
            return withDesktopHint('${slang.t.errors.network.basicPrefix}${slang.t.errors.network.sslConnectionFailed}');
          }
          // 兜底返回原始错误信息
          return errorMessage.isNotEmpty
              ? errorMessage
              : withDesktopHint('${slang.t.errors.network.basicPrefix}${slang.t.errors.network.unexpectedError}');
        default:
          return errorMessage.isNotEmpty
              ? errorMessage
              : withDesktopHint('${slang.t.errors.network.basicPrefix}${slang.t.errors.network.unexpectedError}');
      }
    }

    // 处理非DioException类型的错误
    final String errorString = error?.toString() ?? '';
    if (errorString.isNotEmpty && errorString != 'null') {
      // 检查是否为HandshakeException
      if (errorString.contains('HandshakeException') || errorString.contains('Connection terminated during handshake')) {
        return withDesktopHint('${slang.t.errors.network.basicPrefix}${slang.t.errors.network.sslConnectionFailed}');
      }
      return errorString;
    }

    return slang.t.errors.errorWhileFetching;
  }
}