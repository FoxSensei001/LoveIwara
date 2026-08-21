// ignore_for_file: constant_identifier_names

import 'dart:developer' as developer;
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/app/services/logging/log_service.dart';
import 'package:i_iwara/app/services/logging/log_models.dart';

/// 日志工具类，提供控制台输出 + 文件持久化
class LogUtils {
  static late Logger _logger;
  static const String _TAG = "i_iwara";

  // 控制是否初始化完成
  static bool _initialized = false;

  // 控制日志级别
  static bool _isProduction = false;

  // 初始化状态
  static bool get isInitialized => _initialized;

  /// 缓存的持久化服务引用。
  ///
  /// 早先每条日志都要跑一遍 `Get.isRegistered<LogService>()` + `Get.find<LogService>()`：
  /// GetX 内部的 key 是 `Type.toString()`，AOT 下每次都会新分配一个字符串，再做两次
  /// map 查找，外面还套一层 try/catch——全在日志热路径上。LogService 是
  /// `permanent: true` 注册的，拿到一次就不会被换掉，缓存即可。
  static LogService? _cachedLogService;

  /// 由 main.dart 在 `Get.put(logService)` 之后显式挂载，省掉容器查找。
  static void attachLogService(LogService service) {
    _cachedLogService = service;
  }

  static LogService? get _logService {
    final cached = _cachedLogService;
    if (cached != null) {
      // close() 之后 isInitialized 变 false，此时不再回落到容器查找。
      return cached.isInitialized ? cached : null;
    }
    // 兜底：attachLogService 之前（启动早期）的少量日志仍走容器查找。
    // 只缓存已初始化的实例——缓存一个尚未 init 的实例会让上面那条分支
    // 永久返回 null，再也不会回来重查。
    try {
      if (Get.isRegistered<LogService>()) {
        final svc = Get.find<LogService>();
        if (svc.isInitialized) {
          _cachedLogService = svc;
          return svc;
        }
      }
    } catch (_) {}
    return null;
  }

  // 初始化日志系统
  static Future<void> init({
    bool isProduction = false,
    bool enablePersistence = true,
  }) async {
    _isProduction = isProduction;

    // 设置终端日志打印格式。
    //
    // ⚠️ methodCount / errorMethodCount 只要 > 0，PrettyPrinter 就会对**每一条**
    // 日志执行 `event.stackTrace ?? StackTrace.current`，然后把整条栈
    // toString + split + 4 个谓词过滤（见 pretty_printer.dart 的 log()/
    // formatStackTrace）。生产环境用的是 ProductionFilter，而 `Logger.level`
    // 默认是 Level.trace —— 等于一条都不挡，全仓 800+ 处 i/w/e 每次都要在
    // 调用线程上做一次 AOT 栈展开。生产环境必须置 0。
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: isProduction ? 0 : 2,
        // errorMethodCount 恒为 0：这条分支只在 event.error != null 时走，而
        // LogUtils.e() 传的 error 是已经拼好的 details 字符串（真堆栈就在里面）。
        // 让 PrettyPrinter 再抓一次 StackTrace.current 只会打印 8 帧
        // LogUtils/logger 自己的内部帧，纯噪音 + 纯开销。
        errorMethodCount: 0,
        lineLength: 120,
        // ANSI 转义在 logcat / 文件里只是噪音。
        colors: !isProduction,
        printEmojis: true,
        noBoxingByDefault: true,
      ),
      // 根据生产环境设置过滤器
      filter: isProduction ? ProductionFilter() : DevelopmentFilter(),
    );

    try {
      _initialized = true;

      // 记录设备和应用信息
      await _logDeviceInfo();
    } catch (e) {
      _logger.e("初始化日志失败: $e");
    }
  }

  /// 日志总开关（用户设置 `ConfigKey.LOGGING_ENABLED`，出厂默认关闭）关闭时，
  /// 整条链路都不该跑——控制台 PrettyPrinter、`developer.log`、LogService 一概
  /// 不碰。这个开关存在的理由就是「用户不需要日志，别让他付这份开销」，所以
  /// 只挡住写磁盘那一侧是名不副实的：真正贵的是控制台 printer。
  ///
  /// 作用范围刻意只覆盖 [d] / [i] / [w] —— 量大的是这几个。[e] 和
  /// [captureUnhandledException] 豁免：error 在健康应用里稀疏、开销可忽略，
  /// 却是唯一有诊断价值的部分，全挡掉等于默认配置下彻底失去可排障性。
  ///
  /// 只在生产（release/profile）生效。debug 构建不受此开关影响——那是开发者
  /// 自己的控制台，不是用户要承担的开销；而开关出厂即关，若一并挡掉会让本地
  /// 开发默认一条日志都看不到。
  static bool get _suppressedByUserSetting {
    if (!_isProduction) return false;
    final svc = _cachedLogService;
    // 服务就绪前（启动早期）照常记录：那段日志正是排查启动问题的关键，
    // 而且量小、只发生一次。
    // 服务已 close 时同样放行（fail-open）——否则一个死掉的服务对象会把日志
    // 永久静默，而且没有任何提示。
    if (svc == null || !svc.isInitialized) return false;
    return !svc.policy.enabled;
  }

  static String _two(int v) => v < 10 ? '0$v' : '$v';

  // 获取时间字符串。手写拼接，避开 DateTime.toString() 里毫秒/微秒的格式化
  // 和随后的 substring 二次分配。
  static String _getTimeString() {
    final n = DateTime.now();
    return '${n.year}-${_two(n.month)}-${_two(n.day)} '
        '${_two(n.hour)}:${_two(n.minute)}:${_two(n.second)}';
  }

  /// 额外写入 developer.log，确保 debug/profile 下 `flutter logs` 可见。
  ///
  /// release 里只镜像 warning 及以上：`developer.log` 的记录走的是 VM service
  /// 的 log stream，release 包上没有监听方，等于白跑一趟原生调用，还要多付一次
  /// `DateTime.now()`——而 debug/info 正是量最大的那部分。
  static void _mirrorToDeveloperLog(
    String message, {
    required String tag,
    required int level,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kIsWeb) return;
    if (kReleaseMode && level < 900) return;
    try {
      developer.log(
        message,
        name: tag,
        level: level,
        error: error,
        stackTrace: stackTrace,
      );
    } catch (_) {
      // 忽略镜像日志失败，避免影响主流程
    }
  }

  /// 记录调试日志。
  ///
  /// 生产环境直接返回：LogService 的 minLevel 在生产下是 info，debug 事件送进去
  /// 只会被等级过滤丢掉，白白付掉 developer.log + 容器查找 + 计数的开销
  /// （全仓有 360+ 处 d() 调用）。
  ///
  /// 注：诊断页「日志丢弃较多」的误报是另一回事，已在 diagnostics_page 侧
  /// 改成只看 `processorRateLimitedCount` 解决。加上总开关后 LogUtils 层已全部
  /// 早退，生产里 `droppedByMinLevel` / `droppedByDisabled` 本就恒为 0。
  static void d(String message, [String tag = _TAG]) {
    if (_isProduction) return;
    _logger.d("[${_getTimeString()}][$tag] $message");
    _mirrorToDeveloperLog(message, tag: tag, level: 500);
    _logService?.log(level: LogLevel.debug, message: message, tag: tag);
  }

  // 记录信息日志
  static void i(String message, [String tag = _TAG]) {
    if (_suppressedByUserSetting) return;
    _logger.i("[${_getTimeString()}][$tag] $message");
    _mirrorToDeveloperLog(message, tag: tag, level: 800);
    _logService?.log(level: LogLevel.info, message: message, tag: tag);
  }

  // 记录警告日志
  static void w(String message, [String tag = _TAG]) {
    if (_suppressedByUserSetting) return;
    _logger.w("[${_getTimeString()}][$tag] $message");
    _mirrorToDeveloperLog(message, tag: tag, level: 900);
    _logService?.log(level: LogLevel.warning, message: message, tag: tag);
  }

  // 记录错误日志
  static void e(
    String message, {
    String tag = _TAG,
    Object? error,
    StackTrace? stackTrace,
    StackTrace? stack,
  }) {
    // ⚠️ e() **刻意不受日志总开关约束**，与 [captureUnhandledException] 同级。
    //
    // 总开关要挡的是「稳态下持续产生的日志量」——那是 i()/w() 的量级；健康
    // 应用里 error 本来就稀疏，开销可忽略，而它恰恰是唯一有诊断价值的部分。
    // 开关出厂即关，若连 e() 一起挡掉，绝大多数用户的包里一条错误都不留，
    // 「让用户复现一次、看 logcat / 诊断弹窗」这条排障路径就断了。
    //
    // 落盘那一侧仍然受开关约束：LogService.log() 在 `!enabled` 时会自行返回。
    final trace = stackTrace ?? stack;

    // error / stackTrace 各自只字符串化一次，控制台和持久化共用结果。
    // AOT 下 StackTrace.toString() 要做符号化，早先这里转一次、LogService.log
    // 里再转一次，等于每条 error 白付一遍。
    final errorText = error?.toString();
    final traceText = trace?.toString();

    String? details;
    if (errorText != null || traceText != null) {
      final buffer = StringBuffer();
      if (errorText != null) {
        buffer.writeln("错误详情: $errorText");
      }
      if (traceText != null) {
        buffer.writeln("堆栈跟踪: $traceText");
      }
      details = buffer.toString();
    }

    _logger.e(
      "[${_getTimeString()}][$tag] $message",
      stackTrace: null,
      error: details,
    );
    _mirrorToDeveloperLog(
      message,
      tag: tag,
      level: 1000,
      error: error,
      stackTrace: trace,
    );

    _logService?.log(
      level: LogLevel.error,
      message: message,
      tag: tag,
      errorText: errorText,
      stackTraceText: traceText,
    );
  }

  /// 崩溃/未捕获异常路径。
  ///
  /// **刻意不受日志总开关约束**：这条路径一次崩溃只走一次，谈不上性能开销，
  /// 而挡掉它会让崩溃在 logcat 里也彻底消失、失去任何可诊断性。总开关要挡的是
  /// 「稳态下持续产生的日志量」，不是「出事时的那一条」。
  /// 落盘那一侧仍受开关约束——[LogService.captureUnhandledError] 在
  /// `!enabled` 时会自行返回。
  static void captureUnhandledException({
    required String source,
    required Object error,
    required StackTrace stackTrace,
    String message = '未捕获异常',
    String tag = '全局错误处理',
  }) {
    final details = StringBuffer()
      ..writeln('来源: $source')
      ..writeln('错误详情: $error')
      ..writeln('堆栈跟踪: $stackTrace');

    if (_initialized) {
      _logger.e(
        "[${_getTimeString()}][$tag] $message",
        stackTrace: null,
        error: details.toString(),
      );
    } else {
      debugPrint('[$tag] $message');
      debugPrint(details.toString());
    }

    final svc = _logService;
    if (svc != null) {
      svc.captureUnhandledError(
        source: source,
        message: message,
        error: error,
        stackTrace: stackTrace,
        tag: tag,
      );
    }
  }

  /// 同步标记本次为正常退出（删除崩溃标记）。退出路径应在任何慢清理之前
  /// 第一时间调用，避免清理超时/被杀时误报崩溃。详见
  /// [LogService.markCleanExitSync]。
  static void markCleanExitSync() {
    _logService?.markCleanExitSync();
  }

  // 关闭日志
  static Future<void> close() async {
    final svc = _logService;
    if (svc != null) {
      await svc.close();
    }
  }

  // 记录设备和应用信息
  static Future<void> _logDeviceInfo() async {
    try {
      // 记录应用信息（pubspec.yaml 不随发布产物打包，运行时不可读，
      // 统一使用编译期常量，避免无效 I/O 与误导性回退）。
      i("应用名称: ${CommonConstants.applicationName ?? 'i_iwara'}", "设备信息");
      i("版本: ${CommonConstants.VERSION}", "设备信息");

      // 记录设备信息
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (GetPlatform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        i("Android设备: ${androidInfo.brand} ${androidInfo.model}", "设备信息");
        i(
          "Android版本: ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})",
          "设备信息",
        );
      } else if (GetPlatform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        i("iOS设备: ${iosInfo.name} (${iosInfo.model})", "设备信息");
        i("iOS版本: ${iosInfo.systemVersion}", "设备信息");
      } else if (GetPlatform.isWindows) {
        WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
        i("Windows设备: ${windowsInfo.computerName}", "设备信息");
        i(
          "Windows版本: ${windowsInfo.displayVersion} (${windowsInfo.buildNumber})",
          "设备信息",
        );
      } else if (GetPlatform.isMacOS) {
        MacOsDeviceInfo macOsInfo = await deviceInfo.macOsInfo;
        i("macOS设备: ${macOsInfo.computerName}", "设备信息");
        i("macOS版本: ${macOsInfo.osRelease} (${macOsInfo.hostName})", "设备信息");
      } else if (GetPlatform.isLinux) {
        LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
        i("Linux设备: ${linuxInfo.name}", "设备信息");
        i("Linux版本: ${linuxInfo.version}", "设备信息");
      }

      // 记录内存信息。ProcessInfo.currentRss 在部分平台会抛，直接 try 掉即可；
      // 早先用 Platform.resolvedExecutable.isEmpty 判断它可不可读，两者毫无关系。
      String rss;
      try {
        rss = '${(ProcessInfo.currentRss / 1024 / 1024).toStringAsFixed(2)} MB';
      } catch (_) {
        rss = 'Unknown';
      }
      i("常驻内存(RSS): $rss", "设备信息");
    } catch (e) {
      _logger.e("记录设备信息失败: ${e.toString()}");
    }
  }
}
