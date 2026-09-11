import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'migration.dart';

class MigrationV8DisableTheater extends Migration {
  @override
  int get version => 8;

  @override
  String get description => "强制关闭剧院模式";

  @override
  void up(CommonDatabase db) {
    db.execute('''
      UPDATE app_config 
      SET value = 'false' 
      WHERE key = 'theater_mode';
    ''');
    LogUtils.i('已应用迁移v8：强制关闭剧院模式');
  }
}
