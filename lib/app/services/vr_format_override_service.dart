import 'package:get/get.dart';
import 'package:i_iwara/app/models/vr_format.model.dart';
import 'package:i_iwara/app/repositories/local_media_repository.dart';
import 'package:i_iwara/db/database_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:sqlite3/common.dart';

/// 一条手动覆盖：2D 播放器那份粗粒度格式，外加空间面板选定的精确档（可空）。
class VrFormatOverride {
  const VrFormatOverride({required this.format, this.xrFormat});

  final VrSourceFormat format;

  /// 空间面板（Quest 原生 `VideoFormat`）的枚举名，只有在空间里亲手选过才有。
  /// 它表达得了 [format] 表达不了的全幅 SBS / 鱼眼视场角 / EAC，见迁移 v40。
  final String? xrFormat;
}

/// 视频 VR 片源格式的「用户手动覆盖」持久层。
///
/// 只干一件事：把用户手动定死的某个视频的 [VrSourceFormat]（投影 + 左右眼编排）
/// **永久**记在 `video_vr_override` 表里，下次再打开同一个视频时读回来，压过一切
/// 机器推断。钥匙是在线视频 id，或本机文件的本地库条目 id（两个命名空间形状不同，
/// 天生不撞，见 `MyVideoStateController.vrOverrideKey`）。
///
/// # ⛔ 这里没有、也不该有任何按时间清理的逻辑
///
/// 手动覆盖是一次纠错，代表「机器认错了、以我为准」。这种意图必须永远有效——
/// 所以本服务**绝不按时间淘汰**。这也正是它不复用 `PlaybackHistoryService` /
/// `video_playback_history` 的原因：那张表的 `init()` 会把 7 天前的行整批 DELETE
/// 掉，覆盖被清掉等于用户每周都要重新纠正同一个视频。详见迁移 v22 的表头注释。
///
/// 本机文件那一侧的行**跟着条目走**：条目被删（应用内删文件 / 移除来源）时同一个
/// 事务里一起删，见 [LocalMediaRepository.deleteItems]；文件在应用外被挪走 / 改名时
/// 由 [getEntry] 按指纹认领，见 [LocalMediaRepository.adoptVrOverrideByFingerprint]。
class VrFormatOverrideService extends GetxService {
  static VrFormatOverrideService get to => Get.find();

  static const String _tag = 'VrFormatOverrideService';

  late final CommonDatabase _db;

  /// [database] 仅供测试注入内存库；生产走 [DatabaseService] 的单例连接。
  VrFormatOverrideService({CommonDatabase? database}) {
    _db = database ?? DatabaseService().database;
  }

  /// 读回某个视频的手动覆盖；没有覆盖返回 null。
  Future<VrSourceFormat?> get(String videoId) async =>
      (await getEntry(videoId))?.format;

  /// 读回某个视频的手动覆盖（连同空间面板的精确档）；没有覆盖返回 null。
  ///
  /// 存的是两列枚举名（projection / stereo），这里拼回配置串交给
  /// [VrSourceFormat.fromConfigString] 容错解析——脏数据/旧值认不出来时，每个
  /// 字段各自退回自己的安全缺省，而不是整条丢弃。
  ///
  /// 按 id 查不到时，若它是本机文件，再按指纹问一次（文件在应用外被改名 / 挪目录，
  /// 路径 sha1 变了 id 就跟着变）。认领成功会落库，下次按 id 直接命中。
  Future<VrFormatOverride?> getEntry(String videoId) async {
    try {
      final rows = _db.select(
        'SELECT projection FROM video_vr_override WHERE video_id = ?',
        [videoId],
      );
      if (rows.isNotEmpty) {
        // 墓碑（projection 为 NULL）= 用户对这个本机文件点过「恢复自动识别」：没有覆盖，
        // 也**不许再按指纹认领**，见 [remove]。
        return rows.first['projection'] == null ? null : _select(videoId);
      }
      final adopted = LocalMediaRepository(
        _db,
      ).adoptVrOverrideByFingerprint(videoId);
      if (!adopted) return null;
      return _select(videoId);
    } catch (e) {
      LogUtils.e('读取 VR 格式覆盖失败', tag: _tag, error: e);
      return null;
    }
  }

  bool _isLocalItem(String videoId) {
    try {
      return _db.select('SELECT 1 FROM local_media_items WHERE id = ?', [
        videoId,
      ]).isNotEmpty;
    } catch (_) {
      // 没有本地库表（单测的内存库只跑了 v22 / v40）。
      return false;
    }
  }

  VrFormatOverride? _select(String videoId) {
    final results = _db.select(
      'SELECT projection, stereo, xr_format FROM video_vr_override WHERE video_id = ?',
      [videoId],
    );
    if (results.isEmpty) return null;
    final row = results.first;
    final projection = row['projection'] as String?;
    final stereo = row['stereo'] as String?;
    final xrFormat = (row['xr_format'] as String?)?.trim();
    return VrFormatOverride(
      format: VrSourceFormat.fromConfigString('$projection:$stereo'),
      xrFormat: (xrFormat == null || xrFormat.isEmpty) ? null : xrFormat,
    );
  }

  /// 写入/更新某个视频的手动覆盖。一个视频只留一份（主键为 video_id，
  /// INSERT OR REPLACE 直接顶掉旧值）。
  ///
  /// [xrFormat] 只有空间面板会传。2D 播放器里重选时不传 = 清掉旧的精确档：
  /// 那边表达不了全幅 / 鱼眼视场角，留着旧档会让空间里铺出来的与 2D 里刚选的对不上。
  Future<void> put(
    String videoId,
    VrSourceFormat format, {
    String? xrFormat,
  }) async {
    try {
      _db.execute(
        '''
        INSERT OR REPLACE INTO video_vr_override
          (video_id, projection, stereo, updated_at, xr_format)
        VALUES (?, ?, ?, ?, ?)
        ''',
        [
          videoId,
          format.projection.name,
          format.stereoLayout.name,
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
          xrFormat,
        ],
      );
    } catch (e) {
      LogUtils.e('写入 VR 格式覆盖失败', tag: _tag, error: e);
    }
  }

  /// 撤销某个视频的手动覆盖，交回给机器推断。删不存在的行是无害 no-op。
  ///
  /// ⛔ 本机文件不能直接 DELETE，要留一块**墓碑**（projection / stereo 为 NULL）：
  /// 按 id 查不到时 [getEntry] 会按文件指纹去别的条目那里认领——改名前的旧条目（missing）
  /// 或同一文件的另一份拷贝身上还挂着旧覆盖，一删就当场被认领回来，用户点了「恢复自动」
  /// 下次打开照旧是那一档。在线视频没有认领这回事，照常删掉。
  Future<void> remove(String videoId) async {
    try {
      final isLocalItem = _isLocalItem(videoId);
      if (isLocalItem) {
        _db.execute(
          'INSERT OR REPLACE INTO video_vr_override '
          '(video_id, projection, stereo, updated_at, xr_format) '
          'VALUES (?, NULL, NULL, ?, NULL)',
          [videoId, DateTime.now().millisecondsSinceEpoch ~/ 1000],
        );
        return;
      }
      _db.execute('DELETE FROM video_vr_override WHERE video_id = ?', [
        videoId,
      ]);
    } catch (e) {
      LogUtils.e('删除 VR 格式覆盖失败', tag: _tag, error: e);
    }
  }
}
