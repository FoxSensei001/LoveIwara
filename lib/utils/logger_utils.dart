import 'package:logger/logger.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:i_iwara/app/services/log_service.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:yaml/yaml.dart';

/// 日志工具类，提供统一的日志接口
/// 
/// 内部使用 LogService 进行数据库存储
class LogUtils {
  static late Logger _logger;
  static const String _TAG = "i_iwara";
  
  // 控制是否初始化完成
  static bool _initialized = false;
  
  // 控制日志级别
  static bool _isProduction = false;
  
  // 内存中保存的最近日志，用于在未持久化时导出
  static final List<String> _memoryLogs = [];
  static const int _maxMemoryLogLines = 1000; // 减少内存日志行数限制
  
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
    
    // 设置日志级别
    // Logger.level = isProduction ? Level.info : Level.debug;
    
    try {
      _initialized = true;
      
      // 记录设备和应用信息
      await _logDeviceInfo();
    } catch (e) {
      _logger.e("初始化日志失败: $e");
    }
  }
  
  // 获取日志目录
  static Future<Directory> _getLogDirectory() async {
    if (GetPlatform.isDesktop) {
      return await getApplicationDocumentsDirectory();
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }
  
  // 获取日志目录路径
  static Future<String> get logDirectoryPath async {
    final dir = await _getLogDirectory();
    return path.join(dir.path, 'logs');
  }

  // 获取时间字符串
  static String _getTimeString() {
    return DateTime.now().toString().substring(0, 19);
  }
  
  // 写入到内存日志
  static void _addToMemoryLog(String logLine) {
    // 只在未注册LogService时存储大量内存日志
    if (!Get.isRegistered<LogService>()) {
      _memoryLogs.add(logLine);
      if (_memoryLogs.length > _maxMemoryLogLines) {
        _memoryLogs.removeAt(0); // 移除最旧的日志
      }
    } else if (_memoryLogs.length < 100) {
      // 如果已有LogService，只保留少量最新日志用于应急
      _memoryLogs.add(logLine);
      if (_memoryLogs.length > 100) {
        _memoryLogs.removeAt(0);
      }
    }
  }
  
  // 将日志写入数据库，无视日志级别过滤
  static Future<void> _writeToDatabase(
      LogLevel level, String message, String tag, {String? details}) async {
    try {
      if (Get.isRegistered<LogService>()) {
        await Get.find<LogService>().addLog(
          level: level,
          tag: tag,
          message: message,
          details: details,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("写入数据库日志失败: $e");
      }
    }
  }

  // 记录调试日志
  static void d(String message, [String tag = _TAG]) {
    if (!_isProduction) {
      _logger.d("[${_getTimeString()}][$tag] $message");
    }
    
    // 添加到内存日志
    final String logLine = "[${_getTimeString()}][DEBUG][$tag] $message";
    _addToMemoryLog(logLine);
    
    // 数据库写入
    unawaited(_writeToDatabase(LogLevel.debug, message, tag));
  }

  // 记录信息日志
  static void i(String message, [String tag = _TAG]) {
    _logger.i("[${_getTimeString()}][$tag] $message");
    
    // 添加到内存日志
    final String logLine = "[${_getTimeString()}][INFO][$tag] $message";
    _addToMemoryLog(logLine);
    
    // 数据库写入
    unawaited(_writeToDatabase(LogLevel.info, message, tag));
  }

  // 记录警告日志
  static void w(String message, [String tag = _TAG]) {
    _logger.w("[${_getTimeString()}][$tag] $message");
    
    // 添加到内存日志
    final String logLine = "[${_getTimeString()}][WARN][$tag] $message";
    _addToMemoryLog(logLine);
    
    // 数据库写入
    unawaited(_writeToDatabase(LogLevel.warn, message, tag));
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
    
    // 添加到内存日志
    final String logLine = "[${_getTimeString()}][ERROR][$tag] $message";
    _addToMemoryLog(logLine);
    
    if (details != null) {
      _addToMemoryLog("[${_getTimeString()}][ERROR][$tag] $details");
    }
    
    // 数据库同步写入 - 错误日志必须立即同步写入，不使用unawaited
    if (Get.isRegistered<LogService>()) {
      try {
        // 同步调用，确保写入完成
        Get.find<LogService>().addLogSync(
          level: LogLevel.error, 
          tag: tag, 
          message: message, 
          details: details
        );
      } catch (e) {
        if (kDebugMode) {
          print("错误日志同步写入失败: $e");
        }
      }
    } else {
      // 如果LogService未注册，记录错误信息以便后续处理
      _writeToDatabase(LogLevel.error, message, tag, details: details);
    }
  }
  
  // 关闭日志
  static Future<void> close() async {
    try {
      // 确保缓冲区日志写入数据库
      if (Get.isRegistered<LogService>()) {
        await Get.find<LogService>().flushBufferToDatabase();
        await Get.find<LogService>().close();
      }
    } catch (e) {
      if (kDebugMode) {
        print("关闭日志失败: $e");
      }
    }
  }
  
  // 设置日志持久化状态（仅为兼容性保留）
  static void setPersistenceEnabled(bool enabled) {
    // 在新版本中，持久化由LogService控制，此处直接更新状态
    CommonConstants.enableLogPersistence = enabled;
    
    if (Get.isRegistered<LogService>()) {
      LogUtils.i('日志持久化设置已更新: $enabled', '日志系统');
      
      // 强制刷新缓冲区确保之前的日志写入
      if (!enabled) {
        unawaited(Get.find<LogService>().flushBufferToDatabase());
      }
    }
  }
  
  // 获取最近的日志内容（从数据库中）
  static Future<String> getRecentLogs({int maxLines = 1000}) async {
    // 优先从数据库中读取
    if (Get.isRegistered<LogService>()) {
      try {
        final today = DateTime.now();
        final startDate = today.subtract(const Duration(days: 1)); // 最近一天的日志
        
        final logs = await Get.find<LogService>().queryLogs(
          startDate: startDate,
          limit: maxLines,
        );
        
        if (logs.isNotEmpty) {
          final buffer = StringBuffer();
          for (final log in logs) {
            buffer.writeln(log.toFormattedString());
          }
          return buffer.toString();
        }
      } catch (e) {
        // 如果读取数据库失败，回退到内存日志
        if (kDebugMode) {
          print("从数据库读取日志失败: $e");
        }
      }
    }
    
    // 如果数据库方式失败，从内存返回
    return _memoryLogs.join('\n');
  }
  
  // 增强的日志导出功能
  static Future<File> exportLogFileEnhanced({
    required String targetPath,
    DateTime? specificDate,
    bool allLogs = false,
    int daysRange = 7,
    String? searchText,
    List<LogLevel>? levels,
  }) async {
    if (Get.isRegistered<LogService>()) {
      try {
        DateTime? startDate;
        DateTime? endDate;
        
        if (specificDate != null) {
          // 指定日期模式
          startDate = DateTime(specificDate.year, specificDate.month, specificDate.day);
          endDate = DateTime(specificDate.year, specificDate.month, specificDate.day, 23, 59, 59);
        } else if (allLogs) {
          // 全部日志模式
          startDate = DateTime.now().subtract(Duration(days: daysRange));
        } else {
          // 默认为今天的日志
          final now = DateTime.now();
          startDate = DateTime(now.year, now.month, now.day);
        }
        
        return await Get.find<LogService>().exportLogsToFile(
          targetPath: targetPath,
          startDate: startDate,
          endDate: endDate,
          levels: levels,
          searchText: searchText,
          mergeAllDates: allLogs,
        );
      } catch (e) {
        // 如果数据库导出失败，记录错误
        if (kDebugMode) {
          print("使用数据库导出日志失败: $e");
        }
      }
    }
    
    // 如果上述方法失败，直接将内存中的日志导出到文件
    try {
      final File targetFile = File(targetPath);
      
      // 创建目标文件的目录
      final directory = Directory(path.dirname(targetPath));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      await targetFile.writeAsString(
        "===== 导出时间: ${DateTime.now()} =====\n\n${_memoryLogs.join('\n')}"
      );
      return targetFile;
    } catch (e) {
      try {
        final File targetFile = File(targetPath);
        final directory = Directory(path.dirname(targetPath));
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        
        await targetFile.writeAsString(
          "导出时发生错误，但仍尝试保存部分日志:\n${e.toString()}\n\n${_memoryLogs.join('\n')}"
        );
        return targetFile;
      } catch (finalError) {
        throw Exception("导出日志失败: $finalError (原始错误: $e)");
      }
    }
  }
  
  // 列出所有日志文件（使用数据库查询有效日期）
  static Future<List<DateTime>> getLogDates() async {
    if (Get.isRegistered<LogService>()) {
      try {
        return await Get.find<LogService>().getLogDates();
      } catch (e) {
        if (kDebugMode) {
          print("从数据库获取日志日期失败: $e");
        }
      }
    }
    
    // 如果数据库查询失败，返回空列表
    return [];
  }
  
  // 获取日志统计信息
  static Future<Map<String, int>> getLogStats() async {
    if (Get.isRegistered<LogService>()) {
      try {
        return await Get.find<LogService>().getLogStats();
      } catch (e) {
        if (kDebugMode) {
          print("获取日志统计信息失败: $e");
        }
      }
    }
    
    // 默认返回空统计
    return {
      'today': 0,
      'week': 0,
      'total': 0
    };
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