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
  Future<void> writeSecureData(String key, String value) async {
    if (_useSecureStorage) {
      try {
        await _secureStorage.write(key: key, value: value);
        return;
      } catch (e) {
        LogUtils.w('写入安全存储失败，回退到普通存储', _tag);
        _useSecureStorage = false;
      }
    }
    // 回退到普通存储
    await box.write(_securePrefix + key, value);
  }

  Future<String?> readSecureData(String key) async {
    if (_useSecureStorage) {
      try {
        return await _secureStorage.read(key: key);
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
    // 回退到普通存储
    return box.read<String>(_securePrefix + key);
  }

  Future<void> deleteSecureData(String key) async {
    if (_useSecureStorage) {
      try {
        await _secureStorage.delete(key: key);
        return;
      } catch (e) {
        LogUtils.w('删除安全存储数据失败，回退到普通存储', _tag);
        _useSecureStorage = false;
      }
    }
    // 回退到普通存储
    await box.remove(_securePrefix + key);
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

  Future<void> writeCredentials(String username, String password) async {
    await writeSecureData('username', username);
    await writeSecureData('password', password);
  }

  Future<Map<String, String>?> readCredentials() async {
    final username = await readSecureData('username');
    final password = await readSecureData('password');
    if (username != null && password != null) {
      return {'username': username, 'password': password};
    }
    return null;
  }

  Future<void> clearCredentials() async {
    await deleteSecureData('username');
    await deleteSecureData('password');
  }

}
