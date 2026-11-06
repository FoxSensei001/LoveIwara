import 'package:get_storage/get_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:i_iwara/app/services/secure_fallback_cipher.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 安全存储不可用时的降级策略。
enum SecureWriteFallback {
  /// 不降级：安全存储不可用时放弃持久化（仅内存会话）。
  none,

  /// 降级为「本地密钥 AES-GCM 加密」后写入普通存储。
  /// 机密性弱于 Keystore（密钥在应用沙箱内），但绝不落明文；
  /// 密钥文件被排除在系统备份之外，备份/换机导出的密文不可解。
  encrypted,
}

/// 一次安全写入实际落到的位置。
enum SecureWriteResult { secure, encryptedFallback, skipped }

/// 一次安全读取的结局。
///
/// `null` 一个值表达不了两件完全相反的事：**这台设备上确实没有这条数据**
/// （全新安装、备份还原后密钥没跟过来）与**这条数据读不出来**（Keystore
/// 瞬时异常、密文损坏、JSON 解不开）。调用方按前者做"没有就当没开过"的
/// 兜底时，后者会被一起吞掉——应用锁因此在 Keystore 抽风的那次启动直接
/// 变成未锁状态（fail-open）。
enum SecureReadStatus {
  /// 读到了合法数据。
  found,

  /// 安全存储与降级副本里都没有这个键。
  missing,

  /// 读取过程出错 / 数据损坏。**不能**当作"没有"。
  failed,
}

/// [StorageService.readSecureDataDetailed] 的返回值。
class SecureReadResult<T> {
  const SecureReadResult.found(this.value)
    : status = SecureReadStatus.found,
      error = null;
  const SecureReadResult.missing()
    : status = SecureReadStatus.missing,
      value = null,
      error = null;
  const SecureReadResult.failed(this.error)
    : status = SecureReadStatus.failed,
      value = null;

  final SecureReadStatus status;
  final T? value;
  final Object? error;

  bool get isFound => status == SecureReadStatus.found;
  bool get isMissing => status == SecureReadStatus.missing;
  bool get isFailed => status == SecureReadStatus.failed;
}

/// 安全存储健康状态（诊断页展示用）。
enum SecureStorageHealth {
  /// 探测通过，正常使用 Keystore/Keychain。
  healthy,

  /// 检测到损坏数据并已清空自愈，本会话继续使用安全存储（旧数据已丢失）。
  recoveredAfterReset,

  /// 本会话不可用，敏感数据走降级加密兜底。
  unavailable,

  /// 按平台策略主动不使用系统安全存储（**非故障**），敏感数据走本地加密兜底。
  /// 与 [unavailable] 的区别是「不是坏了，是不用」——诊断页不该因此报红。
  platformOptOut,
}

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static const String _tag = 'StorageService';

  factory StorageService() => _instance;

  StorageService._internal();

  GetStorage? _box;
  // macOS 上这个实例不会被使用，原因见 init() 里的平台分支。
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SecureFallbackCipher _fallbackCipher = SecureFallbackCipher();

  // 安全存储是否可用（不可恢复的读写失败会将其置为不可用）
  bool _useSecureStorage = true;
  SecureStorageHealth _health = SecureStorageHealth.healthy;
  String? _lastSecureError;

  // 为安全数据的普通存储副本（降级加密/历史明文遗留）添加前缀
  static const String _securePrefix = 'secure_';

  // 设备被标记为「安全存储不可信」后启用双写保护（持久化在普通存储，
  // 由 TokenManager 的静默丢失检测触发）。
  static const String _untrustedFlagKey = 'secure_storage_untrusted';

  // 「这份加密镜像与安全存储同步过」的标记，按键记。⛔ 前缀不能以 secure_ 开头，
  // 否则会被当成副本扫进迁移。
  //
  // 有标记＝安全存储写成功时顺手写的镜像，只是备份，安全存储为准；
  // 没标记＝降级会话里只写进了普通存储的新值（或升级前遗留的降级副本），
  // 它比安全存储新，启动迁移时要以它为准。分不清这两种，降级期间切的号、
  // 改的 PIN、登出墓碑都会在下次启动被安全存储里的旧值回滚。
  static const String _mirrorSyncedPrefix = 'fbsync_';

  /// 安全写成功时是否也常备加密镜像。只在安卓：要治的是安卓 Keystore 冷启动
  /// 静默丢数据。iOS 钥匙串、Windows DPAPI 本身可靠，而镜像所在的普通存储
  /// 会进 iCloud / 本地备份 / 网盘同步，密钥文件也在一起，机密性反而变弱。
  static bool get _mirrorWhileSecure =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  // 本次启动里，安全存储缺失、靠加密镜像/降级副本读回来的键。
  // TokenManager 据此记「静默丢失」：镜像救回了登录，但丢失本身仍要留证据。
  final Set<String> _restoredFromFallback = <String>{};

  /// 本次启动里 [key] 是否因安全存储缺失而从普通存储副本读回。
  bool wasRestoredFromFallback(String key) =>
      _restoredFromFallback.contains(key);

  // v10 插件在密钥不匹配/数据损坏时抛出的特征串（转小写匹配）。
  // 刻意不包含笼统的 'keystore'——避免把瞬时故障误判为损坏而清空真实数据。
  static const List<String> _corruptionSignatures = [
    'bad_decrypt',
    'unwrap',
    'badpadding',
    'aeadbadtag',
    'invalid key',
    'invalidkey',
    'key mismatch',
    'unrecoverable',
    'algorithm change',
  ];

  bool initialized = false;

  Future<void> init() async {
    if (initialized) return;

    try {
      await GetStorage.init();
      _box = GetStorage();

      if (kIsWeb) {
        _useSecureStorage = false;
        _health = SecureStorageHealth.unavailable;
        _lastSecureError = 'Web 平台不支持安全存储';
        LogUtils.w('运行在 Web 上，不支持安全存储', _tag);
      } else if (defaultTargetPlatform == TargetPlatform.macOS) {
        // macOS 主动不用系统钥匙串，这是权衡后的选择，不是故障：
        //
        // - 插件默认走 data protection keychain，要求 keychain-access-groups
        //   entitlement，而带该 entitlement 的 target 必须用开发证书签名；本项目
        //   桌面包是 ad-hoc 签名分发的（见 macos/packaging/build_dmg.sh），加了
        //   构建直接失败，不加则运行期报 -34018，安全存储整只降级。
        // - 改走传统 file-based keychain 虽然能用，但钥匙串按代码签名认程序，
        //   而 ad-hoc 签名每次构建/每次发版哈希都变，于是系统反复弹「想要访问
        //   钥匙串」要求输密码——实测体验比不用还差，故放弃。
        //
        // 因此 macOS 直接走 AES-256-GCM 本地兜底（密钥在应用私有目录、排除系统
        // 备份）。等将来有了 Developer ID 证书稳定签名，可以把这个分支去掉。
        _useSecureStorage = false;
        _health = SecureStorageHealth.platformOptOut;
        LogUtils.i('macOS 按平台策略不使用系统钥匙串，敏感数据走本地加密兜底', _tag);
      } else {
        await _initSecureStorageWithSelfHeal();
      }

      initialized = true;
    } catch (e) {
      LogUtils.e('存储服务初始化失败', tag: _tag, error: e);
      rethrow;
    }
  }

  /// 探测安全存储；失败且符合损坏特征时清空自愈并重试一次。
  /// 换机/备份还原会留下「Keystore 私钥已丢、密文还在」的坏状态，
  /// 不清理的话每次启动都失败，安全存储永久瘫痪。
  Future<void> _initSecureStorageWithSelfHeal() async {
    try {
      await _probeSecureStorage();
      _useSecureStorage = true;
      _health = SecureStorageHealth.healthy;
      LogUtils.d('安全存储可用', _tag);

      // 迁移普通存储中的降级副本/历史明文（设备不可信时保留双份，不迁移）
      if (!secureStorageUntrusted) {
        await _migrateFallbackDataToSecureStorage();
      }
      return;
    } catch (e) {
      _lastSecureError = e.toString();
      LogUtils.e('安全存储探测失败', tag: _tag, error: e);

      if (_looksLikeCorruption(e)) {
        LogUtils.w('探测失败符合数据损坏特征，尝试清空自愈', _tag);
        try {
          await _secureStorage.deleteAll();
          await _probeSecureStorage();
          _useSecureStorage = true;
          _health = SecureStorageHealth.recoveredAfterReset;
          LogUtils.i('安全存储清空自愈成功，本会话恢复使用（旧数据已丢失）', _tag);
          return;
        } catch (e2) {
          _lastSecureError = e2.toString();
          LogUtils.e('清空自愈后仍不可用', tag: _tag, error: e2);
        }
      }

      _useSecureStorage = false;
      _health = SecureStorageHealth.unavailable;
      LogUtils.w('安全存储不可用，敏感数据将走降级加密兜底', _tag);
    }
  }

  Future<void> _probeSecureStorage() async {
    await _secureStorage.write(key: 'test_key', value: 'test_value');
    final value = await _secureStorage.read(key: 'test_key');
    await _secureStorage.delete(key: 'test_key');
    if (value != 'test_value') {
      throw StateError('安全存储探测读回值不一致: $value');
    }
  }

  bool _looksLikeCorruption(Object e) {
    final s = e.toString().toLowerCase();
    return _corruptionSignatures.any(s.contains);
  }

  /// 检测到损坏时清空自愈。成功返回 true（安全存储保持启用）。
  Future<bool> _tryHealCorruption(Object error, String context) async {
    if (!_looksLikeCorruption(error)) return false;
    try {
      await _secureStorage.deleteAll();
      _health = SecureStorageHealth.recoveredAfterReset;
      LogUtils.w('安全存储数据损坏($context)，已清空自愈，本会话继续使用', _tag);
      return true;
    } catch (e) {
      LogUtils.e('清空自愈失败($context)', tag: _tag, error: e);
      return false;
    }
  }

  void _disableSecureStorage(Object error, String context) {
    _lastSecureError = error.toString();
    _useSecureStorage = false;
    _health = SecureStorageHealth.unavailable;
    LogUtils.w('安全存储不可用($context)，本会话降级: $error', _tag);
  }

  GetStorage get box {
    if (_box == null) {
      throw StateError('StorageService 未初始化');
    }
    return _box!;
  }

  /// 普通存储的可空访问器：供未初始化场景（如单测）下的调用方安全使用。
  GetStorage? get boxOrNull => _box;

  /// 迁移普通存储中的安全数据副本（降级加密封皮或历史明文）到安全存储。
  Future<void> _migrateFallbackDataToSecureStorage() async {
    try {
      final keys = box.getKeys();
      final allKeys = keys is Iterable ? keys.toList() : [keys];
      final secureKeys = allKeys
          .where((key) => key.toString().startsWith(_securePrefix))
          .toList();

      if (secureKeys.isEmpty) return;

      LogUtils.d('检查 ${secureKeys.length} 个安全数据副本', _tag);

      int successCount = 0;
      for (final prefixedKey in secureKeys) {
        try {
          final keyString = prefixedKey.toString();
          final originalKey = keyString.substring(_securePrefix.length);

          final raw = box.read<String>(keyString);
          if (raw == null) continue;

          String? value;
          final isEnvelope = SecureFallbackCipher.isEnvelope(raw);
          // 同步过的镜像只是备份：启动时不动它（也省掉逐个读 Keystore）。
          // 安全存储真缺这条时，读取路径会从镜像读回并写回安全存储。
          if (isEnvelope &&
              box.read<bool>(_mirrorSyncedKey(originalKey)) == true) {
            continue;
          }
          if (isEnvelope) {
            value = await _fallbackCipher.decrypt(raw);
            if (value == null) {
              // 密钥已丢（如换机后密文被还原而密钥没有）：僵尸数据，清理。
              await box.remove(keyString);
              LogUtils.w('降级副本不可解，已清理: $originalKey', _tag);
              continue;
            }
          } else {
            value = raw; // 历史明文遗留
          }

          // 没同步标记的副本比安全存储新（降级会话的写入 / 历史明文）：以它为准。
          await _secureStorage.write(key: originalKey, value: value);
          if (isEnvelope && _mirrorWhileSecure) {
            // 现在两边一致了，镜像留作常备备份(治根因A)。
            await _markMirrorSynced(originalKey);
          } else {
            await _removeFallbackCopy(originalKey);
          }
          successCount++;
        } catch (e) {
          LogUtils.w('迁移数据失败: $prefixedKey', _tag);
        }
      }

      if (successCount > 0) {
        LogUtils.i('降级副本已写回安全存储: $successCount 个', _tag);
      }
    } catch (e) {
      LogUtils.e('数据迁移过程出错', tag: _tag, error: e);
    }
  }

  //==================== 非安全存储 ====================
  @Deprecated('Use [CommonDatabase] instead')
  Future<void> writeData(String key, dynamic value) async {
    await box.write(key, value);
  }

  @Deprecated('Use [CommonDatabase] instead')
  T? readData<T>(String key) {
    return box.read<T>(key);
  }

  @Deprecated('Use [CommonDatabase] instead')
  Future<void> deleteData(String key) async {
    await box.remove(key);
  }

  @Deprecated('Use [CommonDatabase] instead')
  Future<void> clearAll() async {
    await box.erase();
    if (_useSecureStorage) {
      try {
        await _secureStorage.deleteAll();
      } catch (e) {
        LogUtils.e('清除安全存储失败', tag: _tag, error: e);
      }
    }
  }

  //==================== 安全存储 ====================
  /// 安全存储当前是否可用（不可恢复的读写失败会将其置为不可用）。
  bool get isSecureStorageAvailable => _useSecureStorage;

  /// 安全存储健康状态与最近一次错误（诊断页展示）。
  SecureStorageHealth get secureStorageHealth =>
      kIsWeb ? SecureStorageHealth.unavailable : _health;
  String? get secureStorageLastError => _lastSecureError;

  /// 设备是否被标记为「安全存储不可信」（发生过 token 静默丢失，
  /// 敏感数据双写安全存储 + 降级加密兜底）。
  bool get secureStorageUntrusted =>
      _box?.read<bool>(_untrustedFlagKey) ?? false;

  /// 标记本设备安全存储不可信，此后敏感写入启用双写保护。
  /// 针对「探测正常、但 Keystore 密钥跨进程重启失效被插件静默清空」的机型。
  Future<void> markSecureStorageUntrusted(String reason) async {
    if (secureStorageUntrusted) return;
    LogUtils.w('安全存储被标记为不可信($reason)，启用双写保护', _tag);
    await _box?.write(_untrustedFlagKey, true);
  }

  /// 测试专用：直接设置安全存储可用性（单例状态需在用例间复位）。
  @visibleForTesting
  void debugSetSecureStorageAvailable(bool value) {
    _useSecureStorage = value;
    _health = value
        ? SecureStorageHealth.healthy
        : SecureStorageHealth.unavailable;
  }

  /// 测试专用：注入降级加密器（隔离密钥文件位置）。
  @visibleForTesting
  set debugFallbackCipher(SecureFallbackCipher cipher) {
    _fallbackCipher = cipher;
  }

  /// 测试专用：跑一遍启动时的副本迁移（正常只在 init 探测通过后跑）。
  @visibleForTesting
  Future<void> debugRunStartupMigration() =>
      _migrateFallbackDataToSecureStorage();

  /// 测试专用：注入普通存储 box。
  @visibleForTesting
  set debugBox(GetStorage? value) {
    _box = value;
  }

  /// 尽力清空全部安全存储（登出时个别删除失败的兜底，HIGH#3）。
  Future<void> wipeSecureStorage() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      LogUtils.e('清空安全存储失败', tag: _tag, error: e);
    }
  }

  /// 写入安全数据，返回实际落盘位置。
  ///
  /// [fallback] 为 [SecureWriteFallback.encrypted]（默认）时：安全存储可用也会
  /// **主动常备一份本地密钥 AES-GCM 加密镜像**（治根因A：坏/间歇 Keystore 设备
  /// 从首次保存起即可冷启动恢复登录，不必等「连续 2 次静默丢失」才反应式武装）；
  /// 安全存储不可用则以该加密镜像兜底——绝不落明文（延续 HIGH#1 无明文原则）。
  /// 为 none 时不留镜像、安全存储不可用即跳过持久化。
  Future<SecureWriteResult> writeSecureData(
    String key,
    String value, {
    SecureWriteFallback fallback = SecureWriteFallback.encrypted,
  }) async {
    // 重新写入后这条就不再是「从副本读回」的了。
    _restoredFromFallback.remove(key);
    // 加密兜底键（token 等）安全写入成功后仍主动常备一份加密兜底镜像，
    // 使坏/间歇 Keystore 设备从「首次保存」起就能在冷启动恢复登录，
    // 不必等连续 2 次静默丢失才「反应式」武装(治根因A：反应式双写形同虚设)。
    // 镜像为 AES-256-GCM + 应用沙箱密钥 + 已排除系统备份，无机密性回退。
    // 非安卓平台只在设备被标记不可信（发生过静默丢失）后才双写，与原先一致。
    final keepEncryptedFallback =
        fallback == SecureWriteFallback.encrypted &&
        (_mirrorWhileSecure || secureStorageUntrusted);

    if (_useSecureStorage) {
      try {
        await _secureStorage.write(key: key, value: value);
        await _syncFallbackAfterSecureWrite(
          key,
          value,
          keep: keepEncryptedFallback,
        );
        return SecureWriteResult.secure;
      } catch (e) {
        // 损坏特征 → 清空自愈并重试一次，安全存储保持启用。
        if (await _tryHealCorruption(e, 'write:$key')) {
          try {
            await _secureStorage.write(key: key, value: value);
            await _syncFallbackAfterSecureWrite(
              key,
              value,
              keep: keepEncryptedFallback,
            );
            return SecureWriteResult.secure;
          } catch (e2) {
            _disableSecureStorage(e2, 'write-after-heal:$key');
          }
        } else {
          _disableSecureStorage(e, 'write:$key');
        }
      }
    }

    if (fallback == SecureWriteFallback.none) {
      LogUtils.w('安全存储不可用，按 fail-closed 跳过持久化: $key', _tag);
      return SecureWriteResult.skipped;
    }

    if (await _writeEncryptedFallback(key, value)) {
      // 只写进了普通存储：它比安全存储新，撤掉同步标记，下次启动以它为准。
      await _clearMirrorSynced(key);
      return SecureWriteResult.encryptedFallback;
    }
    LogUtils.w('降级加密不可用，跳过持久化（不落明文）: $key', _tag);
    return SecureWriteResult.skipped;
  }

  Future<bool> _writeEncryptedFallback(String key, String value) async {
    if (_box == null) return false;
    try {
      final envelope = await _fallbackCipher.encrypt(value);
      if (envelope == null) return false;
      await _box!.write(_securePrefix + key, envelope);
      return true;
    } catch (e) {
      LogUtils.w('写入降级加密副本失败: $key ($e)', _tag);
      return false;
    }
  }

  Future<void> _removeFallbackCopy(String key) async {
    if (_box == null) return;
    try {
      await _box!.remove(_securePrefix + key);
      await _box!.remove(_mirrorSyncedKey(key));
    } catch (_) {}
  }

  /// 安全写入成功后同步降级镜像(治根因A)：
  /// - [keep]=true（加密兜底键，如 token）：主动写一份加密兜底常备镜像，
  ///   使坏/间歇 Keystore 设备从首次保存起即可在冷启动恢复登录；
  /// - [keep]=false：清掉任何残留副本，保持单一真相(HIGH#2)。
  Future<void> _syncFallbackAfterSecureWrite(
    String key,
    String value, {
    required bool keep,
  }) async {
    if (keep && await _writeEncryptedFallback(key, value)) {
      await _markMirrorSynced(key);
      return;
    }
    // 不留镜像，或镜像没写成：删掉旧镜像。宁可没有，也别留一份落后的——
    // 哪天安全存储丢了，落后的镜像会把上一个账号 / 旧 PIN 读回来。
    await _removeFallbackCopy(key);
  }

  String _mirrorSyncedKey(String key) => _mirrorSyncedPrefix + key;

  Future<void> _markMirrorSynced(String key) async {
    try {
      await _box?.write(_mirrorSyncedKey(key), true);
    } catch (_) {}
  }

  Future<void> _clearMirrorSynced(String key) async {
    try {
      await _box?.remove(_mirrorSyncedKey(key));
    } catch (_) {}
  }

  Future<String?> readSecureData(String key) async {
    return (await readSecureDataDetailed(key)).value;
  }

  /// 与 [readSecureData] 同一条链路，但把"没有"和"读不出来"分开告诉调用方。
  ///
  /// 只有真正需要 fail-closed 的调用方（应用锁凭据）才要用它；其余场景
  /// 继续用 [readSecureData]，行为完全不变。
  Future<SecureReadResult<String>> readSecureDataDetailed(String key) async {
    if (_useSecureStorage) {
      Object? readError;
      try {
        final value = await _secureStorage.read(key: key);
        if (value != null) return SecureReadResult.found(value);
        // 安全存储无此数据 → 尝试降级副本（健康且可信时迁移回安全存储）。
        final restored = await _readFallback(
          key,
          migrateToSecure: !secureStorageUntrusted,
        );
        if (restored != null) _restoredFromFallback.add(key);
        return _fallbackResult(restored);
      } catch (e) {
        readError = e;
        // 损坏特征 → 清空自愈，本条数据尝试从降级副本恢复；
        // 修复点：自愈成功后安全存储保持启用（原实现自愈完仍整会话降级）。
        if (await _tryHealCorruption(e, 'read:$key')) {
          final healed = await _readFallback(
            key,
            migrateToSecure: !secureStorageUntrusted,
          );
          // 自愈会把安全存储整个清空——降级副本里没有的话，这条数据是被
          // 我们自己删掉的，不是"这台设备上从来没有过"。
          if (healed != null) return SecureReadResult.found(healed);
          return SecureReadResult.failed(readError);
        }
        _disableSecureStorage(e, 'read:$key');
        final fallback = await _readFallback(key, migrateToSecure: false);
        if (fallback != null) return SecureReadResult.found(fallback);
        return SecureReadResult.failed(readError);
      }
    }
    return _fallbackResult(await _readFallback(key, migrateToSecure: false));
  }

  SecureReadResult<String> _fallbackResult(String? value) {
    return value == null
        ? const SecureReadResult<String>.missing()
        : SecureReadResult<String>.found(value);
  }

  /// 读取普通存储中的副本：降级加密封皮（enc1:）或历史明文遗留。
  /// [migrateToSecure] 为 true 且安全存储可用时迁移回安全存储并删除副本。
  Future<String?> _readFallback(
    String key, {
    required bool migrateToSecure,
  }) async {
    final raw = _box?.read<String>(_securePrefix + key);
    if (raw == null) return null;

    String value;
    final isEnvelope = SecureFallbackCipher.isEnvelope(raw);
    if (isEnvelope) {
      final decrypted = await _fallbackCipher.decrypt(raw);
      if (decrypted == null) {
        // 密钥丢失/数据损坏：僵尸密文，清理并按无数据处理。
        await _removeFallbackCopy(key);
        return null;
      }
      value = decrypted;
    } else {
      value = raw;
    }

    if (migrateToSecure && _useSecureStorage) {
      try {
        await _secureStorage.write(key: key, value: value);
        // 加密封皮在安卓上是常备镜像(治根因A)：写回安全存储后保留并标为已同步，
        // 下次冷启动 Keystore 再次静默丢失时仍可恢复；其余情况删掉副本。
        if (isEnvelope && _mirrorWhileSecure) {
          await _markMirrorSynced(key);
        } else {
          await _removeFallbackCopy(key);
        }
        LogUtils.d('降级副本已同步至安全存储: $key', _tag);
      } catch (_) {
        // 迁移失败保留副本，下次再试。
      }
    } else if (!isEnvelope) {
      // 历史明文遗留且暂时无法迁移：就地升级为加密封皮，消除明文。
      final envelope = await _fallbackCipher.encrypt(value);
      if (envelope != null && _box != null) {
        try {
          await _box!.write(_securePrefix + key, envelope);
        } catch (_) {}
      }
    }
    return value;
  }

  Future<void> deleteSecureData(String key) async {
    _restoredFromFallback.remove(key);
    if (_useSecureStorage) {
      try {
        await _secureStorage.delete(key: key);
      } catch (e) {
        if (!await _tryHealCorruption(e, 'delete:$key')) {
          _disableSecureStorage(e, 'delete:$key');
        }
      }
    }
    // 始终同时删除降级副本：否则安全存储为空时读取会把它当有效数据返回，
    // 造成「登出后 token 复活」(HIGH#2)。
    await _removeFallbackCopy(key);
  }

  Future<SecureWriteResult> writeSecureObject(
    String key,
    Map<String, dynamic> value,
  ) async {
    final string = json.encode(value);
    return writeSecureData(key, string);
  }

  Future<Map<String, dynamic>?> readSecureObject(String key) async {
    return (await readSecureObjectDetailed(key)).value;
  }

  /// [readSecureObject] 的分状态版本，见 [SecureReadResult]。
  ///
  /// JSON 解不开算 [SecureReadStatus.failed]（数据在，只是坏了），不是
  /// [SecureReadStatus.missing]。
  Future<SecureReadResult<Map<String, dynamic>>> readSecureObjectDetailed(
    String key,
  ) async {
    final raw = await readSecureDataDetailed(key);
    switch (raw.status) {
      case SecureReadStatus.missing:
        return const SecureReadResult<Map<String, dynamic>>.missing();
      case SecureReadStatus.failed:
        LogUtils.e('读取安全存储对象失败', tag: _tag, error: raw.error);
        return SecureReadResult<Map<String, dynamic>>.failed(raw.error);
      case SecureReadStatus.found:
        try {
          return SecureReadResult<Map<String, dynamic>>.found(
            json.decode(raw.value!) as Map<String, dynamic>,
          );
        } catch (e) {
          LogUtils.e('安全存储对象解析失败', tag: _tag, error: e);
          return SecureReadResult<Map<String, dynamic>>.failed(e);
        }
    }
  }

  /// 记住用户名（仅用于登录页预填）。不再保存密码 —— 持久登录依赖 refresh token。
  /// 安全存储不可用时走降级加密兜底，绝不落明文(HIGH#3)。
  Future<void> writeRememberedUsername(String username) async {
    final result = await writeSecureData('username', username);
    if (result == SecureWriteResult.skipped) {
      LogUtils.w('用户名未能持久化（安全存储与降级加密均不可用）', _tag);
    }
    // 清除任何历史遗留的明文密码。
    await deleteSecureData('password');
  }

  Future<String?> readRememberedUsername() async {
    return readSecureData('username');
  }

  Future<void> clearCredentials() async {
    await deleteSecureData('username');
    // 'password' 为历史遗留键，始终一并清除。
    await deleteSecureData('password');
  }
}
