import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'migration.dart';

/// v14: 为 favorite_folders 表添加 display_order 字段以支持自定义排序
class MigrationV14FavoriteFolderOrder extends Migration {
  @override
  int get version => 14;

  @override
  String get description => '为收藏夹表添加 display_order 字段以支持自定义排序';

  @override
  void up(CommonDatabase db) {
    LogUtils.i('开始执行迁移v14：为 favorite_folders 添加 display_order 字段');

    // 添加 display_order 字段（默认为 0）
    db.execute('ALTER TABLE favorite_folders ADD COLUMN display_order INTEGER NOT NULL DEFAULT 0;');

    // 为现有记录初始化 display_order，按创建时间排序
    try {
      final stmt = db.prepare('''
        SELECT id FROM favorite_folders
        ORDER BY created_at DESC
      ''');

      final rows = stmt.select();
      stmt.close();

      for (var i = 0; i < rows.length; i++) {
        final id = rows[i]['id'] as String;
        db.execute(
          'UPDATE favorite_folders SET display_order = ? WHERE id = ?',
          [i, id],
        );
      }

      LogUtils.i('迁移v14：已为 ${rows.length} 个收藏夹初始化排序值');
    } catch (e) {
      LogUtils.w(
        '迁移v14：初始化 display_order 失败，error=$e',
        'MigrationV14FavoriteFolderOrder',
      );
    }

    // 创建索引以提高排序查询性能
    db.execute(
      'CREATE INDEX IF NOT EXISTS idx_favorite_folders_display_order ON favorite_folders(display_order);',
    );

    db.execute('PRAGMA user_version = 14;');
    LogUtils.i('已应用迁移v14：收藏夹排序字段与索引创建完成');
  }

  @override
  void down(CommonDatabase db) {
    LogUtils.i('开始回滚迁移v14：移除收藏夹排序索引');

    // 删除索引
    db.execute('DROP INDEX IF EXISTS idx_favorite_folders_display_order;');

    // SQLite 不支持 ALTER TABLE DROP COLUMN，所以保留字段
    // 如果需要完全回滚，需要重建表

    db.execute('PRAGMA user_version = 13;');
    LogUtils.i('已回滚迁移v14：数据库版本已回退到 v13');
  }
}
