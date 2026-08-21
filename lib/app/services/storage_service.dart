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

/// 安全存储健康状态（诊断页展示用）。
enum SecureStorageHealth {
  /// 探测通过，正常使用 Keystore/Keychain。
  healthy,

  /// 检测到损坏数据并已清空自愈，本会话继续使用安全存储（旧数据已丢失）。
  recoveredAfterReset,

  /// 本会话不可用，敏感数据走降级加密兜底。
  unavailable,
}

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static const String _tag = 'StorageService';

  factory StorageService() => _instance;

  StorageService._internal();

  GetStorage? _box;
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

      LogUtils.i('开始迁移 ${secureKeys.length} 个安全数据副本到安全存储', _tag);

      int successCount = 0;
      for (final prefixedKey in secureKeys) {
        try {
          final keyString = prefixedKey.toString();
          final originalKey = keyString.substring(_securePrefix.length);

          final raw = box.read<String>(keyString);
          if (raw == null) continue;

          String? value;
          if (SecureFallbackCipher.isEnvelope(raw)) {
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

          await _secureStorage.write(key: originalKey, value: value);
          await box.remove(keyString);
          successCount++;
        } catch (e) {
          LogUtils.w('迁移数据失败: $prefixedKey', _tag);
        }
      }

      LogUtils.i('数据迁移完成: $successCount/${secureKeys.length} 成功', _tag);
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
  /// [fallback] 为 [SecureWriteFallback.encrypted]（默认）时，安全存储不可用
  /// 则降级为本地密钥 AES-GCM 加密后写普通存储——绝不落明文（延续 HIGH#1 的
  /// 无明文原则，同时保住坏 Keystore 设备的登录持久化）；为 none 时跳过持久化。
  Future<SecureWriteResult> writeSecureData(
    String key,
    String value, {
    SecureWriteFallback fallback = SecureWriteFallback.encrypted,
  }) async {
    if (_useSecureStorage) {
      try {
        await _secureStorage.write(key: key, value: value);
        if (secureStorageUntrusted &&
            fallback == SecureWriteFallback.encrypted) {
          // 双写保护：该设备发生过静默丢失，兜底副本常备。
          await _writeEncryptedFallback(key, value);
        } else {
          // 安全写入成功后清掉残留副本，保持单一真相(HIGH#2)。
          await _removeFallbackCopy(key);
        }
        return SecureWriteResult.secure;
      } catch (e) {
        // 损坏特征 → 清空自愈并重试一次，安全存储保持启用。
        if (await _tryHealCorruption(e, 'write:$key')) {
          try {
            await _secureStorage.write(key: key, value: value);
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
    } catch (_) {}
  }

  Future<String?> readSecureData(String key) async {
    if (_useSecureStorage) {
      try {
        final value = await _secureStorage.read(key: key);
        if (value != null) return value;
        // 安全存储无此数据 → 尝试降级副本（健康且可信时迁移回安全存储）。
        return await _readFallback(
          key,
          migrateToSecure: !secureStorageUntrusted,
        );
      } catch (e) {
        // 损坏特征 → 清空自愈，本条数据尝试从降级副本恢复；
        // 修复点：自愈成功后安全存储保持启用（原实现自愈完仍整会话降级）。
        if (await _tryHealCorruption(e, 'read:$key')) {
          return await _readFallback(
            key,
            migrateToSecure: !secureStorageUntrusted,
          );
        }
        _disableSecureStorage(e, 'read:$key');
        return await _readFallback(key, migrateToSecure: false);
      }
    }
    return await _readFallback(key, migrateToSecure: false);
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
        await _removeFallbackCopy(key);
        LogUtils.d('降级副本已迁移至安全存储: $key', _tag);
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

  Future<void> writeSecureObject(String key, Map<String, dynamic> value) async {
    final string = json.encode(value);
    await writeSecureData(key, string);
  }

  Future<Map<String, dynamic>?> readSecureObject(String key) async {
    try {
      final string = await readSecureData(key);
      if (string == null) return null;
      return json.decode(string) as Map<String, dynamic>;
    } catch (e) {
      LogUtils.e('读取安全存储对象失败', tag: _tag, error: e);
      return null;
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
