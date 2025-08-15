import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'migration.dart';

class MigrationV11EmojiRemoval extends Migration {
  @override
  int get version => 11;

  @override
  String get description => "移除指定的表情包链接";

  @override
  void up(CommonDatabase db) {
    LogUtils.i('开始执行迁移v11：移除指定的表情包链接');

    // 移除指定的表情包链接
    final urlsToRemove = [
      'https://emoji.discadia.com/emojis/eeaba756-e3a3-436b-bec3-efcf8f2b389a.PNG',
      'https://emoji.discadia.com/emojis/c45d895c-d59f-4019-af75-dc6089911544.GIF',
    ];

    for (final url in urlsToRemove) {
      db.execute('''
        DELETE FROM EmojiImages
        WHERE url = ?;
      ''', [url]);
    }

    db.execute('PRAGMA user_version = 11;');
    LogUtils.i('已应用迁移v11：移除指定表情包链接完成');
  }

  @override
  void down(CommonDatabase db) {
    // 回滚操作：重新插入被删除的表情包链接
    // 注意：这里需要知道这些表情包原本属于哪个分组
    // 根据v9迁移，这两个链接都属于senkosan分组

    // 获取senkosan分组的ID
    final stmt = db.prepare('SELECT group_id FROM EmojiGroups WHERE name = ?;');
    final result = stmt.select(['senkosan']);

    if (result.isNotEmpty) {
      final groupId = result.first['group_id'] as int;

      final urlsToRestore = [
        'https://emoji.discadia.com/emojis/eeaba756-e3a3-436b-bec3-efcf8f2b389a.PNG',
        'https://emoji.discadia.com/emojis/c45d895c-d59f-4019-af75-dc6089911544.GIF',
      ];

      for (final url in urlsToRestore) {
        db.execute('''
          INSERT INTO EmojiImages (group_id, url, thumbnail_url)
          VALUES (?, ?, ?);
        ''', [groupId, url, url]);
      }
    }

    stmt.dispose();
    db.execute('PRAGMA user_version = 10;');
    LogUtils.i('已回滚迁移v11：恢复被删除的表情包链接');
  }
}
