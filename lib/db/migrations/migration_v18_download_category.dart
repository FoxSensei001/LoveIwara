import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'migration.dart';

/// v18: 为下载任务增加「自定义分类（文件夹）」能力。
/// - 新建 download_categories 表存放用户自建分类（命名桶）。
/// - 为 download_tasks 增加可空 category_id 列，NULL 表示「未分类」。
/// - 为 category_id 建索引以加速按分类筛选 / 计数。
///
/// 设计要点：分类是单归属（一个下载至多属于一个分类），所以无需成员关系表，
/// 任务表上一个外键列即可；删除分类时把任务退回「未分类」而非删除文件。
class MigrationV18DownloadCategory extends Migration {
  @override
  int get version => 18;

  @override
  String get description =>
      '新建 download_categories 表并为 download_tasks 增加 category_id 字段';

  @override
  void up(CommonDatabase db) {
    LogUtils.i('开始执行迁移v18：下载分类（download_categories + category_id）');

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

    // 可空列，NULL = 未分类，兼容旧数据。
    // 幂等：仅当列缺失时才添加，避免在异常状态下重跑迁移抛 duplicate column。
    final columns = db.select("PRAGMA table_info('download_tasks')");
    final hasCategoryId = columns.any((row) => row['name'] == 'category_id');
    if (!hasCategoryId) {
      db.execute('ALTER TABLE download_tasks ADD COLUMN category_id TEXT;');
    }

    // 加速「按分类筛选 / 计数」
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_download_tasks_category
      ON download_tasks(category_id);
    ''');

    db.execute('PRAGMA user_version = 18;');
    LogUtils.i('已应用迁移v18：下载分类表与 category_id 字段创建完成');
  }

  @override
  void down(CommonDatabase db) {
    LogUtils.i('开始回滚迁移v18');
    db.execute('DROP INDEX IF EXISTS idx_download_tasks_category;');
    db.execute('DROP TABLE IF EXISTS download_categories;');
    // SQLite 不支持 DROP COLUMN，category_id 列保留即可
    db.execute('PRAGMA user_version = 17;');
    LogUtils.i('已回滚迁移v18：数据库版本已回退到 v17');
  }
}
