import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:i_iwara/app/models/api_failure.model.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/models/video_source.model.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
// `loadAllLocales` 是 slang 的 extension：extension 只在不带前缀的导入里进作用域，
// 所以单独把这一条 show 进来（用它的是下面的 ensureAllAppLocalesLoaded）。
import 'package:slang/slang.dart' show LocaleSettingsExt;
import 'package:path_provider/path_provider.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/device_form_factor_utils.dart';
import 'package:i_iwara/utils/desktop_native_fullscreen.dart';
import 'package:media_kit_video/media_kit_video.dart' as media_kit_video;
import '../app/ui/pages/video_detail/controllers/my_video_state_controller.dart';
import 'package:path/path.dart' as p;
import 'package:i_iwara/app/services/config_service.dart';

class CommonUtils {
  /// 导出文件名用的本地时间戳后缀（`20260918_153012`）。同名导出多次时系统
  /// 会一路追加「(1)(2)…」，带上时间就既不撞名、也看得出是哪一次备份。
  static String exportFileTimestamp([DateTime? now]) {
    final t = now ?? DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${t.year}${two(t.month)}${two(t.day)}_'
        '${two(t.hour)}${two(t.minute)}${two(t.second)}';
  }

  /// 规范化 URL，确保有正确的协议前缀
  /// 如果 URL 已经包含 http:// 或 https://，则直接返回
  /// 如果 URL 以 // 开头，则添加 https: 前缀
  static String? normalizeUrl(String? url) {
    if (url == null || url.isEmpty) return url;

    // 如果已经有完整的协议前缀，直接返回
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // 如果以 // 开头，添加 https: 前缀
    if (url.startsWith('//')) {
      return 'https:$url';
    }

    // 其他情况，假设需要添加完整的 https:// 前缀
    return 'https://$url';
  }

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

  /// 将形如 `1:01`、`1:23:45` 的时间节点分量解析为 [Duration]。
  ///
  /// - 仅传入 [minutes] 与 [seconds] 时按「分:秒」解析；
  /// - 同时传入 [hours] 时按「时:分:秒」解析。
  /// - 分、秒分量必须 `< 60`，否则视为非法（如 `1:99`）返回 null。
  static Duration? parseTimestamp({
    String? hours,
    required String minutes,
    required String seconds,
  }) {
    final h = hours == null ? 0 : int.tryParse(hours);
    final m = int.tryParse(minutes);
    final s = int.tryParse(seconds);
    if (h == null || m == null || s == null) return null;
    // 分、秒必须在合法范围内，过滤误匹配
    if (m >= 60 || s >= 60) return null;
    if (h < 0 || m < 0 || s < 0) return null;
    return Duration(hours: h, minutes: m, seconds: s);
  }

  /// 进入全屏
  /// toVerticalScreen: 是否进入竖屏全屏（仅IOS Android有效）
  /// useGravityOrientation: 是否根据重力感应选择横屏方向（仅移动端有效）
  static Future<void> defaultEnterNativeFullscreen({
    bool toVerticalScreen = false,
    bool useGravityOrientation = false,
  }) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // XR 头显（Quest / Horizon OS 等）：App 是一块用户自己拖宽高的 2D 面板，
        // 任何固定方向请求都会让系统按该方向加信箱边、把面板宽度锁死。全屏在这里
        // 只需要沉浸模式铺满当前面板，方向一律不碰。
        if (await DeviceFormFactorUtils.resolveIsXrDevice()) {
          LogUtils.i('[全屏方向] XR 头显：跳过方向请求，仅进入沉浸模式', 'CommonUtils');
          await SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.immersiveSticky,
            overlays: [],
          );
          return;
        }

        List<DeviceOrientation> orientations;

        if (toVerticalScreen) {
          orientations = [DeviceOrientation.portraitUp];
        } else if (useGravityOrientation) {
          // 根据重力感应选择横屏方向
          orientations = await _getGravityBasedOrientations();
        } else {
          // 正常全屏：设置里没有「双向都行」的选项，一律按用户选择的固定方向进入。
          // ⚠️ 这里曾经写死允许 landscapeLeft/landscapeRight 两个方向、完全不读取
          // FULLSCREEN_ORIENTATION 配置，是「设置选左选右全部固定成左」这个回归的
          // 根因之一（另一半在 forceNativeOrientation 的原生 SENSOR_LANDSCAPE）。
          orientations = await _getConfigBasedOrientations();
        }

        LogUtils.i(
          '[全屏方向] setPreferredOrientations -> '
              '${orientations.map((o) => o.name).join(', ')}',
          'CommonUtils',
        );

        // 顺序执行且方向指令放最后：并发 Future.wait 里沉浸模式切换可能与方向
        // 变更抢占，个别 Android 机型会吞掉旋转，出现「点全屏不转屏」。
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.immersiveSticky,
          overlays: [],
        );
        await SystemChrome.setPreferredOrientations(orientations);
        // Android 原生兜底强制方向：确保关闭系统自动旋转 / 平板竖持也真旋转。
        // 必须把 orientations 已经解析出的具体左右方向透传给原生层，不能再传笼统的
        // 'landscape'——原生侧一旦用 SENSOR_LANDSCAPE 无视左右会重新导致同一个 bug。
        final String nativeOrientationMode = toVerticalScreen
            ? 'portrait'
            : (orientations.first == DeviceOrientation.landscapeLeft
                  ? 'landscape_left'
                  : 'landscape_right');
        await DeviceFormFactorUtils.forceNativeOrientation(
          nativeOrientationMode,
        );
      } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        // 桌面全屏的进与出都收在 [DesktopNativeFullscreen] 里：它同时负责留痕
        // （window_manager 不认这条路开的全屏）、窗口几何快照、以及「这个全屏
        // 还有没有人在里面演出」的登记。分开写迟早漏一半。
        await DesktopNativeFullscreen.enterNative();
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  /// 退出全屏。
  ///
  /// 桌面端交给 [DesktopNativeFullscreen.exitNative]（同一条 MethodChannel，
  /// 外加落痕）；移动端转交 media_kit 的实现（恢复系统 UI / 放开方向）。进出
  /// 成对收在 [CommonUtils] 里，标记才不会漏改。
  ///
  /// ⛔ 这里**不**还原窗口几何：几何还原有自己的时序（要等系统全屏真的退干净），
  /// 由调用方调 [DesktopNativeFullscreen.restoreGeometry]。
  static Future<void> defaultExitNativeFullscreen() async {
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      await DesktopNativeFullscreen.exitNative();
      return;
    }
    try {
      await media_kit_video.defaultExitNativeFullscreen();
    } finally {
      DesktopNativeFullscreen.markExited();
    }
  }

  /// 将设置里的横屏方向（用户意图，与 Android 实际表现一致）映射为当前平台
  /// 正确的 [DeviceOrientation]。
  ///
  /// iOS 上 Flutter 的 [DeviceOrientation.landscapeLeft] / [DeviceOrientation.landscapeRight]
  /// 触发的物理旋转方向与 Android 相反（iOS 按“设备旋转的方向”命名，Flutter 按
  /// “设备顶部的朝向”命名，二者互为镜像）。因此在 iOS 上做一次左右对调，才能让
  /// 实际旋转方向与用户在设置里选择的、以及 Android 上的表现保持一致。
  static DeviceOrientation _resolveLandscapeOrientation(String configValue) {
    // 'landscape_left'（含默认/未知值）都视为“左侧横屏”意图。
    final bool wantLeft = configValue != 'landscape_right';
    if (Platform.isIOS) {
      return wantLeft
          ? DeviceOrientation.landscapeRight
          : DeviceOrientation.landscapeLeft;
    }
    return wantLeft
        ? DeviceOrientation.landscapeLeft
        : DeviceOrientation.landscapeRight;
  }

  /// 根据配置获取屏幕方向
  static Future<List<DeviceOrientation>> _getConfigBasedOrientations() async {
    try {
      final configService = Get.find<ConfigService>();
      final orientation =
          configService[ConfigKey.FULLSCREEN_ORIENTATION] as String;
      return [_resolveLandscapeOrientation(orientation)];
    } catch (e) {
      debugPrint('获取配置方向失败: $e');
      return [_resolveLandscapeOrientation('landscape_left')]; // 默认左侧横屏
    }
  }

  /// 根据重力感应获取屏幕方向
  static Future<List<DeviceOrientation>> _getGravityBasedOrientations() async {
    try {
      final context = rootNavigatorKey.currentContext;
      if (context == null) {
        return await _getConfigBasedOrientations();
      }

      // 获取当前设备方向
      final currentOrientation = MediaQuery.of(context).orientation;

      // 如果当前已经是横屏，保持当前方向
      if (currentOrientation == Orientation.landscape) {
        // 获取当前的具体横屏方向
        final currentDeviceOrientation = await _getCurrentDeviceOrientation();
        if (currentDeviceOrientation != null) {
          return [currentDeviceOrientation];
        }
      }

      // 如果当前是竖屏，根据重力感应选择横屏方向
      // 由于重力感应数据获取复杂，我们使用配置的默认方向
      // 用户可以通过旋转设备来改变方向
      return await _getConfigBasedOrientations();
    } catch (e) {
      debugPrint('获取重力感应方向失败: $e');
      return await _getConfigBasedOrientations();
    }
  }

  /// 获取当前设备方向
  static Future<DeviceOrientation?> _getCurrentDeviceOrientation() async {
    try {
      final context = rootNavigatorKey.currentContext;
      if (context == null) {
        return null;
      }

      // 通过 MediaQuery 获取当前方向
      final orientation = MediaQuery.of(context).orientation;

      // 尝试通过系统信息获取当前设备方向
      // 这里我们使用一个简化的逻辑
      if (orientation == Orientation.landscape) {
        // 由于无法直接获取具体的横屏方向，我们返回配置的默认方向
        final configService = Get.find<ConfigService>();
        final defaultOrientation =
            configService[ConfigKey.FULLSCREEN_ORIENTATION] as String;
        // 与 _getConfigBasedOrientations 共用同一套 iOS 左右对调逻辑，保持一致。
        return _resolveLandscapeOrientation(defaultOrientation);
      }

      return null;
    } catch (e) {
      debugPrint('获取当前设备方向失败: $e');
      return null;
    }
  }

  /// 根据重力感应切换横屏方向（仅在全屏状态下使用）
  /// 这个方法会在横屏状态下根据重力感应在左右横屏之间切换
  static Future<void> switchLandscapeOrientationByGravity() async {
    try {
      if (!Platform.isAndroid && !Platform.isIOS) {
        return; // 仅移动端支持
      }

      final context = rootNavigatorKey.currentContext;
      if (context == null) {
        return;
      }

      // XR 头显没有「转屏」这回事，且任何方向请求都会把面板宽度锁死。
      if (DeviceFormFactorUtils.isXrDevice) {
        return;
      }

      // 获取当前方向
      final currentOrientation = MediaQuery.of(context).orientation;
      if (currentOrientation != Orientation.landscape) {
        return; // 只在横屏状态下切换
      }

      // 获取当前的具体横屏方向
      final currentDeviceOrientation = await _getCurrentDeviceOrientation();

      // 根据当前方向切换到另一个横屏方向
      List<DeviceOrientation> newOrientations;
      if (currentDeviceOrientation == DeviceOrientation.landscapeLeft) {
        newOrientations = [DeviceOrientation.landscapeRight];
      } else {
        newOrientations = [DeviceOrientation.landscapeLeft];
      }

      // 应用新的方向
      await SystemChrome.setPreferredOrientations(newOrientations);
    } catch (e) {
      debugPrint('切换横屏方向失败: $e');
    }
  }

  /// 清晰度统一排序优先级（从高到低）。source 固定最前，preview 固定最后，
  /// 其余按分辨率数值从高到低排列。列表之外的未知清晰度排在最后，
  /// 并保持彼此间的原始相对顺序（稳定排序）。
  static const List<String> _qualityOrder = [
    'source',
    '1080',
    '720',
    '540',
    '360',
    'preview',
  ];

  /// 获取清晰度名称对应的排序权重，权重越小越靠前。
  static int _qualitySortWeight(String? name) {
    if (name == null) return _qualityOrder.length;
    final index = _qualityOrder.indexOf(name.toLowerCase());
    return index == -1 ? _qualityOrder.length : index;
  }

  /// 清晰度的高低序：越小越高（原画 0 … 预览最大）；认不出的标签排最后。
  /// 与 [sortVideoResolutionsByQuality] 同一张表，供「向下降级」逻辑按位置比较。
  static int qualityRank(String? name) => _qualitySortWeight(name);

  /// 按统一的清晰度优先级对 [VideoSource] 列表排序，用于下载清晰度选择等场景。
  /// 使用稳定排序（保留原始相对顺序），避免同权重项之间顺序抖动。
  static List<VideoSource> sortVideoSourcesByQuality(
    List<VideoSource> sources,
  ) {
    final indexed = sources.indexed.toList()
      ..sort((a, b) {
        final weightCompare = _qualitySortWeight(
          a.$2.name,
        ).compareTo(_qualitySortWeight(b.$2.name));
        return weightCompare != 0 ? weightCompare : a.$1.compareTo(b.$1);
      });
    return indexed.map((e) => e.$2).toList();
  }

  /// 按统一的清晰度优先级对 [VideoResolution] 列表排序，用于播放器清晰度切换等场景。
  static List<VideoResolution> sortVideoResolutionsByQuality(
    List<VideoResolution> resolutions,
  ) {
    final indexed = resolutions.indexed.toList()
      ..sort((a, b) {
        final weightCompare = _qualitySortWeight(
          a.$2.label,
        ).compareTo(_qualitySortWeight(b.$2.label));
        return weightCompare != 0 ? weightCompare : a.$1.compareTo(b.$1);
      });
    return indexed.map((e) => e.$2).toList();
  }

  /// 获取清晰度的本地化展示文案，如 "Source" -> "原画"、"Preview" -> "预览"。
  /// 数字类分辨率（如 "540"、"1080"）保持原样展示，未知/空值回退为“未知”文案。
  static String getQualityDisplayLabel(slang.Translations t, String? name) {
    if (name == null || name.isEmpty) return t.download.errors.unknown;
    switch (name.toLowerCase()) {
      case 'source':
        return t.common.videoQualitySource;
      case 'preview':
        return t.common.preview;
      default:
        return name;
    }
  }

  /// 将videoSources转换成videoResolutions
  /// 转换结果按统一的清晰度优先级排序（source 固定最前，preview 固定最后）。
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
            url: CommonUtils.normalizeUrl(videoSource.src!.view) ?? '',
          ),
        );
      }
    }

    return sortVideoResolutionsByQuality(videoResolutions);
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
  ///
  /// [includeTime] 为 false 时，超过一周的旧时间只给到「年-月-日」——窄卡片上
  /// 摆不下时分，与其让省略号把时间截成半截，不如整段少显示一级。
  static String formatFriendlyTimestamp(
    DateTime? timestamp, {
    bool includeTime = true,
  }) {
    if (timestamp == null) {
      return '';
    }
    final t = slang.t;
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return t.common.justNow;
    } else if (difference.inHours < 1) {
      return t.common.minutesAgo(n: difference.inMinutes);
    } else if (difference.inDays < 1) {
      return t.common.hoursAgo(n: difference.inHours);
    } else if (difference.inDays < 7) {
      return t.common.daysAgo(n: difference.inDays);
    } else {
      final date =
          "${timestamp.year}-${_twoDigits(timestamp.month)}-${_twoDigits(timestamp.day)}";
      if (!includeTime) return date;
      return "$date ${_twoDigits(timestamp.hour)}:${_twoDigits(timestamp.minute)}";
    }
  }

  /// 辅助方法，将数字补齐为两位
  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  /// 使用「千/万/亿」这类四位一级计数单位的语言，值是 (千, 万, 亿) 三个词。
  /// 不在表里的语言走 k/M/B。
  static const Map<String, (String, String, String)> _eastAsianNumberUnits = {
    'zh': ('千', '万', '亿'),
    'ja': ('千', '万', '億'),
    'ko': ('천', '만', '억'),
  };

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

    // 东亚按「千 / 万 / 亿」四位一级分档，其余语言按三位一级的 k/M/B。
    // 日语和韩语原先落在 k/M/B 分支里，对当地用户是读不惯的。
    final eastAsianUnits =
        _eastAsianNumberUnits[slang.LocaleSettings.currentLocale.languageCode];
    if (eastAsianUnits != null) {
      final (thousand, tenThousand, hundredMillion) = eastAsianUnits;
      if (num < 1000) {
        return num.toString();
      } else if (num < 10000) {
        double result = num / 1000;
        return '${formatNumber(result)}$thousand';
      } else if (num < 100000000) {
        double result = num / 10000;
        return '${formatNumber(result)}$tenThousand';
      } else {
        double result = num / 100000000;
        return '${formatNumber(result)}$hundredMillion';
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

    if (GetPlatform.isAndroid) {
      try {
        // Android 优先使用外部存储目录（/storage/emulated/0/Android/data/包名/files）
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          directory = externalDir;
        } else {
          // 回退到内部存储目录
          directory = await getApplicationDocumentsDirectory();
        }
      } catch (e) {
        // 如果外部存储获取失败，使用内部存储
        LogUtils.e('获取外部存储失败，使用内部存储', tag: 'CommonUtils', error: e);
        directory = await getApplicationDocumentsDirectory();
      }
    } else {
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
  static Future<Directory> getInternalAppDirectory({
    String pathSuffix = '',
  }) async {
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
  static Future<Directory?> getExternalAppDirectory({
    String pathSuffix = '',
  }) async {
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

  /// 把设备语言映射成我们的语言代码（与 `lib/i18n/*.i18n.yaml` 的文件名一致）。
  ///
  /// ⛔ 这里原来拿 `languageCode` 去 match `case 'zh-HK'` / `case 'zh-TW'`，
  /// 而 `languageCode` 永远只会是 `'zh'`——那两个分支是死代码，所有中文设备
  /// 一律被判成简体。繁简要看 scriptCode / countryCode 才分得出来。
  static String getDeviceLocale() {
    final locale = PlatformDispatcher.instance.locale;
    if (locale.languageCode == 'zh') {
      final isTraditional =
          locale.scriptCode == 'Hant' ||
          const {'TW', 'HK', 'MO'}.contains(locale.countryCode);
      return isTraditional ? 'zh-TW' : 'zh-CN';
    }
    return locale.languageCode;
  }

  /// 把 slang 支持的所有语言（现在 12 门）的译文都加载进来，
  /// 供语言选择器「按目标 locale 取译文」用。
  ///
  /// 语言列表要显示的不是**当前**语言，而是每门语言自己的母语名与提示语——
  /// 那只能按目标 locale 取译文（`AppLocale.translations`）。而 slang 是按需加载
  /// 的（`lib/i18n/strings.g.dart` 里 `lazy: true`，非基准语言走 deferred 导入）：
  /// 没加载过的语言，`translations` 会**静默**回退成基准语言 en 的译文，母语名
  /// 整列都会变成 `English`，且不报任何错。所以读之前先把它们补齐。
  ///
  /// 幂等：已加载的会跳过，重复调用只剩几次 map 命中。
  /// slang 自带的复数解析器只覆盖 cs/de/en/es/fr/it/ja/pl/ru/sv/uk/vi。
  ///
  /// 本仓还支持 **zh-CN / zh-TW / ko / th / id**——这些语言的名词不随数量变形，
  /// 所以「永远取 other 形态」就是它们**正确**的规则。不注册的话，一旦用到任何
  /// 复数词条（`common.totalComments` 一类），slang 会在运行期直接抛异常。
  ///
  /// 幂等：重复调用只是重设同一份解析器。
  /// 语言选择器里的**显示顺序**。
  ///
  /// ⛔ 不能用 `AppLocale.values`：那是**文件名字母序**（en, de, es, fr, id, ja, ko, ru, th,
  /// vi, zh-CN, zh-TW），摆给用户看等于随机。这里按用户实际分布排：
  ///   1. 原先支持的 4 门（en / ja / zh-CN / zh-TW）——用户最多，放最上面；
  ///   2. 其余按二次元内容受众规模排：ko（韩）→ th（泰）→ id（印尼）→ vi（越）
  ///      → es（西语，拉美为主）→ ru（俄）→ fr（法）→ de（德）。
  ///
  /// 想换顺序就改这一个列表——语言选择器与首次启动向导共用它。
  /// 新增语言**不必改这里**：忘了登记也不会让那门语言在选择器里消失，
  /// 见 [orderedAppLocales]。
  static const List<slang.AppLocale> appLocaleDisplayOrder = [
    slang.AppLocale.en,
    slang.AppLocale.ja,
    slang.AppLocale.zhCn,
    slang.AppLocale.zhTw,
    slang.AppLocale.ko,
    slang.AppLocale.th,
    slang.AppLocale.id,
    slang.AppLocale.vi,
    slang.AppLocale.es,
    slang.AppLocale.ru,
    slang.AppLocale.fr,
    slang.AppLocale.de,
  ];

  /// 选择器实际用的顺序：登记过的按 [appLocaleDisplayOrder]，**没登记的补在末尾**。
  ///
  /// 这条兜底是故意的：将来加语言的人只要丢一份 yaml 就行，即使忘了更新顺序表，
  /// 那门语言也只是排最后，不会静默消失（`AppLocale.values` 里它一定存在）。
  static List<slang.AppLocale> get orderedAppLocales => [
    ...appLocaleDisplayOrder,
    ...slang.AppLocale.values.where(
      (locale) => !appLocaleDisplayOrder.contains(locale),
    ),
  ];

  static void ensurePluralResolvers() {
    for (final locale in const [
      slang.AppLocale.zhCn,
      slang.AppLocale.zhTw,
      slang.AppLocale.ko,
      slang.AppLocale.th,
      slang.AppLocale.id,
    ]) {
      slang.LocaleSettings.setPluralResolver(
        locale: locale,
        cardinalResolver:
            (
              num n, {
              String? zero,
              String? one,
              String? two,
              String? few,
              String? many,
              String? other,
            }) =>
                // 这几门语言的词条只提供 other 形态；万一缺了，退回 one / 空串，
                // 也绝不抛异常（宁可显示得糙一点，也不能把界面炸掉）。
                other ?? one ?? many ?? '',
      );
    }
  }

  static Future<void> ensureAllAppLocalesLoaded() async {
    try {
      await slang.LocaleSettings.instance.loadAllLocales();
      // 语言包都到位之后再注册复数解析器（注册要求目标语言已加载）。
      ensurePluralResolvers();
    } catch (e) {
      // 兜底：某个语言包加载失败不该让语言选择器整个打不开，退化成显示 en 文案。
      LogUtils.e('加载语言包失败', tag: 'CommonUtils', error: e);
    }
  }

  /// 获取视频链接的过期时间
  /// 链接示例：https://firefly.iwara.tv/download?filename=xxx.mp4&expires=1764679161&hash=xxx
  /// expires 参数是 Unix 时间戳（秒）
  static DateTime? getVideoLinkExpireTime(String videoLink) {
    try {
      final uri = Uri.parse(videoLink);
      final expiresStr = uri.queryParameters['expires'];
      if (expiresStr == null || expiresStr.isEmpty) {
        return null;
      }

      // 将 Unix 时间戳（秒）转换为 DateTime
      final expiresTimestamp = int.tryParse(expiresStr);
      if (expiresTimestamp == null) {
        return null;
      }

      // Unix 时间戳是秒，需要转换为毫秒
      return DateTime.fromMillisecondsSinceEpoch(expiresTimestamp * 1000);
    } catch (e) {
      LogUtils.e('解析视频链接过期时间失败', tag: 'CommonUtils', error: e);
      return null;
    }
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

  /// 日期在界面上的写法**跟语言走**，不是 12 门语言一个样。
  ///
  /// 沿用本仓既有做法（见 [_eastAsianNumberUnits]）：这种「排版格式表」直接放在
  /// Dart 里，不额外造 12 个 i18n key——它是排版规则，不是文案。
  ///
  /// ⛔ 故意只用数字格式、不用月份名：月份名要 12 门语言 × 12 个月 = 144 条新文案，
  /// 而这些日期出现在历史记录、下载任务这类紧凑位置，数字形式才是惯例。
  ///
  /// ⛔ en 保持 `yyyy-MM-dd`（本仓原行为，ISO 无歧义）：这次只让**其它语言**回到
  /// 各自的习惯写法，不改变英文界面的既有观感。
  static const Map<String, String> _datePatterns = {
    'en': 'yyyy-MM-dd',
    'zh-CN': 'yyyy年M月d日',
    'zh-TW': 'yyyy年M月d日',
    'ja': 'yyyy年M月d日',
    'ko': 'yyyy년 M월 d일',
    'ru': 'dd.MM.yyyy',
    'de': 'dd.MM.yyyy',
    'es': 'dd/MM/yyyy',
    'fr': 'dd/MM/yyyy',
    'vi': 'dd/MM/yyyy',
    'id': 'dd/MM/yyyy',
    'th': 'dd/MM/yyyy',
  };

  /// 按当前语言格式化日期（只到日，不含时间）。
  ///
  /// 未登记的语言回退 en 的 ISO 写法，不会出现「未知语言给空串」。
  static String formatDate(DateTime start) {
    final pattern =
        _datePatterns[slang.LocaleSettings.currentLocale.languageTag] ??
        _datePatterns['en']!;
    // 先替换长标记，再替换单字符标记（`MM` 必须在 `M` 之前、`dd` 在 `d` 之前）。
    return pattern
        .replaceAll('yyyy', start.year.toString().padLeft(4, '0'))
        .replaceAll('MM', _twoDigits(start.month))
        .replaceAll('dd', _twoDigits(start.day))
        .replaceAll('M', start.month.toString())
        .replaceAll('d', start.day.toString());
  }

  /// 获取当前平台名称
  static String getPlatformName() {
    if (Platform.isMacOS) {
      return 'macOS';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else {
      return 'Unknown';
    }
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
    final bool isDesktop =
        Platform.isMacOS || Platform.isWindows || Platform.isLinux;

    String withDesktopHint(String msg) =>
        isDesktop ? '$msg${slang.t.common.parseExceptionDestopHint}' : msg;

    String extractPort(String message) {
      final match = RegExp(r'Invalid port (\d+)').firstMatch(message);
      return match != null ? match.group(1) ?? '' : '';
    }

    if (error is DioException) {
      final String errorMessage =
          error.message ?? error.error?.toString() ?? '';
      final failure = ApiFailureResolver.resolve(error);
      final statusCode = failure.statusCode;

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return withDesktopHint(
            '${slang.t.errors.network.basicPrefix}${slang.t.errors.network.requestTimeout}',
          );
        case DioExceptionType.badResponse:
          switch (failure.kind) {
            case ApiFailureKind.privateVideo:
              return withDesktopHint(slang.t.videoDetail.privateVideo);
            case ApiFailureKind.forbidden:
            case ApiFailureKind.unauthorized:
            case ApiFailureKind.authRefreshFailed:
              return withDesktopHint(slang.t.errors.pleaseLoginAgain);
            case ApiFailureKind.cloudflareBlocked:
            case ApiFailureKind.serverError:
              return statusCode != null
                  ? withDesktopHint(
                      '${slang.t.errors.network.basicPrefix}${slang.t.errors.network.serverError} ($statusCode)',
                    )
                  : withDesktopHint(
                      '${slang.t.errors.network.basicPrefix}${slang.t.errors.network.unexpectedError}',
                    );
            default:
              return statusCode != null
                  ? withDesktopHint(
                      '${slang.t.errors.network.basicPrefix}${slang.t.errors.network.serverError} ($statusCode)',
                    )
                  : withDesktopHint(
                      '${slang.t.errors.network.basicPrefix}${slang.t.errors.network.unexpectedError}',
                    );
          }
        case DioExceptionType.cancel:
          // return withDesktopHint('请求已取消');
          return withDesktopHint(
            '${slang.t.errors.network.basicPrefix}${slang.t.errors.network.requestCanceled}',
          );
        case DioExceptionType.connectionError:
          if (errorMessage.contains('Invalid port')) {
            final port = extractPort(errorMessage);
            return port.isNotEmpty
                ? withDesktopHint(
                    '${slang.t.errors.network.basicPrefix}${slang.t.errors.network.invalidPort}: $port',
                  )
                : withDesktopHint(
                    '${slang.t.errors.network.basicPrefix}${slang.t.errors.network.proxyPortError}',
                  );
          }
          if (errorMessage.contains('Connection refused')) {
            return withDesktopHint(
              '${slang.t.errors.network.basicPrefix}${slang.t.errors.network.connectionRefused}',
            );
          }
          if (errorMessage.contains('Network is unreachable')) {
            return withDesktopHint(
              '${slang.t.errors.network.basicPrefix}${slang.t.errors.network.networkUnreachable}',
            );
          }
          if (errorMessage.contains('No route to host')) {
            return withDesktopHint(
              '${slang.t.errors.network.basicPrefix}${slang.t.errors.network.noRouteToHost}',
            );
          }
          return withDesktopHint(
            '${slang.t.errors.network.basicPrefix}${slang.t.errors.network.connectionFailed}',
          );
        case DioExceptionType.unknown:
          if (failure.kind == ApiFailureKind.authRefreshFailed) {
            return withDesktopHint(slang.t.errors.pleaseLoginAgain);
          }
          if (errorMessage.contains('Invalid port')) {
            final port = extractPort(errorMessage);
            return port.isNotEmpty
                ? withDesktopHint(
                    '${slang.t.errors.network.basicPrefix}${slang.t.errors.network.invalidPort}: $port',
                  )
                : withDesktopHint(
                    '${slang.t.errors.network.basicPrefix}${slang.t.errors.network.proxyPortError}',
                  );
          }
          if (errorMessage.contains('HandshakeException') ||
              errorMessage.contains('Connection terminated during handshake')) {
            return withDesktopHint(
              '${slang.t.errors.network.basicPrefix}${slang.t.errors.network.sslConnectionFailed}',
            );
          }
          // 兜底返回原始错误信息
          return errorMessage.isNotEmpty
              ? errorMessage
              : withDesktopHint(
                  '${slang.t.errors.network.basicPrefix}${slang.t.errors.network.unexpectedError}',
                );
        default:
          return errorMessage.isNotEmpty
              ? errorMessage
              : withDesktopHint(
                  '${slang.t.errors.network.basicPrefix}${slang.t.errors.network.unexpectedError}',
                );
      }
    }

    // 处理非DioException类型的错误
    final String errorString = error?.toString() ?? '';
    if (errorString.isNotEmpty && errorString != 'null') {
      // 检查是否为HandshakeException
      if (errorString.contains('HandshakeException') ||
          errorString.contains('Connection terminated during handshake')) {
        return withDesktopHint(
          '${slang.t.errors.network.basicPrefix}${slang.t.errors.network.sslConnectionFailed}',
        );
      }
      return errorString;
    }

    return slang.t.errors.errorWhileFetching;
  }
}
