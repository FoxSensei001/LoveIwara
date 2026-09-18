import 'package:sqlite3/common.dart';
import 'package:i_iwara/utils/logger_utils.dart';

import 'migration.dart';

/// v43：本机文件支持 NAS（WebDAV）源，`local_media_sources` 加两列。
///
/// - `remote_state`：远端源最近一次连接的结论（`ok` / `authFailed` /
///   `certUntrusted` / `unreachable` / `credUnreadable`）。和 `offline` 并存：
///   `offline` 回答「现在能不能用」，这一列回答「为什么不能用」——「连不上」和
///   「密码不对」要给用户的是两句完全不同的话。本地源恒为 NULL。
/// - `tls_fingerprint`：用户确认信任过的服务器证书 SHA-256（自签证书 TOFU）。
///   NULL = 走系统信任。
///
/// 鉴权方式（Basic / Digest）不落库：每次都由服务器挑战、`HttpClient.authenticate`
/// 当场应对，没有需要记住的东西。
///
/// ⛔ 账号密码**不在库里**：在 secure storage（`webdav_cred_<sourceId>`）。库会随
/// 备份跨设备还原，凭据不该跟着走。
class MigrationV43LocalMediaWebDavSource extends Migration {
  @override
  int get version => 43;

  @override
  String get description => '本机文件：WebDAV 源（remote_state / tls_fingerprint）';

  @override
  void up(CommonDatabase db) {
    final existing = db
        .select('PRAGMA table_info(local_media_sources)')
        .map((row) => row['name'] as String)
        .toSet();
    for (final column in const ['remote_state', 'tls_fingerprint']) {
      if (existing.contains(column)) continue;
      db.execute('ALTER TABLE local_media_sources ADD COLUMN $column TEXT');
    }
    LogUtils.i('已应用迁移v43：WebDAV 源字段就位', 'MigrationV43');
  }
}
