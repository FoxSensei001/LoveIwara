import 'dart:convert';

import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'migration.dart';

/// v13: 为 download_tasks 增加媒体维度字段及索引
class MigrationV13DownloadTaskMediaIndex extends Migration {
  @override
  int get version => 13;

  @override
  String get description => '为 download_tasks 增加 media_type/media_id/quality 字段并建立索引';

  @override
  void up(CommonDatabase db) {
    LogUtils.i('开始执行迁移v13：为 download_tasks 增加媒体字段与索引');

    // 增加可空字段，兼容旧数据
    db.execute("ALTER TABLE download_tasks ADD COLUMN media_type TEXT;");
    db.execute("ALTER TABLE download_tasks ADD COLUMN media_id TEXT;");
    db.execute("ALTER TABLE download_tasks ADD COLUMN quality TEXT;");

    // 为高频查询建立索引
    db.execute(
      'CREATE INDEX IF NOT EXISTS idx_download_tasks_media_type_id ON download_tasks(media_type, media_id);',
    );
    db.execute(
      'CREATE INDEX IF NOT EXISTS idx_download_tasks_video_quality ON download_tasks(media_type, media_id, quality);',
    );

    // 一次性回填历史数据中的媒体字段，避免依赖业务侧懒加载
    try {
      LogUtils.i('迁移v13：开始基于 ext_data 回填 download_tasks.media_* 字段');

      final stmt = db.prepare('''
        SELECT id, ext_data 
        FROM download_tasks 
        WHERE ext_data IS NOT NULL 
          AND (media_type IS NULL OR media_id IS NULL)
      ''');

      final rows = stmt.select([]);
      stmt.close();

      for (final row in rows) {
        final id = row['id'] as String;
        final rawExt = row['ext_data'];

        if (rawExt == null) continue;

        String mediaType;
        String mediaId;
        String? quality;

        try {
          final jsonStr = rawExt.toString().trim();
          final decoded = jsonDecode(jsonStr);

          if (decoded is! Map<String, dynamic>) {
            continue;
          }

          final type = decoded['type'] as String?;
          final data = decoded['data'];
          if (type == null || data is! Map<String, dynamic>) {
            continue;
          }

          if (type == 'video') {
            final vid = data['id'] as String?;
            final q = data['quality'] as String?;
            if (vid == null || vid.isEmpty) {
              continue;
            }
            mediaType = 'video';
            mediaId = vid;
            quality = (q != null && q.isNotEmpty) ? q : null;
          } else if (type == 'gallery') {
            final gid = data['id'] as String?;
            if (gid == null || gid.isEmpty) {
              continue;
            }
            mediaType = 'gallery';
            mediaId = gid;
            quality = null;
          } else {
            // 其他类型暂不处理
            continue;
          }
        } catch (e) {
          LogUtils.w(
            '迁移v13：解析 ext_data 回填媒体字段失败，taskId=$id, error=$e',
            'MigrationV13DownloadTaskMediaIndex',
          );
          continue;
        }

        try {
          db.execute(
            '''
            UPDATE download_tasks
            SET media_type = ?, media_id = ?, quality = ?
            WHERE id = ?
          ''',
            [mediaType, mediaId, quality, id],
          );
        } catch (e) {
          LogUtils.w(
            '迁移v13：更新媒体字段失败，taskId=$id, error=$e',
            'MigrationV13DownloadTaskMediaIndex',
          );
        }
      }

      LogUtils.i('迁移v13：基于 ext_data 的媒体字段回填完成，共处理 ${rows.length} 条记录');
    } catch (e) {
      LogUtils.w(
        '迁移v13：回填 download_tasks 媒体字段时发生异常，已跳过，后续可由业务侧懒填充。error=$e',
        'MigrationV13DownloadTaskMediaIndex',
      );
    }

    db.execute('PRAGMA user_version = 13;');
    LogUtils.i('已应用迁移v13：download_tasks 媒体字段与索引创建完成');
  }

  @override
  void down(CommonDatabase db) {
    LogUtils.i('开始回滚迁移v13：移除 download_tasks 的媒体索引');

    // 仅删除索引，保留新增列，避免复杂的表重建逻辑
    db.execute(
      'DROP INDEX IF EXISTS idx_download_tasks_media_type_id;',
    );
    db.execute(
      'DROP INDEX IF EXISTS idx_download_tasks_video_quality;',
    );

    db.execute('PRAGMA user_version = 12;');
    LogUtils.i('已回滚迁移v13：数据库版本已回退到 v12');
  }
}


