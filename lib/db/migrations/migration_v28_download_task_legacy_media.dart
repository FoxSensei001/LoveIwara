import 'dart:convert';

import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'migration.dart';

/// v28：补齐 v13 迁移时没有成功解析的历史视频任务媒体索引。
///
/// 旧任务的 `media_type` 可能仍为空；只要 ext_data 里保留了视频类型和 id，
/// 就可以在迁移时安全补回，之后「已下载」同步和播放队列都能看到它。
class MigrationV28DownloadTaskLegacyMedia extends Migration {
  @override
  int get version => 28;

  @override
  String get description => '补齐历史下载任务的视频媒体索引';

  @override
  void up(CommonDatabase db) {
    final rows = db.select(
      'SELECT id, ext_data FROM download_tasks '
      'WHERE media_type IS NULL AND ext_data IS NOT NULL',
    );
    var repaired = 0;
    for (final row in rows) {
      try {
        final decoded = jsonDecode(row['ext_data'].toString());
        if (decoded is! Map<String, dynamic> || decoded['type'] != 'video') {
          continue;
        }
        final data = decoded['data'];
        if (data is! Map<String, dynamic>) continue;
        final mediaId = data['id'] as String?;
        if (mediaId == null || mediaId.isEmpty) continue;
        final quality = data['quality'] as String?;
        db.execute(
          'UPDATE download_tasks SET media_type = ?, media_id = ?, quality = ? '
          'WHERE id = ?',
          ['video', mediaId, quality, row['id']],
        );
        repaired++;
      } catch (e) {
        LogUtils.w(
          '迁移v28：解析历史视频任务失败，taskId=${row['id']}，error=$e',
          'MigrationV28DownloadTaskLegacyMedia',
        );
      }
    }
    LogUtils.i('已应用迁移v28：补齐 $repaired 条历史视频媒体索引');
  }

  @override
  void down(CommonDatabase db) {}
}
