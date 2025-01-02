import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:i_iwara/app/models/video_source.model.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:path_provider/path_provider.dart';
import '../app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:path/path.dart' as p;
class CommonUtils {
  /// 格式化Duration 为 mm:ss
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  /// 进入全屏
  /// toVerticalScreen: 是否进入竖屏全屏（仅IOS Android有效）
  static Future<void> defaultEnterNativeFullscreen(
      {bool toVerticalScreen = false}) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await Future.wait(
          [
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
          ],
        );
      } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        // 此处使用media_kit_video的MethodChannel，
        await const MethodChannel('com.alexmercerind/media_kit_video')
            .invokeMethod(
          'Utils.EnterNativeFullscreen',
        );
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  /// 将videoSources转换成videoResolutions
  static List<VideoResolution> convertVideoSourcesToResolutions(
      List<VideoSource>? videoSources,
      {filterPreview = false}) {
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
      List<VideoResolution>? videoResolutions, String? resolutionTag) {
    if (videoResolutions == null || resolutionTag == null) {
      return null;
    }
    return videoResolutions
        .firstWhere(
          (element) =>
              element.label.toLowerCase() == resolutionTag.toLowerCase(),
          orElse: () => VideoResolution(label: '', url: ''),
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

  /// 获取应用目录
  static Future<Directory> getAppDirectory({String pathSuffix = ''}) async {
    final directory = await getApplicationDocumentsDirectory();
    // join 上 applicationName
    final path = p.join(directory.path, CommonConstants.applicationName, pathSuffix);
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
