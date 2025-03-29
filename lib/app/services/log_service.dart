import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:get/get.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:sqlite3/common.dart';
import 'package:i_iwara/common/constants.dart';
import 'dart:math' as Math;

/// 日志级别
enum LogLevel {
  debug,
  info,
  warn,
  error
}

/// 日志条目模型
class LogEntry {
  final int? id;
  final DateTime timestamp;
  final LogLevel level;
  final String? tag;
  final String message;
  final String? details;
  final String? sessionId;
  final DateTime? createdAt;

  LogEntry({
    this.id,
    required this.timestamp,
    required this.level,
    this.tag,
    required this.message,
    this.details,
    this.sessionId,
    this.createdAt,
  });

  // 将数据库行转换为日志条目
  factory LogEntry.fromJson(Map<String, dynamic> json) {
    // 转换字符串级别到枚举
    LogLevel logLevel;
    final levelStr = (json['level'] as String).toLowerCase();
    switch (levelStr) {
      case 'debug':
        logLevel = LogLevel.debug;
        break;
      case 'info':
        logLevel = LogLevel.info;
        break;
      case 'warn':
        logLevel = LogLevel.warn;
        break;
      case 'error':
        logLevel = LogLevel.error;
        break;
      default:
        logLevel = LogLevel.info; // 默认为info级别
    }
    
    return LogEntry(
      id: json['id'] as int?,
      timestamp: DateTime.fromMillisecondsSinceEpoch((json['timestamp'] as int) * 1000),
      level: logLevel,
      tag: json['tag'] as String?,
      message: json['message'] as String,
      details: json['details'] as String?,
      sessionId: json['session_id'] as String?,
      createdAt: json['created_at'] != null 
        ? DateTime.fromMillisecondsSinceEpoch((json['created_at'] as int) * 1000)
        : null,
    );
  }

  // 格式化为字符串
  String toFormattedString() {
    final timeStr = timestamp.toString().substring(0, 19);
    final levelStr = level.name.toUpperCase();
    final tagStr = tag != null ? "[$tag]" : "";
    final detailsStr = details != null ? "\n$details" : "";
    
    return "[$timeStr][$levelStr]$tagStr $message$detailsStr";
  }
  
  // 转换LogLevel为字符串
  static String levelToString(LogLevel level) => level.name;
}

/// 日志服务 - 负责日志的数据库操作
class LogService extends GetxService {
  // 数据库实例
  late final CommonDatabase _db;
  
  // 当前会话ID
  final String _sessionId = const Uuid().v4();
  
  // 内存缓冲区，用于批量插入
  final Queue<LogEntry> _buffer = Queue();
  
  // 缓冲区最大大小
  static const int _maxBufferSize = 100; // 增加缓冲区大小以提高写入效率
  
  // 定时写入器
  Timer? _flushTimer;
  
  // 批量写入锁
  final _bufferLock = RxBool(false);
  
  // 记录文件路径备份，用于兼容旧版本
  String? _legacyLogFilePath;
  
  // 上次清理时间
  DateTime? _lastCleanupTime;
  
  // 清理周期 单位：
  static const int _cleanupIntervalHours = 24;
  
  // 单例访问
  static LogService get to => Get.find();
  
  // 预编译的SQL语句
  late final dynamic _insertLogStmt;
  
  // 初始化
  Future<LogService> init() async {
    try {
      // 使用独立的日志数据库
      _db = await DatabaseService().initLogDatabase();
      
      // 预编译SQL语句以提高性能
      _insertLogStmt = _db.prepare('''
        INSERT INTO app_logs 
        (timestamp, level, tag, message, details, session_id)
        VALUES (?, ?, ?, ?, ?, ?)
      ''');
      
      // 创建遗留日志目录（为了兼容性）
      await _initLegacyLogFile();
      
      // 启动定时写入器
      _startFlushTimer();
      
      // 清理过期日志和检查数据库大小
      unawaited(_cleanupOldLogs());
      unawaited(_checkAndCleanupBySize());
      
      // 添加一条初始化日志，确保至少有一条记录
      await addLog(
        level: LogLevel.info,
        tag: "系统",
        message: "日志系统初始化完成 - 使用独立数据库",
      );
      
      // 立即刷新缓冲区确保写入
      await _flushBuffer();
      
      return this;
    } catch (e) {
      if (kDebugMode) {
        print("日志系统初始化失败: $e");
      }
      rethrow;
    }
  }
  
  // 创建遗留日志文件目录（为了向后兼容）
  Future<void> _initLegacyLogFile() async {
    try {
      final Directory appDocDir = await _getLegacyLogDirectory();
      final String logDirPath = path.join(appDocDir.path, 'logs');
      
      // 确保日志目录存在
      final Directory logDir = Directory(logDirPath);
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }
      
      // 创建日志文件，使用日期作为文件名
      final String today = DateTime.now().toString().split(' ')[0];
      final String logFileName = 'iwara_log_$today.txt';
      _legacyLogFilePath = path.join(logDirPath, logFileName);
    } catch (e) {
      if (kDebugMode) {
        print("初始化遗留日志文件失败: $e");
      }
    }
  }
  
  // 获取遗留日志目录
  Future<Directory> _getLegacyLogDirectory() async {
    if (GetPlatform.isDesktop) {
      // 桌面端使用应用程序数据目录
      return await getApplicationDocumentsDirectory();
    } else {
      // 移动端使用应用程序文档目录
      return await getApplicationDocumentsDirectory();
    }
  }
  
  // 启动定时写入器
  void _startFlushTimer() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(const Duration(seconds: 10), (_) => _flushBuffer());
  }
  
  // 清理过期日志
  Future<void> _cleanupOldLogs() async {
    // 检查是否需要清理（每24小时清理一次）
    final now = DateTime.now();
    if (_lastCleanupTime != null && 
        now.difference(_lastCleanupTime!).inHours < _cleanupIntervalHours) {
      return;
    }
    
    try {
      // 使用配置或常量的保留日志天数
      final retentionDays = CommonConstants.logRetentionDays;
      
      // 计算截止日期
      final cutoffDate = now.subtract(Duration(days: retentionDays));
      final cutoffTimestamp = cutoffDate.millisecondsSinceEpoch ~/ 1000;
      
      // 获取将被删除的日志数量
      final countResult = _db.prepare('''
        SELECT COUNT(*) as count FROM app_logs 
        WHERE timestamp < ?
      ''').select([cutoffTimestamp]);
      
      final count = countResult.isEmpty ? 0 : (countResult.first['count'] as int? ?? 0);
      
      // 只有当有日志需要清理时才执行清理
      if (count > 0) {
        // 删除过期日志
        _db.prepare('''
          DELETE FROM app_logs 
          WHERE timestamp < ?
        ''').execute([cutoffTimestamp]);
        
        // 添加清理日志
        await addLog(
          level: LogLevel.info,
          tag: "日志系统",
          message: "自动清理了 $count 条超过 $retentionDays 天的日志记录",
        );
      }
      
      _lastCleanupTime = now;
    } catch (e) {
      if (kDebugMode) {
        print("清理过期日志失败: $e");
      }
    }
  }
  
  // 检查数据库大小并清理
  Future<void> _checkAndCleanupBySize() async {
    try {
      // 获取当前数据库大小
      final currentSize = await getLogDatabaseSize();
      
      // 获取最大允许的数据库大小
      final maxSize = CommonConstants.maxLogDatabaseSize;
      
      // 如果当前大小小于最大大小的90%，不需要清理
      if (currentSize < maxSize * 0.9) {
        return;
      }
      
      // 查询日志表中最早和最晚的时间戳，计算日志总时间跨度
      final timeRangeResult = _db.prepare('''
        SELECT 
          MIN(timestamp) as min_time,
          MAX(timestamp) as max_time
        FROM app_logs
      ''').select();
      
      if (timeRangeResult.isEmpty) return;
      
      final minTime = timeRangeResult.first['min_time'] as int? ?? 0;
      final maxTime = timeRangeResult.first['max_time'] as int? ?? 0;
      
      // 如果最早和最晚的时间戳相同或没有数据，则无法基于时间删除
      if (minTime == 0 || maxTime == 0 || minTime >= maxTime) {
        // 此时可以考虑删除日志表中的前N条记录
        await _deleteOldestRecords(currentSize, maxSize);
        return;
      }
      
      // 计算时间跨度（秒）
      final timeSpan = maxTime - minTime;
      
      // 计算要保留的时间比例（目标是减少至少20%的数据）
      final targetRetentionRatio = 0.8;
      
      // 计算新的截止时间戳（保留最近的80%数据）
      final newCutoffTimestamp = minTime + (timeSpan * (1 - targetRetentionRatio)).toInt();
      
      // 获取将被删除的日志数量
      final countResult = _db.prepare('''
        SELECT COUNT(*) as count FROM app_logs 
        WHERE timestamp < ?
      ''').select([newCutoffTimestamp]);
      
      final count = countResult.isEmpty ? 0 : (countResult.first['count'] as int? ?? 0);
      
      // 只有当有日志需要清理时才执行清理
      if (count > 0) {
        // 删除过期日志
        _db.prepare('''
          DELETE FROM app_logs 
          WHERE timestamp < ?
        ''').execute([newCutoffTimestamp]);
        
        // 添加清理日志
        final sizeBeforeMB = (currentSize / (1024 * 1024)).toStringAsFixed(2);
        await addLog(
          level: LogLevel.info,
          tag: "日志系统",
          message: "数据库大小达到 $sizeBeforeMB MB，接近上限 ${maxSize / (1024 * 1024)} MB，已清理 $count 条较早的日志记录",
        );
        
        // 对数据库执行VACUUM操作，释放空间
        _db.execute('VACUUM');
      }
    } catch (e) {
      if (kDebugMode) {
        print("基于大小清理日志失败: $e");
      }
    }
  }
  
  // 删除最早的N条记录
  Future<void> _deleteOldestRecords(int currentSize, int maxSize) async {
    try {
      // 计算需要删除的记录比例（目标是减少至少20%的数据）
      final targetDeleteRatio = 0.2;
      
      // 计算数据库中的总记录数
      final countResult = _db.prepare('SELECT COUNT(*) as count FROM app_logs').select();
      final totalCount = countResult.isEmpty ? 0 : (countResult.first['count'] as int? ?? 0);
      
      // 如果没有记录，则返回
      if (totalCount == 0) return;
      
      // 计算需要删除的记录数量
      final recordsToDelete = (totalCount * targetDeleteRatio).ceil();
      
      // 获取要删除的记录ID
      final idsToDeleteResult = _db.prepare('''
        SELECT id FROM app_logs 
        ORDER BY timestamp ASC 
        LIMIT ?
      ''').select([recordsToDelete]);
      
      if (idsToDeleteResult.isEmpty) return;
      
      // 提取ID列表
      final idsToDelete = idsToDeleteResult.map((row) => row['id'] as int).toList();
      
      // 批量删除记录（每批次1000条）
      final batchSize = 1000;
      for (var i = 0; i < idsToDelete.length; i += batchSize) {
        final end = (i + batchSize < idsToDelete.length) ? i + batchSize : idsToDelete.length;
        final batch = idsToDelete.sublist(i, end);
        
        // 构建IN子句的参数
        final placeholders = List.filled(batch.length, '?').join(',');
        
        // 执行删除
        _db.prepare('''
          DELETE FROM app_logs 
          WHERE id IN ($placeholders)
        ''').execute(batch);
      }
      
      // 添加清理日志
      final sizeBeforeMB = (currentSize / (1024 * 1024)).toStringAsFixed(2);
      await addLog(
        level: LogLevel.info,
        tag: "日志系统",
        message: "数据库大小达到 $sizeBeforeMB MB，接近上限 ${maxSize / (1024 * 1024)} MB，已清理 $recordsToDelete 条最早的日志记录",
      );
      
      // 对数据库执行VACUUM操作，释放空间
      _db.execute('VACUUM');
    } catch (e) {
      if (kDebugMode) {
        print("删除最早的记录失败: $e");
      }
    }
  }
  
  // 添加日志时检查数据库大小
  Future<void> _checkDatabaseSizeBeforeAdd() async {
    try {
      // 每100条日志检查一次数据库大小
      if (_db.prepare('SELECT MAX(id) as max_id FROM app_logs').select().first['max_id'] % 100 != 0) {
        return;
      }
      
      await _checkAndCleanupBySize();
    } catch (e) {
      // 仅在debug模式下打印错误，避免影响正常日志流程
      if (kDebugMode) {
        print("检查数据库大小失败: $e");
      }
    }
  }
  
  // 添加日志
  Future<void> addLog({
    required LogLevel level,
    String? tag,
    required String message,
    String? details,
  }) async {
    try {
      // 检查是否启用日志持久化
      if (!CommonConstants.enableLogPersistence && level != LogLevel.error) {
        // 只有错误日志始终保存，其他日志根据配置决定
        return;
      }
      
      final now = DateTime.now();
      
      // 创建日志条目
      final entry = LogEntry(
        timestamp: now,
        level: level,
        tag: tag,
        message: message,
        details: details,
        sessionId: _sessionId,
      );
      
      // 添加到缓冲区
      _buffer.add(entry);
      
      // 如果缓冲区达到最大大小，立即写入
      if (_buffer.length >= _maxBufferSize) {
        unawaited(_flushBuffer());
      }
      
      // 周期性检查数据库大小
      if (level == LogLevel.info) {
        unawaited(_checkDatabaseSizeBeforeAdd());
      }
      
      // 同时写入到遗留日志文件（如果有）
      if (_legacyLogFilePath != null) {
        unawaited(_writeToLegacyLog(entry));
      }
    } catch (e) {
      // 如果添加日志过程中发生错误，不要抛出异常，而是在控制台打印错误
      if (kDebugMode) {
        print("添加日志失败: $e");
        print("尝试添加的日志信息: $message");
      }
    }
  }
  
  // 写入到遗留日志文件
  Future<void> _writeToLegacyLog(LogEntry entry) async {
    try {
      final file = File(_legacyLogFilePath!);
      final logLine = entry.toFormattedString();
      await file.writeAsString('$logLine\n', mode: FileMode.append);
    } catch (_) {
      // 忽略文件写入错误
    }
  }
  
  // 刷新缓冲区到数据库
  Future<void> _flushBuffer() async {
    if (_buffer.isEmpty || _bufferLock.value) return;
    
    _bufferLock.value = true;
    try {
      // 开始事务
      _db.execute('BEGIN TRANSACTION');
      
      try {
        final batch = List.from(_buffer);
        _buffer.clear();
        
        for (final entry in batch) {
          _insertLogStmt.execute([
            entry.timestamp.millisecondsSinceEpoch ~/ 1000,
            LogEntry.levelToString(entry.level),
            entry.tag,
            entry.message,
            entry.details,
            entry.sessionId,
          ]);
        }
        
        // 提交事务
        _db.execute('COMMIT');
      } catch (e) {
        // 如果出错，回滚事务
        _db.execute('ROLLBACK');
        if (kDebugMode) {
          print("写入日志到数据库失败: $e");
        }
        
        // 重新将失败的日志添加回缓冲区
        // 注意：这可能导致日志重复写入，但比日志丢失要好
        // 仅在缓冲区为空时添加回缓冲区，避免无限循环
        if (_buffer.isEmpty) {
          final failedBatch = _db.prepare('SELECT MAX(id) as max_id FROM app_logs').select();
          final lastId = failedBatch.isEmpty ? 0 : (failedBatch.first['max_id'] as int? ?? 0);
          
          // 查询最近一分钟内写入的日志数量
          final now = DateTime.now();
          final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
          final recentLogsCount = _db.prepare('''
            SELECT COUNT(*) as count FROM app_logs 
            WHERE timestamp >= ?
          ''').select([oneMinuteAgo.millisecondsSinceEpoch ~/ 1000]);
          
          // 如果最近一分钟内写入超过100条日志，说明系统可能处于高负载状态
          // 此时不再尝试重写失败的日志，以避免进一步增加系统负担
          final count = recentLogsCount.isEmpty ? 0 : (recentLogsCount.first['count'] as int? ?? 0);
          if (count < 100) {
            // 记录一条错误日志，说明有日志写入失败
            final errorEntry = LogEntry(
              timestamp: now,
              level: LogLevel.error,
              tag: "日志系统",
              message: "写入日志到数据库失败",
              details: "错误详情: $e",
              sessionId: _sessionId,
            );
            _buffer.add(errorEntry);
          }
        }
      }
    } finally {
      _bufferLock.value = false;
    }
  }
  
  // 公共方法：强制刷新缓冲区到数据库
  Future<void> flushBufferToDatabase() async {
    return _flushBuffer();
  }
  
  // 公共方法：强制检查并清理日志大小
  Future<bool> forceCheckAndCleanupBySize() async {
    try {
      // 获取当前数据库大小
      final currentSize = await getLogDatabaseSize();
      
      // 获取最大允许的数据库大小
      final maxSize = CommonConstants.maxLogDatabaseSize;
      
      // 如果当前大小已经超过最大大小，需要立即清理
      if (currentSize > maxSize) {
        // 计算需要删除的比例，确保能将大小降低到限制以下
        final targetDeleteRatio = Math.max(0.3, 1 - (maxSize / currentSize));
        
        // 计算数据库中的总记录数
        final countResult = _db.prepare('SELECT COUNT(*) as count FROM app_logs').select();
        final totalCount = countResult.isEmpty ? 0 : (countResult.first['count'] as int? ?? 0);
        
        // 如果没有记录，则返回
        if (totalCount == 0) return false;
        
        // 计算需要删除的记录数量
        final recordsToDelete = (totalCount * targetDeleteRatio).ceil();
        
        // 获取要删除的记录ID
        final idsToDeleteResult = _db.prepare('''
          SELECT id FROM app_logs 
          ORDER BY timestamp ASC 
          LIMIT ?
        ''').select([recordsToDelete]);
        
        if (idsToDeleteResult.isEmpty) return false;
        
        // 提取ID列表
        final idsToDelete = idsToDeleteResult.map((row) => row['id'] as int).toList();
        
        // 批量删除记录（每批次1000条）
        final batchSize = 1000;
        for (var i = 0; i < idsToDelete.length; i += batchSize) {
          final end = (i + batchSize < idsToDelete.length) ? i + batchSize : idsToDelete.length;
          final batch = idsToDelete.sublist(i, end);
          
          // 构建IN子句的参数
          final placeholders = List.filled(batch.length, '?').join(',');
          
          // 执行删除
          _db.prepare('''
            DELETE FROM app_logs 
            WHERE id IN ($placeholders)
          ''').execute(batch);
        }
        
        // 添加清理日志
        final sizeBeforeMB = (currentSize / (1024 * 1024)).toStringAsFixed(2);
        await addLog(
          level: LogLevel.info,
          tag: "日志系统",
          message: "已降低日志大小上限至 ${maxSize / (1024 * 1024)} MB，当前大小 $sizeBeforeMB MB，已自动清理 $recordsToDelete 条最早的日志记录",
        );
        
        // 对数据库执行VACUUM操作，释放空间
        _db.execute('VACUUM');
        
        return true;
      } else {
        // 如果当前大小还没有超过限制，使用普通的清理逻辑
        await _checkAndCleanupBySize();
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print("强制清理日志失败: $e");
      }
      return false;
    }
  }
  
  // 查询日志
  Future<List<LogEntry>> queryLogs({
    DateTime? startDate,
    DateTime? endDate,
    List<LogLevel>? levels,
    String? tag,
    String? searchText,
    String? sessionId,
    int limit = 1000,
    int offset = 0,
  }) async {
    try {
      final List<dynamic> params = [];
      final List<String> conditions = [];
      
      // 添加时间范围条件
      if (startDate != null) {
        conditions.add('timestamp >= ?');
        params.add(startDate.millisecondsSinceEpoch ~/ 1000);
      }
      
      if (endDate != null) {
        // 确保是一天的结束时间
        final endOfDay = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
        );
        conditions.add('timestamp <= ?');
        params.add(endOfDay.millisecondsSinceEpoch ~/ 1000);
      }
      
      // 添加日志级别条件
      if (levels != null && levels.isNotEmpty) {
        final levelStrings = levels.map((l) => LogEntry.levelToString(l)).toList();
        final placeholders = List.generate(levelStrings.length, (index) => '?').join(',');
        conditions.add('level IN ($placeholders)');
        params.addAll(levelStrings);
      }
      
      // 添加标签条件
      if (tag != null && tag.isNotEmpty) {
        conditions.add('tag = ?');
        params.add(tag);
      }
      
      // 添加搜索文本条件
      if (searchText != null && searchText.isNotEmpty) {
        conditions.add('(message LIKE ? OR details LIKE ?)');
        params.add('%$searchText%');
        params.add('%$searchText%');
      }
      
      // 添加会话ID条件
      if (sessionId != null && sessionId.isNotEmpty) {
        conditions.add('session_id = ?');
        params.add(sessionId);
      }
      
      // 构建SQL查询
      String sql = '''
        SELECT * FROM app_logs
        ${conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : ''}
        ORDER BY timestamp DESC
        LIMIT ? OFFSET ?
      ''';
      params.addAll([limit, offset]);
      
      // 执行查询
      final results = _db.prepare(sql).select(params);
      
      // 转换结果
      return results.map((row) => LogEntry.fromJson(row)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("查询日志失败: $e");
      }
      return [];
    }
  }
  
  // 获取日志日期列表
  Future<List<DateTime>> getLogDates() async {
    try {
      final sql = '''
        SELECT DISTINCT 
          date(timestamp, 'unixepoch', 'localtime') as log_date
        FROM app_logs
        ORDER BY log_date DESC
      ''';
      
      final results = _db.prepare(sql).select();
      
      // 检查是否有结果
      if (results.isEmpty) {
        // 检查是否有今天的记录，如果没有，添加一条
        await addLog(
          level: LogLevel.info,
          tag: "系统",
          message: "获取日志日期列表",
        );
        
        // 刷新缓冲区确保写入
        await _flushBuffer();
        
        // 再次执行查询
        final retryResults = _db.prepare(sql).select();
        if (retryResults.isEmpty) {
          return [];
        }
        
        return retryResults.map((row) {
          final dateStr = row['log_date'] as String;
          return DateTime.parse(dateStr);
        }).toList();
      }
      
      return results.map((row) {
        final dateStr = row['log_date'] as String;
        return DateTime.parse(dateStr);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print("获取日志日期列表失败: $e");
      }
      return [];
    }
  }
  
  // 获取当前会话ID
  String get currentSessionId => _sessionId;
  
  // 导出日志到文件
  Future<File> exportLogsToFile({
    required String targetPath,
    DateTime? startDate,
    DateTime? endDate,
    List<LogLevel>? levels,
    String? tag,
    String? searchText,
    String? sessionId,
    bool mergeAllDates = false,
  }) async {
    try {
      // 确保所有缓冲区日志写入
      await _flushBuffer();
      
      // 获取日志数据
      final logs = await queryLogs(
        startDate: startDate,
        endDate: endDate,
        levels: levels,
        tag: tag,
        searchText: searchText,
        sessionId: sessionId,
        limit: 50000, // 设置较大的限制
      );
      
      if (logs.isEmpty) {
        throw Exception("未找到符合条件的日志");
      }
      
      // 创建目标文件
      final targetFile = File(targetPath);
      final targetDir = Directory(path.dirname(targetPath));
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }
      
      // 准备导出内容
      final buffer = StringBuffer();
      buffer.writeln("===== 导出时间: ${DateTime.now()} =====");
      
      if (!mergeAllDates && (startDate != null || endDate != null)) {
        buffer.write("===== 日期范围: ");
        if (startDate != null) {
          buffer.write("${startDate.toString().split(' ')[0]} ");
        }
        buffer.write("至 ");
        if (endDate != null) {
          buffer.write("${endDate.toString().split(' ')[0]}");
        } else {
          buffer.write("今");
        }
        buffer.writeln(" =====");
      }
      
      buffer.writeln("===== 总日志数: ${logs.length} =====");
      buffer.writeln();
      
      // 批量写入日志，以提高性能
      final chunkSize = 1000;
      for (var i = 0; i < logs.length; i += chunkSize) {
        final end = (i + chunkSize < logs.length) ? i + chunkSize : logs.length;
        final chunk = logs.sublist(i, end);
        
        for (final log in chunk) {
          buffer.writeln(log.toFormattedString());
        }
        
        // 每处理一个块就写入一次文件，避免内存占用过大
        if (i == 0) {
          await targetFile.writeAsString(buffer.toString());
          buffer.clear();
        } else {
          await targetFile.writeAsString(buffer.toString(), mode: FileMode.append);
          buffer.clear();
        }
      }
      
      return targetFile;
    } catch (e) {
      if (kDebugMode) {
        print("导出日志失败: $e");
      }
      rethrow;
    }
  }
  
  // 清空日志数据
  Future<void> clearLogs({
    DateTime? beforeDate,
    List<LogLevel>? levels,
    String? tag,
  }) async {
    try {
      // 确保所有缓冲区日志写入
      await _flushBuffer();
      
      final List<dynamic> params = [];
      final List<String> conditions = [];
      
      if (beforeDate != null) {
        conditions.add('timestamp < ?');
        params.add(beforeDate.millisecondsSinceEpoch ~/ 1000);
      }
      
      if (levels != null && levels.isNotEmpty) {
        final levelStrings = levels.map((l) => LogEntry.levelToString(l)).toList();
        final placeholders = List.generate(levelStrings.length, (index) => '?').join(',');
        conditions.add('level IN ($placeholders)');
        params.addAll(levelStrings);
      }
      
      if (tag != null && tag.isNotEmpty) {
        conditions.add('tag = ?');
        params.add(tag);
      }
      
      String sql = '''
        DELETE FROM app_logs
        ${conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : ''}
      ''';
      
      // 获取将被删除的日志数量
      String countSql = '''
        SELECT COUNT(*) as count FROM app_logs
        ${conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : ''}
      ''';
      
      final countResult = _db.prepare(countSql).select(params);
      final count = countResult.isEmpty ? 0 : (countResult.first['count'] as int? ?? 0);
      
      // 执行删除
      _db.prepare(sql).execute(params);
      
      // 清空内存缓冲区
      _buffer.clear();
      
      // 记录一条清理日志
      await addLog(
        level: LogLevel.info,
        tag: "系统",
        message: "日志清理操作完成，已清理 $count 条日志记录",
      );
      
      // 确保立即写入
      await _flushBuffer();
    } catch (e) {
      if (kDebugMode) {
        print("清空日志数据失败: $e");
      }
    }
  }
  
  // 获取日志统计信息
  Future<Map<String, int>> getLogStats() async {
    try {
      // 强制刷新缓冲区确保所有日志已写入数据库
      await _flushBuffer();
      
      // 获取当前日期和7天前的日期
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastWeek = today.subtract(const Duration(days: 7));

      // 转换为Unix时间戳
      final todayTimestamp = today.millisecondsSinceEpoch ~/ 1000;
      final lastWeekTimestamp = lastWeek.millisecondsSinceEpoch ~/ 1000;

      // 单次查询获取所有统计信息
      final stats = _db.prepare('''
        SELECT
          (SELECT COUNT(*) FROM app_logs WHERE timestamp >= ?) as today_count,
          (SELECT COUNT(*) FROM app_logs WHERE timestamp >= ?) as week_count,
          (SELECT COUNT(*) FROM app_logs) as total_count
      ''').select([todayTimestamp, lastWeekTimestamp]);
      
      if (stats.isEmpty) {
        return {
          'today': 0,
          'week': 0,
          'total': 0,
        };
      }
      
      return {
        'today': stats.first['today_count'] as int? ?? 0,
        'week': stats.first['week_count'] as int? ?? 0,
        'total': stats.first['total_count'] as int? ?? 0,
      };
    } catch (e) {
      if (kDebugMode) {
        print('获取日志统计失败: $e');
      }
      return {
        'today': 0,
        'week': 0,
        'total': 0,
      };
    }
  }
  
  // 关闭服务，确保所有日志都写入
  Future<void> close() async {
    // 取消定时器
    _flushTimer?.cancel();
    _flushTimer = null;
    
    // 刷新所有未写入的日志
    await _flushBuffer();
    
    // 释放预编译语句
    _insertLogStmt.dispose();
  }
  
  // 获取日志数据库大小
  Future<int> getLogDatabaseSize() async {
    try {
      // 确保所有缓冲区日志写入
      await _flushBuffer();
      
      // 获取日志表的行数和平均大小
      final sizeResult = _db.prepare('''
        SELECT
          COUNT(*) as row_count,
          AVG(LENGTH(message) + LENGTH(IFNULL(details,'')) + LENGTH(IFNULL(tag,''))) as avg_size
        FROM app_logs
      ''').select();
      
      if (sizeResult.isEmpty) return 0;
      
      final rowCount = sizeResult.first['row_count'] as int? ?? 0;
      final avgSize = sizeResult.first['avg_size'] as double? ?? 0;
      
      return (rowCount * avgSize).toInt();
    } catch (e) {
      if (kDebugMode) {
        print("获取日志数据库大小失败: $e");
      }
      return 0;
    }
  }
  
  // 获取日志记录总数
  Future<int> getLogCount() async {
    try {
      // 确保所有缓冲区日志写入
      await _flushBuffer();
      
      final result = _db.prepare('SELECT COUNT(*) as count FROM app_logs').select();
      return result.isEmpty ? 0 : (result.first['count'] as int? ?? 0);
    } catch (e) {
      if (kDebugMode) {
        print("获取日志记录总数失败: $e");
      }
      return 0;
    }
  }
  
  // 获取数据库目录路径
  Future<String> getDatabaseDirectory() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final appDir = path.join(documentsDirectory.path, CommonConstants.applicationName ?? 'i_iwara');
      return appDir;
    } catch (e) {
      if (kDebugMode) {
        print("获取数据库目录路径失败: $e");
      }
      throw Exception("获取数据库目录路径失败: $e");
    }
  }
  
  // 获取日志数据库实例，用于执行原始SQL命令
  CommonDatabase get database => _db;
  
  // 执行VACUUM操作，收缩数据库文件
  Future<void> vacuum() async {
    try {
      // 确保所有缓冲区日志写入
      await _flushBuffer();
      
      // 执行VACUUM操作
      _db.execute('VACUUM');
      
      // 记录日志
      await addLog(
        level: LogLevel.info,
        tag: "系统",
        message: "执行VACUUM操作完成，已优化数据库存储空间",
      );
    } catch (e) {
      if (kDebugMode) {
        print("执行VACUUM操作失败: $e");
      }
    }
  }
} 