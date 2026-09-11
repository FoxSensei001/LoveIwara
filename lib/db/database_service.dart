import 'dart:io';

import 'package:flutter/foundation.dart' show visibleForTesting;
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

      _ensureCriticalSchema(_db);
    } catch (e, stackTrace) {
      LogUtils.e(
        '数据库初始化失败',
        tag: 'DatabaseService',
        error: e,
        stackTrace: stackTrace,
      );
      // 迁移失败时 e 已经是一条信息完整的 DatabaseException（带版本号与描述）。
      // 再包一层只会得到「数据库异常: 数据库初始化失败: 数据库异常: 迁移 v38…
      // 失败: …」这种套娃，还把原始抛出点丢掉。原样重抛，保住栈。
      if (e is DatabaseException) rethrow;
      Error.throwWithStackTrace(DatabaseException("数据库初始化失败: $e"), stackTrace);
    }
  }

  /// 获取数据库实例
  CommonDatabase get database => _db;

  /// 这次启动**真的补建过**的 schema 项；正常情况下恒为空。
  ///
  /// 由「诊断」页读取展示——见 [_ensureCriticalSchema] 关于「为什么必须看得见」
  /// 的说明。
  List<String> get schemaRepairs => List.unmodifiable(_schemaRepairs);
  final List<String> _schemaRepairs = [];

  /// 历史上最近一次补建的记录（跨启动持久化在 `commons` 表里），没有则为 null。
  String? get lastSchemaRepairRecord => _lastSchemaRepairRecord;
  String? _lastSchemaRepairRecord;

  /// `commons` 表里存补建记录用的键。
  static const String _schemaRepairKey = 'schema_repair_log';

  /// 幂等地确保少数几张**关键表/列**存在，作为迁移的安全网。
  ///
  /// # ⛔ 关于它的来历，别信旧注释
  ///
  /// 这块代码此前的注释写着「版本号已前进但表/列缺失这类状态确实发生过」。
  /// 2026-09-11 查证：它和迁移 v18 是**同一个 commit**（570b814f）出生的，
  /// 也就是写迁移当下顺手写的防御性代码，**不是**对任何现场报障的回应。
  /// 已知会产生这种状态的只有开发期切分支（分支 A 的 v18 跑完、切到分支 B，
  /// B 的 v18 是别的内容，于是永远不跑）。生产环境有一条机械上成立但没有证据的
  /// 路径：Android 自动备份没有排除 `i_iwara.db`，而库跑在 DELETE journal 模式
  /// （未开 WAL），备份代理若在迁移事务开着时拷走 `.db` 而不拷 `-journal`，
  /// 还原出来的就可能是半套用的 DDL。（迁移改成逐条事务后这个窗口已从「整批
  /// v1→v38」缩到「单条」。）
  ///
  /// # ⛔ 为什么它必须**留下证据**
  ///
  /// 它从 0.5.0 就发出去了，而此前**建表那条路是完全静默的**——真补建出一张表
  /// 也不记一个字，只有补列那条会记日志。于是两个版本过去，谁也说不清它到底有
  /// 没有救过人。这正是"要不要删掉它"至今无法回答的原因。
  ///
  /// 现在：先查存在性再建，真补了才记；并且把记录写进 `commons` 表 +
  /// 暴露给「诊断」页。**侧载分发没有遥测，`LogUtils.e` 的信号量约等于 0**，
  /// 用户能截图发出来的那张诊断卡才是真正拿得到的证据。
  /// 等下一个版本拿到数据，再决定删还是留——拿证据删，不是拿猜测删。
  ///
  /// ⚠️ 它**不是**安全网，别 overclaim：列缺了的话应用本来就会在第一次查询时带着
  /// `no such column` 大声炸掉。它买到的是「更早 + 点名 + 留痕」。
  void _ensureCriticalSchema(CommonDatabase db) {
    try {
      _schemaRepairs
        ..clear()
        ..addAll(ensureCriticalSchema(db));
      _flushRepairRecord(db);
      _loadLastRepairRecord(db);
    } catch (e, stackTrace) {
      LogUtils.e(
        '校验关键 schema 失败',
        tag: 'DatabaseService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 纯函数版：补建缺失的关键 schema，返回**这次真的补建了哪些项**（空 = 没动）。
  ///
  /// 抽成静态是为了能单测——一条「发现漏洞就自动修」的路径本身不能是未测试代码。
  @visibleForTesting
  static List<String> ensureCriticalSchema(CommonDatabase db) {
    final repairs = <String>[];
    void record(String what) {
      repairs.add(what);
      // error 级：这条消息的存在本身就说明迁移没把事做完，不该淹在 info 里。
      LogUtils.e(
        '⛔ 安全网补建了 schema：$what —— 说明 user_version 与实际 schema 对不上',
        tag: 'DatabaseService',
      );
    }

    if (!_tableExists(db, 'download_categories')) {
      db.execute('''
          CREATE TABLE download_categories(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
            updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
            display_order INTEGER NOT NULL DEFAULT 0
          );
        ''');
      record('建表 download_categories');
    }

    // ⛔ 先确认表在。`PRAGMA table_info` 对不存在的表返回**空结果集**（不抛异常），
    // 于是「表整张没了」会被误判成「只是缺 category_id 这一列」，紧接着的 ALTER
    // 抛 `no such table` 把整个安全网带走——连后面的索引都建不成。
    // 表本身是迁移 v3 的活，这里不越俎代庖去建，只如实记录。
    if (!_tableExists(db, 'download_tasks')) {
      record('⚠️ download_tasks 表缺失（属迁移 v3 职责，安全网不代建）');
      return repairs;
    }

    final columns = db.select("PRAGMA table_info('download_tasks')");
    final hasCategoryId = columns.any((row) => row['name'] == 'category_id');
    if (!hasCategoryId) {
      db.execute('ALTER TABLE download_tasks ADD COLUMN category_id TEXT;');
      record('补列 download_tasks.category_id');
    }

    // 索引没有"补建过"的诊断价值（缺了只是慢，不会报错），保持 IF NOT EXISTS。
    db.execute('''
        CREATE INDEX IF NOT EXISTS idx_download_tasks_category
        ON download_tasks(category_id);
      ''');

    return repairs;
  }

  static bool _tableExists(CommonDatabase db, String table) => db.select(
    "SELECT name FROM sqlite_master WHERE type='table' AND name = ?;",
    [table],
  ).isNotEmpty;

  /// 把这次的补建记录写进 `commons`（只保留最近一次，键固定），
  /// 供下次启动 / 诊断页读取。
  void _flushRepairRecord(CommonDatabase db) {
    if (_schemaRepairs.isEmpty) return;
    final record =
        '${DateTime.now().toIso8601String()} '
        'v${CommonConstants.VERSION}+${CommonConstants.BUILD_NUMBER}: '
        '${_schemaRepairs.join('；')}';
    db.execute(
      '''
      INSERT INTO commons(key, data) VALUES(?, ?)
      ON CONFLICT(key) DO UPDATE SET data = excluded.data,
                                     updated_at = datetime('now')
      ''',
      [_schemaRepairKey, record],
    );
  }

  void _loadLastRepairRecord(CommonDatabase db) {
    final rows = db.select('SELECT data FROM commons WHERE key = ?;', [
      _schemaRepairKey,
    ]);
    _lastSchemaRepairRecord = rows.isEmpty
        ? null
        : rows.first['data'] as String;
  }

  /// 清理日志数据库文件（如果存在）
  Future<void> cleanupLogDatabase() async {
    try {
      // 获取应用文档目录
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbDir = path.join(
        appDocDir.path,
        CommonConstants.applicationName ?? 'i_iwara',
      );

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
