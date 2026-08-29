import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'migration.dart';

/// v22：视频 VR 片源格式的「用户手动覆盖」持久化表。
///
/// # 为什么必须是独立一张表，而不是塞进 video_playback_history
///
/// 用户手动指定某个视频的 VR 格式（投影 + 左右眼编排）是一次**纠错**，语义上
/// 是「这台机器认错了，我来定死」。这种覆盖必须**永久记住**——否则用户每隔一
/// 段时间就要对同一个视频重新纠正一遍，体验灾难。
///
/// ⛔ 而 `video_playback_history` 的 `init()` 里有一句
/// `DELETE ... WHERE created_at < 7天前`：它把 7 天前的行整批清掉。把覆盖塞进
/// 那张表，等于给用户的手动纠正加了一个「一周就过期」的隐形定时炸弹。所以覆盖
/// 必须落在**自己这张永不清理的表**里（本表以及 [VrFormatOverrideService] 全程
/// 没有任何按时间清理的逻辑，这是刻意为之，别加）。
///
/// # 列的用途
///
/// - `video_id`：主键。一个视频只有一份覆盖，重复指定即覆盖旧值（INSERT OR
///   REPLACE）。
/// - `projection` / `stereo`：分别存投影与立体编排的枚举名（如 `equirect180` /
///   `sideBySide`），与 `VrSourceFormat` 序列化用的 `枚举.name` 对齐，读回时靠
///   模型自己的容错解析还原（认不出的字段各退各的安全缺省）。
/// - `updated_at`：秒级时间戳，仅作审计/排障用，**不参与任何淘汰**。
class MigrationV22VrFormatOverride extends Migration {
  @override
  int get version => 22;

  @override
  String get description => '新建 video_vr_override 表（VR 片源格式的用户手动覆盖，永不清理）';

  @override
  void up(CommonDatabase db) {
    LogUtils.i('开始执行迁移v22：VR 格式覆盖（video_vr_override）');

    db.execute('''
      CREATE TABLE IF NOT EXISTS video_vr_override(
        video_id TEXT PRIMARY KEY,
        projection TEXT,
        stereo TEXT,
        updated_at INTEGER
      );
    ''');

    LogUtils.i('已应用迁移v22：video_vr_override 表创建完成');
  }

  @override
  void down(CommonDatabase db) {
    LogUtils.i('开始回滚迁移v22');
    db.execute('DROP TABLE IF EXISTS video_vr_override;');
    LogUtils.i('已回滚迁移v22：video_vr_override 表已删除');
  }
}
