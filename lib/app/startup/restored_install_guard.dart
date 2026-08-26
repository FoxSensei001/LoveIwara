import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 这次启动面对的是「什么样的一份数据」。
enum InstallOrigin {
  /// 安装标记还在——正常的一次启动（包括升级、包括平常的冷启动）。
  normal,

  /// 标记不在，配置里也没说写过：全新安装，或从「还没有标记机制的旧版本」升上来。
  /// 这两种都不该动任何一次性标记，只补写标记。
  unmarked,

  /// 标记不在，可配置却记得这次安装写过标记——数据是从备份还原 / 换机搬过来的。
  restored,
}

/// 识别「配置是从备份还原来的」，并把一次性引导复位。
///
/// # 为什么需要它
///
/// 配置全部存在 `app_flutter/i_iwara/i_iwara.db` 的 `app_config` 表里，而
/// Android 的自动备份（`android:allowBackup` 默认 true）会把它整个带走：卸载重装
/// 或换机之后，`first_time_setup_completed`、`glass_material_intro_shown` 原样
/// 回来，于是**首次引导和玻璃质感提醒双双不再出现**——用户看到的是一台"全新装好
/// 却已经设置过"的应用。更别扭的是登录态被 `backup_rules.xml` 排除在备份之外
/// （Keystore 密文跨设备解不开），所以还原回来的是"设置都在、人却没登录"。
///
/// # 怎么判定
///
/// 在**不参与备份**的目录里放一个标记文件（`backup_rules.xml` /
/// `data_extraction_rules.xml` 里显式 exclude 掉它）。于是：
///
///   - 标记在  → 正常启动。
///   - 标记不在，且配置说"这次安装从来没写过标记" → 全新安装，或者从旧版本升上来
///     的老用户（他们的库里当然没有这个新字段）。**什么都不复位**，只补写标记。
///     这一条是整个设计的关键：不能拿"标记不在"直接当还原，否则所有老用户在升级到
///     本版本的那一次都会被重新扔进引导页。
///   - 标记不在，但配置说写过 → 文件没了、数据还在，只有备份还原能造出这种组合。
///
/// 桌面端没有这套备份机制，标记会一直跟着配置一起留在本机，判定恒为 [normal]
/// ——桌面上"卸载重装后设置还在"本来就是预期行为，这里不去改它。
class RestoredInstallGuard {
  RestoredInstallGuard._();

  static const String _tag = 'RestoredInstallGuard';

  /// 标记文件名。改名字要同步改两份 Android 备份规则里的 exclude 路径，
  /// 否则标记会跟着备份一起还原，判定永远是 [InstallOrigin.normal]。
  static const String markerFileName = 'install_marker';

  /// 纯判断：拿这两个事实，这份数据算什么来路。抽出来是为了能单测——
  /// 真实链路要 path_provider + 数据库，单测里搭不起来。
  @visibleForTesting
  static InstallOrigin classify({
    required bool markerExists,
    required bool markerIssued,
  }) {
    if (markerExists) return InstallOrigin.normal;
    return markerIssued ? InstallOrigin.restored : InstallOrigin.unmarked;
  }

  /// 启动时跑一次（`ConfigService` 就绪之后、路由守卫读到那些标记之前）。
  ///
  /// 返回这次识别出的来路，方便调用方 / 测试断言；失败一律吞掉并返回
  /// [InstallOrigin.normal]——识别不出来时宁可少问一次，也不能把人关进引导页。
  static Future<InstallOrigin> reconcile(
    ConfigService config, {
    Directory? markerDirOverride,
  }) async {
    try {
      final Directory dir =
          markerDirOverride ?? await getApplicationSupportDirectory();
      return await reconcileIn(
        markerDir: dir,
        markerIssued: config[ConfigKey.INSTALL_MARKER_ISSUED] == true,
        setFlag: (key, value) => config.setSetting(key, value),
      );
    } catch (e, s) {
      LogUtils.e('还原安装识别失败，按正常启动处理', tag: _tag, error: e, stackTrace: s);
      return InstallOrigin.normal;
    }
  }

  /// [reconcile] 的本体，把「配置怎么读写」和「标记放在哪」都交给调用方，
  /// 于是不需要真的 `ConfigService`（它要一个打开的数据库）就能测。
  @visibleForTesting
  static Future<InstallOrigin> reconcileIn({
    required Directory markerDir,
    required bool markerIssued,
    required Future<void> Function(ConfigKey key, bool value) setFlag,
  }) async {
    try {
      final File marker = File(p.join(markerDir.path, markerFileName));
      final bool markerExists = await marker.exists();

      final InstallOrigin origin = classify(
        markerExists: markerExists,
        markerIssued: markerIssued,
      );
      if (origin == InstallOrigin.normal) {
        // 标记在、配置却说没写过。正常流程走不到这里，但用户导入过一份**老的**
        // 配置备份（ConfigBackupService）就会把这个字段冲回 false。把账补上，
        // 否则下一次真的还原会被误判成 unmarked、一次性引导不再复位。
        if (!markerIssued) {
          await setFlag(ConfigKey.INSTALL_MARKER_ISSUED, true);
        }
        return origin;
      }

      // 先把标记补上：写不成功就不复位任何东西，否则一旦这台机器写文件长期失败，
      // 每次启动都会重新判定成"还原"，用户会被永远关在引导页里。
      try {
        if (!await markerDir.exists()) {
          await markerDir.create(recursive: true);
        }
        await marker.writeAsString(
          'i_iwara install marker\n',
          flush: true,
        );
      } catch (e, s) {
        LogUtils.e(
          '写安装标记失败，本次不做还原判定（下次启动再试）: ${marker.path}',
          tag: _tag,
          error: e,
          stackTrace: s,
        );
        return InstallOrigin.normal;
      }

      if (!markerIssued) {
        await setFlag(ConfigKey.INSTALL_MARKER_ISSUED, true);
      }

      if (origin == InstallOrigin.restored) {
        // 数据是搬过来的：一次性引导按"新装"重来一遍。这里只复位"问没问过"，
        // 不动用户任何真实设置（收藏、下载、主题、玻璃开关本身都原样保留）。
        await setFlag(ConfigKey.FIRST_TIME_SETUP_COMPLETED, false);
        await setFlag(ConfigKey.GLASS_MATERIAL_INTRO_SHOWN, false);
        LogUtils.i(
          '识别为备份还原的安装：首次引导 / 玻璃质感提醒已复位，本次启动会重新走一遍引导',
          _tag,
        );
      } else {
        LogUtils.i('已补写安装标记（全新安装或首次升级到带标记的版本）: ${marker.path}', _tag);
      }

      return origin;
    } catch (e, s) {
      LogUtils.e('还原安装识别失败，按正常启动处理', tag: _tag, error: e, stackTrace: s);
      return InstallOrigin.normal;
    }
  }
}
