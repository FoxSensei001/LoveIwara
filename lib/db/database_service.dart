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
  CommonDatabase? _logDb;
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

  /// 初始化日志数据库
  Future<CommonDatabase> initLogDatabase() async {
    if (_logDb != null) {
      return _logDb!;
    }

    try {
      // 获取应用文档目录
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbDir = path.join(appDocDir.path, CommonConstants.applicationName ?? 'i_iwara');
      
      // 确保目录存在
      await Directory(dbDir).create(recursive: true);
      
      // 日志数据库文件路径
      final logDbPath = path.join(dbDir, 'iwara_logs.db');
      
      // 打开日志数据库
      _logDb = await openSqliteDb(customPath: logDbPath);
      
      // 初始化日志表
      _initLogTable(_logDb!);
      
      LogUtils.i('日志数据库初始化成功', 'DatabaseService');
      return _logDb!;
    } catch (e) {
      LogUtils.e('日志数据库初始化失败', tag: 'DatabaseService', error: e);
      throw DatabaseException("日志数据库初始化失败: $e");
    }
  }

  /// 初始化日志表
  void _initLogTable(CommonDatabase db) {
    db.execute('''
    CREATE TABLE IF NOT EXISTS app_logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      timestamp INTEGER NOT NULL,
      level TEXT NOT NULL,
      tag TEXT,
      message TEXT NOT NULL,
      details TEXT,
      session_id TEXT,
      created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
    )
    ''');
    
    // 创建索引
    db.execute('CREATE INDEX IF NOT EXISTS idx_logs_timestamp ON app_logs(timestamp)');
    db.execute('CREATE INDEX IF NOT EXISTS idx_logs_level ON app_logs(level)');
    db.execute('CREATE INDEX IF NOT EXISTS idx_logs_tag ON app_logs(tag)');
    db.execute('CREATE INDEX IF NOT EXISTS idx_logs_session_id ON app_logs(session_id)');
  }

  /// 获取日志数据库实例
  Future<CommonDatabase> getLogDatabase() async {
    if (_logDb == null) {
      return await initLogDatabase();
    }
    return _logDb!;
  }

  /// 关闭数据库
  void close() {
    _db.dispose();
    if (_logDb != null) {
      _logDb!.dispose();
      LogUtils.d('日志数据库已关闭', 'DatabaseService');
    }
    LogUtils.d('数据库已关闭', 'DatabaseService');
  }
}
