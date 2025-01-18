import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'migration.dart';

class MigrationV4Favorites extends Migration {
  @override
  int get version => 4;

  @override
  String get description => "创建收藏夹和收藏项目表";

  @override
  void up(CommonDatabase db) {
    // 创建收藏夹表
    db.execute('''
      CREATE TABLE IF NOT EXISTS favorite_folders(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
        updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now'))
      );
    ''');

    // 创建收藏项目表
    db.execute('''
      CREATE TABLE IF NOT EXISTS favorite_items(
        id TEXT PRIMARY KEY,
        folder_id TEXT NOT NULL,
        item_type TEXT NOT NULL, -- video, image, user
        item_id TEXT NOT NULL,
        title TEXT NOT NULL,
        preview_url TEXT,
        author_name TEXT,
        author_username TEXT,
        author_avatar_url TEXT,
        ext_data TEXT, -- 额外数据，JSON格式
        tags TEXT, -- 标签数据，JSON格式
        created_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
        updated_at INTEGER NOT NULL DEFAULT (strftime('%s','now')),
        FOREIGN KEY(folder_id) REFERENCES favorite_folders(id) ON DELETE CASCADE
      );
    ''');

    // 创建索引
    // 1. 文件夹内容按时间排序的索引
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_favorite_items_folder_time 
      ON favorite_items(folder_id, created_at DESC);
    ''');

    // 2. 检查项目是否已收藏的索引
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_favorite_items_type_id 
      ON favorite_items(item_type, item_id);
    ''');

    // 3. 时间范围筛选的索引
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_favorite_items_created_at 
      ON favorite_items(created_at DESC);
    ''');

    // 4. 标签搜索的索引
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_favorite_items_tags 
      ON favorite_items(tags);
    ''');

    // 创建默认收藏夹
    db.execute('''
      INSERT INTO favorite_folders (id, title, description)
      VALUES ('default', 'Default Favorites', 'System default favorites folder');
    ''');

    db.execute('PRAGMA user_version = 4;');
    LogUtils.i('已应用迁移v4：创建收藏夹和收藏项目表');
  }

  @override
  void down(CommonDatabase db) {
    db.execute('DROP TABLE IF EXISTS favorite_items;');
    db.execute('DROP TABLE IF EXISTS favorite_folders;');
    db.execute('PRAGMA user_version = 3;');
    LogUtils.i('已回滚迁移v4：删除收藏夹和收藏项目表');
  }
} 