import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'migration.dart';

/// v40：`video_vr_override` 加一列 `xr_format`，存用户在**空间控制面板**上亲手定的视频类型。
///
/// # 为什么 projection / stereo 两列不够
///
/// 那两列是 2D 播放器那一套 `VrSourceFormat` 的粒度。空间面板（Quest 原生侧的
/// `VideoFormat`）比它细：半幅 / 全幅 SBS（FSBS / FOU）、鱼眼视场角 180~220、EAC。
/// 只存两列的话，用户选了「平面 3D FSBS」，下次进来被还原成 HSBS，画面比例是错的——
/// 等于没记。所以原生枚举名原样存一份，沉浸端靠它逐格还原；两列照旧存粗粒度的那份给 2D 用。
///
/// 这一列**只由空间面板写**。2D 播放器里重新选格式时会把它清成 NULL（那边表达不了
/// 细粒度，留着旧的只会让空间里显示的和 2D 里选的对不上）。
///
/// 与 v22 同一条硬约束：**永不按时间清理**。
class MigrationV40VrOverrideXrFormat extends Migration {
  @override
  int get version => 40;

  @override
  String get description => 'video_vr_override 加 xr_format 列（空间面板选定的精确视频类型）';

  @override
  void up(CommonDatabase db) {
    final tableExists = db
        .select(
          "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'video_vr_override'",
        )
        .isNotEmpty;
    if (!tableExists) {
      // v22 没跑过的库（理论上不存在）：建成含新列的完整形状。
      db.execute('''
        CREATE TABLE IF NOT EXISTS video_vr_override(
          video_id TEXT PRIMARY KEY,
          projection TEXT,
          stereo TEXT,
          updated_at INTEGER,
          xr_format TEXT
        );
      ''');
      LogUtils.i('video_vr_override 不存在，已按含 xr_format 的形状新建', 'MigrationV40');
      return;
    }

    final hasColumn = db
        .select('PRAGMA table_info(video_vr_override)')
        .any((row) => row['name'] == 'xr_format');
    if (hasColumn) {
      LogUtils.i('xr_format 已存在，跳过 v40', 'MigrationV40');
      return;
    }

    db.execute('ALTER TABLE video_vr_override ADD COLUMN xr_format TEXT;');
    LogUtils.i('已为 video_vr_override 添加 xr_format', 'MigrationV40');
  }
}
