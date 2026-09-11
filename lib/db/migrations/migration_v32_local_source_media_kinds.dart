import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'migration.dart';

/// v32：把已有的目录 / 书签源从「只收视频」升成「视频 + 图片」。
///
/// # 为什么需要这一条
///
/// `local_media_sources.media_kinds` 决定扫描器收不收图片
/// （`local_media_scan_service.dart` 里的 `wantsImages` / `wantsVideos`）。
/// 本地库最早只做视频，建表 DDL 与模型默认值都是 `'video'`；后来加上图片支持时，
/// **只改了新建源那两处调用点**，库里既有的行一个都没动。
///
/// 后果不是「少收一点东西」这么轻：
/// - 没有任何界面能改一个源的 media_kinds；
/// - 「重新扫描」是拿着那个旧值再走一遍目录树，扫多少次都还是只有视频。
///
/// 真机上撞到的样子：用户把下载目录改到 `/storage/emulated/0/Download`，下了一套
/// 图库，进「本机文件 → Download」里什么都没有，手动重扫也没用——库里那行写着
/// `media_kinds = 'video'`，图片在 `_shouldCollect` 那一步就被丢掉了。
///
/// # ⛔ 只升目录 / 书签源
///
/// - `mediastore` 源的 uri 是 `content://media/external/video/media`，
///   它按构造就只有视频，升成 both 只会让人以为它会带图片进来。
/// - `downloads` 源不走目录扫描，条目来自 `DownloadsLibrarySyncService`，
///   而那边今天只同步 `completedVideoTasks()`。在同步补上图库之前把它标成 both
///   是一句谎话。
class MigrationV32LocalSourceMediaKinds extends Migration {
  @override
  int get version => 32;

  @override
  String get description => '目录源默认收图片';

  @override
  void up(CommonDatabase db) {
    final tableExists = db.select(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      <Object?>['local_media_sources'],
    ).isNotEmpty;
    if (!tableExists) {
      // v30 会把表按新 DDL（默认 'both'）建出来，这里没有要补的。
      LogUtils.i('local_media_sources 尚不存在，跳过 v32', 'MigrationV32');
      return;
    }

    db.execute(
      "UPDATE local_media_sources SET media_kinds = 'both' "
      "WHERE kind IN ('directory', 'bookmark') AND media_kinds = 'video'",
    );
    final changed = db.updatedRows;
    if (changed > 0) {
      LogUtils.i('已把 $changed 个目录源升为收图片', 'MigrationV32');
    }

    // ⛔ 这条迁移只把开关拨对，**补不出内容**：目录树要走一遍文件系统才拿得到，
    // 迁移只动数据库（同 v31 的目录树，见 `MigrationV31LocalMediaFolders`）。
    // 而目录源今天不会自己重扫（只有 mediastore 源跟着系统的变更通知走），
    // 所以升级上来的用户得手动点一次「重新扫描」，图片才会进库。
    // 「什么时候该自动重扫目录源」是另一个待定的问题，不在这条迁移的范围里。
  }

  /// ⛔ 回滚是**空操作**，不要"把 both 改回 video"。
  ///
}
