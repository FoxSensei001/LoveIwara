import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'migration.dart';

/// v20: iwara 视频 ↔ oreno3d 视频的匹配结果缓存。
///
/// oreno3d 不支持按 iwara ID 检索，每次进详情页都要「搜索 + 逐条拉详情页校验 ID」，
/// 而绝大多数视频在 oreno3d 上根本不存在——这部分开销每次都白花。这里把匹配结论
/// 落一张只存 ID 映射的小表：
///   - oreno3d_id 非空：匹配到了，下次直接按 ID 取详情；
///   - oreno3d_id 为空：确认 oreno3d 上没有，下次直接跳过（带较短 TTL，
///     因为对面新入库的视频有索引延迟，实测当天新增的视频连按作者名都搜不到）。
///
/// 刻意**不**缓存详情内容本身（tags/characters/作者留言那一坨 JSON 一条 1~2KB），
/// 只存 ID 映射：一行约 40 字节，配合 Oreno3dMatchCacheRepository 的行数封顶
/// （5000 行，清理按小时节流、最多滞后一小时收敛）整张表约 0.5MB，
/// 不随使用时长增长。
class MigrationV20Oreno3dMatchCache extends Migration {
  @override
  int get version => 20;

  @override
  String get description => '新增 oreno3d_match_cache 表（iwara ↔ oreno3d 匹配结果缓存）';

  @override
  void up(CommonDatabase db) {
    LogUtils.i('开始执行迁移v20：oreno3d 匹配结果缓存表');

    db.execute('''
      CREATE TABLE IF NOT EXISTS oreno3d_match_cache(
        iwara_id TEXT PRIMARY KEY,
        oreno3d_id TEXT,
        updated_at INTEGER NOT NULL
      );
    ''');

    // 过期清理与行数封顶都按 updated_at 扫，这条索引让两者都走范围扫描。
    db.execute('''
      CREATE INDEX IF NOT EXISTS idx_oreno3d_match_cache_updated_at
        ON oreno3d_match_cache(updated_at);
    ''');

    LogUtils.i('已应用迁移v20：oreno3d_match_cache 表创建完成');
  }

  @override
  void down(CommonDatabase db) {
    LogUtils.i('开始回滚迁移v20');
    db.execute('DROP INDEX IF EXISTS idx_oreno3d_match_cache_updated_at;');
    db.execute('DROP TABLE IF EXISTS oreno3d_match_cache;');
    LogUtils.i('已回滚迁移v20：oreno3d_match_cache 表已删除');
  }
}
