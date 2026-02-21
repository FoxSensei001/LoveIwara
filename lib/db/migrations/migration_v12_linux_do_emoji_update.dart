import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'migration.dart';

class MigrationV12LinuxDoEmojiUpdate extends Migration {
  @override
  int get version => 12;

  @override
  String get description => "更新 neko 分组下的 linux.do 表情包";

  @override
  void up(CommonDatabase db) {
    LogUtils.i('开始执行迁移v12：更新 neko 分组下的 linux.do 表情包');

    // 获取 neko 分组的 ID
    final stmt = db.prepare('SELECT group_id FROM EmojiGroups WHERE name = ?;');
    final result = stmt.select(['neko']);

    if (result.isEmpty) {
      LogUtils.w('未找到 neko 分组，跳过迁移');
      stmt.close();
      return;
    }

    final nekoGroupId = result.first['group_id'] as int;
    stmt.close();

    // 删除 neko 分组下所有 linux.do 域名的表情
    final deleteStmt = db.prepare('''
      DELETE FROM EmojiImages 
      WHERE group_id = ? AND url LIKE '%linux.do%';
    ''');

    final deleteResult = deleteStmt.select([nekoGroupId]);
    final deletedCount = deleteResult.length;
    deleteStmt.close();

    LogUtils.i('已删除 neko 分组下 $deletedCount 个 linux.do 域名的表情');

    // 新的表情包 URL
    const toInputImgs = <String>[
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/1.jpeg",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/2.jpeg",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/3.jpeg",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/4.jpeg",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/5.jpeg",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/6.jpeg",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/7.jpeg",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/8.jpeg",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/9.jpeg",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/11.jpeg",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/12.jpeg",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/13.jpeg",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/14.jpeg",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/15.jpeg",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/16.jpeg",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/17.jpeg",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/40.jpeg",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/18.png",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/19.png",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/20.png",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/21.png",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/22.png",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/23.png",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/24.png",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/25.png",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/26.png",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/27.png",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/28.png",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/29.png",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/30.png",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/31.png",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/32.png",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/33.png",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/34.png",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/35.png",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/36.png",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/37.png",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/38.png",
      "https://cdn.jsdelivr.net/gh/FoxSensei001/t/39.png",
    ];

    // 批量插入新的表情包
    for (int i = 0; i < toInputImgs.length; i++) {
      db.execute(
        '''
        INSERT INTO EmojiImages (group_id, url, thumbnail_url) 
        VALUES (?, ?, ?);
      ''',
        [nekoGroupId, toInputImgs[i], toInputImgs[i]],
      );
    }

    // 如果 neko 分组下还有表情包，更新封面图为第一张图片
    final checkStmt = db.prepare('''
      SELECT url FROM EmojiImages 
      WHERE group_id = ? 
      ORDER BY image_id ASC 
      LIMIT 1;
    ''');
    final checkResult = checkStmt.select([nekoGroupId]);
    checkStmt.close();

    if (checkResult.isNotEmpty) {
      final firstImageUrl = checkResult.first['url'] as String;
      db.execute(
        '''
        UPDATE EmojiGroups 
        SET cover_url = ? 
        WHERE group_id = ?;
      ''',
        [firstImageUrl, nekoGroupId],
      );
    }

    db.execute('PRAGMA user_version = 12;');
    LogUtils.i('已应用迁移v12：更新 neko 分组下的 linux.do 表情包完成');
  }

  @override
  void down(CommonDatabase db) {
    LogUtils.i('开始回滚迁移v12：恢复 neko 分组下的 linux.do 表情包');

    // 注意：由于我们删除了 linux.do 域名的表情，回滚时需要重新插入
    // 这里需要从备份或其他地方恢复原始数据
    // 目前先记录日志，实际回滚可能需要手动处理

    LogUtils.w('迁移v12的回滚操作需要手动处理，因为原始 linux.do 表情包已被删除');

    db.execute('PRAGMA user_version = 11;');
    LogUtils.i('已回滚迁移v12：数据库版本已回退到 v11');
  }
}
