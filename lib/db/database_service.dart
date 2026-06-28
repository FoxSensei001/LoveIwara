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
      await _migrationManager.runMigrations(_db);

      // 安全网：迁移按 user_version 版本闸门执行，无法自愈「版本号已前进但表/列
      // 缺失」这类异常状态（例如热重载未触发迁移、迁移曾被跳过）。这里对下载分类
      // 相关 schema 做一次幂等校验补建，确保即使迁移因故未生效，重启后也能恢复。
      // 成本极低：均为 IF NOT EXISTS / table_info 检查。
      _ensureDownloadCategorySchema(_db);
    } catch (e) {
      LogUtils.e('数据库初始化失败', tag: 'DatabaseService', error: e);
      throw DatabaseException("数据库初始化失败: $e");
    }
  }

  /// 获取数据库实例
  CommonDatabase get database => _db;

  /// 幂等地确保「下载分类」相关 schema 存在（download_categories 表 +
  /// download_tasks.category_id 列 + 索引）。作为迁移的安全网，每次启动调用一次。
  void _ensureDownloadCategorySchema(CommonDatabase db) {
    try {
      db.execute('''
        CREATE TABLE IF NOT EXISTS download_categories(
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
          updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
          display_order INTEGER NOT NULL DEFAULT 0
        );
      ''');

      final columns = db.select("PRAGMA table_info('download_tasks')");
      final hasCategoryId = columns.any((row) => row['name'] == 'category_id');
      if (!hasCategoryId) {
        db.execute('ALTER TABLE download_tasks ADD COLUMN category_id TEXT;');
        LogUtils.w('安全网补建 download_tasks.category_id 列', 'DatabaseService');
      }

      db.execute('''
        CREATE INDEX IF NOT EXISTS idx_download_tasks_category
        ON download_tasks(category_id);
      ''');
    } catch (e) {
      LogUtils.e('校验下载分类 schema 失败', tag: 'DatabaseService', error: e);
    }
  }

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
