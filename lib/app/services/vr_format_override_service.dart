import 'package:get/get.dart';
import 'package:i_iwara/app/models/vr_format.model.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart';

/// 视频 VR 片源格式的「用户手动覆盖」持久层。
///
/// 只干一件事：把用户在播放器里手动定死的某个视频的 [VrSourceFormat]（投影 +
/// 左右眼编排）**永久**记在 `video_vr_override` 表里，下次再打开同一个视频时读
/// 回来，压过一切机器推断。
///
/// # ⛔ 这里没有、也不该有任何清理逻辑
///
/// 手动覆盖是一次纠错，代表「机器认错了、以我为准」。这种意图必须永远有效——
/// 所以本服务全程只有 get / put / remove 三个动作，**绝不按时间淘汰**。这也正
/// 是它不复用 `PlaybackHistoryService` / `video_playback_history` 的原因：那张表
/// 的 `init()` 会把 7 天前的行整批 DELETE 掉，覆盖被清掉等于用户每周都要重新纠
/// 正同一个视频。详见迁移 v22 的表头注释。
class VrFormatOverrideService extends GetxService {
  static VrFormatOverrideService get to => Get.find();

  static const String _tag = 'VrFormatOverrideService';

  late final CommonDatabase _db;

  /// [database] 仅供测试注入内存库；生产走 [DatabaseService] 的单例连接。
  VrFormatOverrideService({CommonDatabase? database}) {
    _db = database ?? DatabaseService().database;
  }

  /// 读回某个视频的手动覆盖；没有覆盖返回 null。
  ///
  /// 存的是两列枚举名（projection / stereo），这里拼回配置串交给
  /// [VrSourceFormat.fromConfigString] 容错解析——脏数据/旧值认不出来时，每个
  /// 字段各自退回自己的安全缺省，而不是整条丢弃。
  Future<VrSourceFormat?> get(String videoId) async {
    try {
      final results = _db.select(
        'SELECT projection, stereo FROM video_vr_override WHERE video_id = ?',
        [videoId],
      );
      if (results.isEmpty) return null;

      final row = results.first;
      final projection = row['projection'] as String?;
      final stereo = row['stereo'] as String?;
      return VrSourceFormat.fromConfigString('$projection:$stereo');
    } catch (e) {
      LogUtils.e('读取 VR 格式覆盖失败', tag: _tag, error: e);
      return null;
    }
  }

  /// 写入/更新某个视频的手动覆盖。一个视频只留一份（主键为 video_id，
  /// INSERT OR REPLACE 直接顶掉旧值）。
  Future<void> put(String videoId, VrSourceFormat format) async {
    try {
      _db.execute(
        '''
        INSERT OR REPLACE INTO video_vr_override
          (video_id, projection, stereo, updated_at)
        VALUES (?, ?, ?, ?)
        ''',
        [
          videoId,
          format.projection.name,
          format.stereoLayout.name,
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
        ],
      );
    } catch (e) {
      LogUtils.e('写入 VR 格式覆盖失败', tag: _tag, error: e);
    }
  }

  /// 撤销某个视频的手动覆盖，交回给机器推断。删不存在的行是无害 no-op。
  Future<void> remove(String videoId) async {
    try {
      _db.execute(
        'DELETE FROM video_vr_override WHERE video_id = ?',
        [videoId],
      );
    } catch (e) {
      LogUtils.e('删除 VR 格式覆盖失败', tag: _tag, error: e);
    }
  }
}
