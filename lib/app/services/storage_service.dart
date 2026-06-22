import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:i_iwara/utils/logger_utils.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  static const String _tag = 'StorageService';

  factory StorageService() => _instance;

  StorageService._internal();

  GetStorage? _box;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // 添加一个标志来跟踪是否使用安全存储
  bool _useSecureStorage = true;

  // 为安全数据添加前缀，以区分普通数据
  static const String _securePrefix = 'secure_';

  bool initialized = false;

  Future<void> init() async {
    if (initialized) return;

    try {
      await GetStorage.init();
      _box = GetStorage();

      if (kIsWeb) {
        _useSecureStorage = false;
        LogUtils.w('运行在 Web 上，不支持安全存储，将使用普通存储作为回退方案', _tag);
      } else {
        // 测试安全存储是否可用
        try {
          await _secureStorage.write(key: 'test_key', value: 'test_value');
          await _secureStorage.read(key: 'test_key');
          await _secureStorage.delete(key: 'test_key');
          _useSecureStorage = true;
          LogUtils.d('安全存储可用', _tag);

          // 迁移之前存储在普通存储中的安全数据
          await _migrateFallbackDataToSecureStorage();
        } catch (e) {
          _useSecureStorage = false;
          LogUtils.e('安全存储不可用，将使用普通存储作为回退方案', tag: _tag, error: e);
        }
      }

      initialized = true;
    } catch (e) {
      LogUtils.e('存储服务初始化失败', tag: _tag, error: e);
      rethrow;
    }
  }

  GetStorage get box {
    if (_box == null) {
      throw StateError('StorageService 未初始化');
    }
    return _box!;
  }

  /// 迁移之前存储在普通存储中的安全数据到真正的安全存储
  Future<void> _migrateFallbackDataToSecureStorage() async {
    try {
      final keys = box.getKeys();
      final allKeys = keys is Iterable ? keys.toList() : [keys];
      final secureKeys = allKeys
          .where((key) => key.toString().startsWith(_securePrefix))
          .toList();

      if (secureKeys.isEmpty) {
        LogUtils.d('没有需要迁移的安全数据', _tag);
        return;
      }

      LogUtils.i('开始迁移 ${secureKeys.length} 个安全数据项到真正的安全存储', _tag);

      int successCount = 0;
      for (final prefixedKey in secureKeys) {
        try {
          final keyString = prefixedKey.toString();
          // 获取原始 key（移除前缀）
          final originalKey = keyString.substring(_securePrefix.length);

          // 读取旧数据
          final value = box.read<String>(keyString);
          if (value != null) {
            // 写入到安全存储
            await _secureStorage.write(key: originalKey, value: value);

            // 删除旧数据
            await box.remove(keyString);

            successCount++;
            LogUtils.d('成功迁移: $originalKey', _tag);
          }
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
  /// 安全存储当前是否可用（写入/删除失败会将其置为不可用）。
  bool get isSecureStorageAvailable => _useSecureStorage;

  /// 测试专用：直接设置安全存储可用性（单例状态需在用例间复位）。
  @visibleForTesting
  void debugSetSecureStorageAvailable(bool value) {
    _useSecureStorage = value;
  }

  /// 尽力清空全部安全存储（登出时个别删除失败的兜底，HIGH#3）。
  Future<void> wipeSecureStorage() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      LogUtils.e('清空安全存储失败', tag: _tag, error: e);
    }
  }

  /// 写入安全数据。
  /// [allowPlaintextFallback] 为 false 时采用 fail-closed：安全存储不可用就**不**落普通存储，
  /// 用于 token 等敏感数据，避免明文降级(HIGH#1)。此时数据仅保留在内存(调用方持有)。
  Future<void> writeSecureData(
    String key,
    String value, {
    bool allowPlaintextFallback = true,
  }) async {
    if (_useSecureStorage) {
      try {
        await _secureStorage.write(key: key, value: value);
        // 安全写入成功后清掉可能残留的 fallback 副本，保持单一真相，
        // 避免日后被 readSecureData 当作待迁移数据迁回(HIGH#2)。
        if (_box != null) {
          try {
            await _box!.remove(_securePrefix + key);
          } catch (_) {}
        }
        return;
      } catch (e) {
        LogUtils.w('写入安全存储失败', _tag);
        _useSecureStorage = false;
      }
    }
    // 敏感数据 fail-closed：不写明文，仅内存会话(HIGH#1)。
    if (!allowPlaintextFallback) {
      LogUtils.w('安全存储不可用，按 fail-closed 跳过持久化: $key', _tag);
      return;
    }
    // 非敏感数据回退到普通存储（box 未初始化时跳过，避免抛错）
    if (_box != null) {
      await _box!.write(_securePrefix + key, value);
    } else {
      LogUtils.w('普通存储未初始化，跳过写入: $key', _tag);
    }
  }

  Future<String?> readSecureData(String key) async {
    if (_useSecureStorage) {
      try {
        final value = await _secureStorage.read(key: key);

        // 如果安全存储中没有数据，检查是否有回退数据需要迁移
        if (value == null) {
          final fallbackValue = _box?.read<String>(_securePrefix + key);
          if (fallbackValue != null) {
            LogUtils.d('发现回退数据，正在迁移: $key', _tag);
            // 迁移到安全存储
            await _secureStorage.write(key: key, value: fallbackValue);
            // 删除旧数据
            await _box?.remove(_securePrefix + key);
            return fallbackValue;
          }
        }

        return value;
      } on PlatformException catch (e) {
        if (e.message?.contains('BAD_DECRYPT') ?? false) {
          LogUtils.w('安全存储解密失败，正在清理所有数据', _tag);
          await _secureStorage.deleteAll();
        }
        LogUtils.w('读取安全存储失败，回退到普通存储', _tag);
        _useSecureStorage = false;
      } catch (e) {
        LogUtils.w('读取安全存储失败，回退到普通存储', _tag);
        _useSecureStorage = false;
      }
    }
    // 回退到普通存储（box 未初始化时返回 null，避免抛错）
    return _box?.read<String>(_securePrefix + key);
  }

  Future<void> deleteSecureData(String key) async {
    if (_useSecureStorage) {
      try {
        await _secureStorage.delete(key: key);
      } catch (e) {
        LogUtils.w('删除安全存储数据失败，回退到普通存储', _tag);
        _useSecureStorage = false;
      }
    }
    // 始终同时删除 fallback 副本：否则 readSecureData 在安全存储为空时
    // 会把它迁回安全存储，造成「登出后 token 复活」(HIGH#2)。
    if (_box != null) {
      try {
        await _box!.remove(_securePrefix + key);
      } catch (_) {}
    }
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
  /// 安全存储不可用时禁止持久化，避免明文降级(HIGH#3)。
  Future<void> writeRememberedUsername(String username) async {
    if (!_useSecureStorage) {
      LogUtils.w('安全存储不可用，跳过记住用户名以避免明文降级', _tag);
      await clearCredentials();
      return;
    }
    await writeSecureData('username', username);
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
