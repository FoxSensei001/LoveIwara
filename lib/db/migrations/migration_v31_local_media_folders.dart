import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'migration.dart';

/// v31：本地媒体库目录实体（`local_media_folders`）与常用目录（`local_media_pinned_folders`）。
///
/// # ⛔ `rel_path` 是树的权威，`folder_path` 只是附属
///
/// iOS 沙盒容器 UUID 会随升级漂移，bookmark 重解析出的新根路径会让所有绝对路径失效；
/// rel_path 不含根前缀，所以漂移后重扫只更新 folder_path，树结构一行都不用动。
///
/// # 索引设计
///
/// - `idx_local_folders_children`：直查直接子目录，涵盖 (source_id, parent_rel_path, missing, sort_name, name, id)，
///   带齐 ORDER BY 兜底列，保证层级浏览无需临时 B 树。
/// - `idx_local_folders_abs`：按扫描得到的绝对路径与 items 的 folder_path 对齐匹配。
/// - `idx_local_pinned_order`：常用目录按用户自定义顺序与创建时间排序。
class MigrationV31LocalMediaFolders extends Migration {
  @override
  int get version => 31;

  @override
  String get description => '本地媒体库目录实体与常用目录';

  static const Map<String, String> _folderColumns = <String, String>{
    'parent_rel_path': 'TEXT',
    'name': 'TEXT',
    'sort_name': 'TEXT',
    'folder_path': 'TEXT',
    'video_count': 'INTEGER NOT NULL DEFAULT 0',
    'image_count': 'INTEGER NOT NULL DEFAULT 0',
    'child_folder_count': 'INTEGER NOT NULL DEFAULT 0',
    'cover_path': 'TEXT',
    'modified_at': 'INTEGER',
    'missing': 'INTEGER NOT NULL DEFAULT 0',
    'probed_at': 'INTEGER',
    'cover_pinned': 'INTEGER NOT NULL DEFAULT 0',
  };

  static const Map<String, String> _pinnedColumns = <String, String>{
    'display_name': 'TEXT',
    'created_at': 'INTEGER',
    'sort_order': 'INTEGER NOT NULL DEFAULT 0',
  };

  @override
  void up(CommonDatabase db) {
    LogUtils.i('开始执行迁移v31：本地媒体库目录实体与常用目录');

    // ── 目录实体 ──────────────────────────────────────────────────────────
    // ⛔ `rel_path` 是树的权威，`folder_path` 只是附属。
    // iOS 沙盒容器 UUID 会随升级漂移，bookmark 重解析出的新根路径会让所有绝对路径失效；
    // rel_path 不含根前缀，所以漂移后重扫只更新 folder_path，树结构一行都不用动。
    db.execute('''
      CREATE TABLE IF NOT EXISTS local_media_folders(
        id TEXT PRIMARY KEY,
        source_id TEXT NOT NULL,
        rel_path TEXT NOT NULL,
        parent_rel_path TEXT,
        name TEXT NOT NULL,
        sort_name TEXT NOT NULL,
        folder_path TEXT,
        video_count INTEGER NOT NULL DEFAULT 0,
        image_count INTEGER NOT NULL DEFAULT 0,
        child_folder_count INTEGER NOT NULL DEFAULT 0,
        cover_path TEXT,
        modified_at INTEGER,
        missing INTEGER NOT NULL DEFAULT 0,
        probed_at INTEGER,
        cover_pinned INTEGER NOT NULL DEFAULT 0,
        UNIQUE(source_id, rel_path)
      );
    ''');

    // ── 常用目录（置顶目录） ─────────────────────────────────────────────
    db.execute('''
      CREATE TABLE IF NOT EXISTS local_media_pinned_folders(
        id TEXT PRIMARY KEY,
        source_id TEXT NOT NULL,
        rel_path TEXT NOT NULL,
        display_name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        UNIQUE(source_id, rel_path)
      );
    ''');

    // 幂等补列：若已有旧表则补全缺失字段
    _ensureColumns(db, 'local_media_folders', _folderColumns);
    _ensureColumns(db, 'local_media_pinned_folders', _pinnedColumns);

    _createIndexes(db);

    LogUtils.i('已应用迁移v31：本地媒体库目录实体与常用目录表就位');
  }

  static List<String> _ensureColumns(
    CommonDatabase db,
    String table,
    Map<String, String> columns,
  ) {
    final existing = <String>{
      for (final row in db.select('PRAGMA table_info($table)'))
        row['name'] as String,
    };
    final added = <String>[];
    for (final entry in columns.entries) {
      if (existing.contains(entry.key)) continue;
      db.execute('ALTER TABLE $table ADD COLUMN ${entry.key} ${entry.value}');
      added.add(entry.key);
    }
    return added;
  }

  static void _createIndexes(CommonDatabase db) {
    const statements = <String>[
      'CREATE INDEX IF NOT EXISTS idx_local_folders_children '
          'ON local_media_folders(source_id, parent_rel_path, missing, sort_name, name, id)',
      'CREATE INDEX IF NOT EXISTS idx_local_folders_abs '
          'ON local_media_folders(source_id, folder_path)',
      'CREATE INDEX IF NOT EXISTS idx_local_pinned_order '
          'ON local_media_pinned_folders(sort_order, created_at)',
    ];
    for (final statement in statements) {
      db.execute(statement);
    }
  }
}
