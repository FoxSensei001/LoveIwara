import 'dart:io';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart' show CommonDatabase;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:i_iwara/common/constants.dart';

import 'migration_manager.dart';
import 'sqlite3/sqlite3.dart' show openSqliteDb;

/// 数据库异常
class DatabaseException implements Exception {
  final String message;

  DatabaseException(this.message);

  @override
  String toString() => '数据库异常: $message';
}

/// 数据库服务
class DatabaseService {
  // 单例模式
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  late CommonDatabase _db;
  final MigrationManager _migrationManager = MigrationManager();

  /// 初始化数据库
  Future<void> init() async {
    try {
      _db = await openSqliteDb();

      // 运行迁移
      _migrationManager.runMigrations(_db);
    } catch (e) {
      LogUtils.e('数据库初始化失败', tag: 'DatabaseService', error: e);
      throw DatabaseException("数据库初始化失败: $e");
    }
  }

  /// 获取数据库实例
  CommonDatabase get database => _db;

  /// 清理日志数据库文件（如果存在）
  Future<void> cleanupLogDatabase() async {
    try {
      // 获取应用文档目录
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbDir = path.join(appDocDir.path, CommonConstants.applicationName ?? 'i_iwara');

      // 日志数据库文件路径
      final logDbPath = path.join(dbDir, 'iwara_logs.db');
      final logDbFile = File(logDbPath);

      // 如果日志数据库文件存在，删除它
      if (await logDbFile.exists()) {
        await logDbFile.delete();
        LogUtils.i('已删除日志数据库文件', 'DatabaseService');
      }
    } catch (e) {
      LogUtils.e('清理日志数据库失败', tag: 'DatabaseService', error: e);
    }
  }



  /// 关闭数据库
  void close() {
    _db.close();
    LogUtils.d('数据库已关闭', 'DatabaseService');
  }
}
