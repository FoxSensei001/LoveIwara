// ignore_for_file: constant_identifier_names

import 'package:logger/logger.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:yaml/yaml.dart';

/// 简化的日志工具类，仅提供控制台输出
class LogUtils {
  static late Logger _logger;
  static const String _TAG = "i_iwara";

  // 控制是否初始化完成
  static bool _initialized = false;

  // 控制日志级别
  static bool _isProduction = false;

  // 初始化状态
  static bool get isInitialized => _initialized;
  
  // 初始化日志系统
  static Future<void> init({bool isProduction = false, bool enablePersistence = true}) async {
    _isProduction = isProduction;

    // 设置终端日志打印格式
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
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

  // 获取时间字符串
  static String _getTimeString() {
    return DateTime.now().toString().substring(0, 19);
  }

  // 记录调试日志
  static void d(String message, [String tag = _TAG]) {
    if (!_isProduction) {
      _logger.d("[${_getTimeString()}][$tag] $message");
    }
  }

  // 记录信息日志
  static void i(String message, [String tag = _TAG]) {
    _logger.i("[${_getTimeString()}][$tag] $message");
  }

  // 记录警告日志
  static void w(String message, [String tag = _TAG]) {
    _logger.w("[${_getTimeString()}][$tag] $message");
  }

  // 记录错误日志
  static void e(String message,
      {String tag = _TAG, Object? error, StackTrace? stackTrace, StackTrace? stack}) {

    // 处理错误和堆栈信息
    String? details;
    if (error != null || stackTrace != null || stack != null) {
      final buffer = StringBuffer();
      if (error != null) {
        buffer.writeln("错误详情: $error");
      }

      final trace = stackTrace ?? stack;
      if (trace != null) {
        buffer.writeln("堆栈跟踪: $trace");
      }

      details = buffer.toString();
    }

    _logger.e("[${_getTimeString()}][$tag] $message",
        stackTrace: null, error: details);
  }

  // 关闭日志（简化版本）
  static Future<void> close() async {
    // 简化版本，无需特殊处理
  }

  // 设置日志持久化状态（保留兼容性，但不执行任何操作）
  static void setPersistenceEnabled(bool enabled) {
    // 简化版本，不再支持持久化
    LogUtils.i('日志持久化功能已移除', '日志系统');
  }

  // 获取最近的日志内容（简化版本）
  static Future<String> getRecentLogs({int maxLines = 1000}) async {
    return "日志功能已简化，仅支持控制台输出";
  }

  // 简化的日志导出功能
  static Future<File> exportLogFileEnhanced({
    required String targetPath,
    DateTime? specificDate,
    bool allLogs = false,
    int daysRange = 7,
    String? searchText,
    List<String>? levels,
  }) async {
    try {
      final File targetFile = File(targetPath);

      await targetFile.writeAsString(
        "===== 导出时间: ${DateTime.now()} =====\n\n日志功能已简化，仅支持控制台输出"
      );
      return targetFile;
    } catch (e) {
      throw Exception("导出日志失败: $e");
    }
  }

  // 读取 pubspec.yaml 文件信息
  static Future<Map<String, dynamic>?> _readPubspecInfo() async {
    try {
      final pubspecFile = File('pubspec.yaml');
      if (await pubspecFile.exists()) {
        final content = await pubspecFile.readAsString();
        final yamlMap = loadYaml(content);
        return Map<String, dynamic>.from(yamlMap);
      }
    } catch (e) {
      if (kDebugMode) {
        print("读取 pubspec.yaml 失败: $e");
      }
    }
    return null;
  }

  // 记录设备和应用信息
  static Future<void> _logDeviceInfo() async {
    try {
      // 记录应用信息
      final pubspecInfo = await _readPubspecInfo();
      if (pubspecInfo != null) {
        final appName = pubspecInfo['name'] ?? 'Unknown';
        final version = pubspecInfo['version'] ?? 'Unknown';
        final description = pubspecInfo['description'] ?? 'Unknown';
        
        i("应用名称: $appName", "设备信息");
        i("应用描述: $description", "设备信息");
        i("版本: $version", "设备信息");
      } else {
        // 回退方案：使用硬编码信息
        i("应用名称: i_iwara", "设备信息");
        i("应用描述: A new Flutter project.", "设备信息");
        i("版本: ${CommonConstants.VERSION}", "设备信息");
      }
      
      // 记录设备信息
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      
      if (GetPlatform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        i("Android设备: ${androidInfo.brand} ${androidInfo.model}", "设备信息");
        i("Android版本: ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})", "设备信息");
      } else if (GetPlatform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        i("iOS设备: ${iosInfo.name} (${iosInfo.model})", "设备信息");
        i("iOS版本: ${iosInfo.systemVersion}", "设备信息");
      } else if (GetPlatform.isWindows) {
        WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
        i("Windows设备: ${windowsInfo.computerName}", "设备信息");
        i("Windows版本: ${windowsInfo.displayVersion} (${windowsInfo.buildNumber})", "设备信息");
      } else if (GetPlatform.isMacOS) {
        MacOsDeviceInfo macOsInfo = await deviceInfo.macOsInfo;
        i("macOS设备: ${macOsInfo.computerName}", "设备信息");
        i("macOS版本: ${macOsInfo.osRelease} (${macOsInfo.hostName})", "设备信息");
      } else if (GetPlatform.isLinux) {
        LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
        i("Linux设备: ${linuxInfo.name}", "设备信息");
        i("Linux版本: ${linuxInfo.version}", "设备信息");
      }
      
      // 记录内存信息
      i("内存总量: ${(Platform.resolvedExecutable.isEmpty ? 'Unknown' : '${(ProcessInfo.currentRss / 1024 / 1024).toStringAsFixed(2)} MB')}", "设备信息");
    } catch (e) {
      _logger.e("记录设备信息失败: ${e.toString()}");
    }
  }
}