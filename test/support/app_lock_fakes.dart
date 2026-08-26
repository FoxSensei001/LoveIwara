import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/storage_service.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

/// 内存版安全存储：可以精确制造「没有这条数据」与「读不出来」两种结局。
///
/// [StorageService] 是带私有构造的单例，测试里只能 `implements` + noSuchMethod。
/// ⚠️ 别在 widget test 里直接用真的 [StorageService]：它会去敲
/// flutter_secure_storage 的 MethodChannel，在测试环境里可能久久不返回，
/// 表现成 `pumpAndSettle timed out`，而不是一个像样的报错。
class FakeSecureStorage implements StorageService {
  final Map<String, Map<String, dynamic>> _objects = {};

  /// 读取一律失败（模拟 Keystore 异常 / 密文损坏 / JSON 解不开）。
  bool failReads = false;

  @override
  Future<SecureWriteResult> writeSecureObject(
    String key,
    Map<String, dynamic> value, {
    SecureWriteFallback fallback = SecureWriteFallback.encrypted,
  }) async {
    _objects[key] = Map<String, dynamic>.from(value);
    return SecureWriteResult.secure;
  }

  @override
  Future<Map<String, dynamic>?> readSecureObject(String key) async {
    return (await readSecureObjectDetailed(key)).value;
  }

  @override
  Future<SecureReadResult<Map<String, dynamic>>> readSecureObjectDetailed(
    String key,
  ) async {
    if (failReads) {
      return const SecureReadResult<Map<String, dynamic>>.failed('boom');
    }
    final value = _objects[key];
    return value == null
        ? const SecureReadResult<Map<String, dynamic>>.missing()
        : SecureReadResult<Map<String, dynamic>>.found(value);
  }

  @override
  Future<void> deleteSecureData(String key) async {
    _objects.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 可编排的生物识别：[onAuthenticate] 里可以模拟「认证框弹着时按 Home」。
class FakeLocalAuth extends LocalAuthentication {
  FakeLocalAuth({this.supported = true, this.result = true});

  bool supported;
  bool result;
  Future<void> Function()? onAuthenticate;

  @override
  Future<bool> isDeviceSupported() async => supported;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async =>
      supported ? const [BiometricType.fingerprint] : const [];

  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<AuthMessages> authMessages = const <AuthMessages>[],
    bool biometricOnly = false,
    bool sensitiveTransaction = true,
    bool persistAcrossBackgrounding = false,
  }) async {
    await onAuthenticate?.call();
    return result;
  }
}

/// 内存版配置：测试里没有 sqlite，跳过落库那一步（`_db` 未初始化会抛
/// LateInitializationError）。内存值仍然照常更新，跨实例共享同一份。
class MemoryConfigService extends ConfigService {
  MemoryConfigService() {
    for (final key in ConfigKey.values) {
      settings[key] = Rx<dynamic>(key.defaultValue);
    }
  }

  @override
  Future<void> saveSetting(ConfigKey key, dynamic value) async {}
}

/// 直接把凭据塞进假存储，避开 12 万轮 PBKDF2（测试里用最低合法轮数）。
Future<void> seedAppLockCredential(
  FakeSecureStorage storage,
  String pin, {
  int iterations = 10000,
}) async {
  final salt = List<int>.generate(16, (i) => i);
  final key = await Pbkdf2.hmacSha256(
    iterations: iterations,
    bits: 256,
  ).deriveKeyFromPassword(password: pin, nonce: salt);
  await storage.writeSecureObject('app_lock_pin_v1', {
    'version': 1,
    'iterations': iterations,
    'salt': base64Encode(salt),
    'hash': base64Encode(await key.extractBytes()),
  });
}
