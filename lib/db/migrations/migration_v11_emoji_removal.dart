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
      db.execute(
        '''
        DELETE FROM EmojiImages
        WHERE url = ?;
      ''',
        [url],
      );
    }

    LogUtils.i('已应用迁移v11：移除指定表情包链接完成');
  }
}
