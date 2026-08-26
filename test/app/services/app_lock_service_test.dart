import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/app_lock_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/storage_service.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

/// 内存版安全存储：可以精确制造「没有这条数据」与「读不出来」两种结局。
///
/// [StorageService] 是带私有构造的单例，测试里只能 `implements` + noSuchMethod。
class _FakeSecureStorage implements StorageService {
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

/// 内存版配置：测试里没有 sqlite，跳过落库那一步（`_db` 未初始化会抛
/// LateInitializationError）。内存值仍然照常更新，跨实例共享同一份。
class _MemoryConfigService extends ConfigService {
  @override
  Future<void> saveSetting(ConfigKey key, dynamic value) async {}
}

/// 可编排的生物识别：[onAuthenticate] 里可以模拟「认证框弹着时按 Home」。
class _FakeLocalAuth extends LocalAuthentication {
  _FakeLocalAuth({this.supported = true, this.result = true});

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

/// 直接把凭据塞进假存储，避开 12 万轮 PBKDF2（测试里用最低合法轮数）。
Future<void> _seedCredential(
  _FakeSecureStorage storage,
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ConfigService config;
  late _FakeSecureStorage storage;
  late AppLockService service;

  ConfigService freshConfig() {
    final c = _MemoryConfigService();
    for (final key in ConfigKey.values) {
      c.settings[key] = Rx<dynamic>(key.defaultValue);
    }
    return c;
  }

  AppLockService buildService({
    ConfigService? configService,
    _FakeSecureStorage? storageService,
    LocalAuthentication? localAuth,
  }) {
    return AppLockService(
      configService: configService ?? config,
      storageService: storageService ?? storage,
      localAuthentication: localAuth ?? _FakeLocalAuth(supported: false),
    );
  }

  setUp(() {
    config = freshConfig();
    storage = _FakeSecureStorage();
    config.settings[ConfigKey.APP_LOCK_ENABLED]!.value = true;
    service = buildService();
  });

  test('PIN accepts only 4 to 8 digits', () {
    expect(service.isValidPin('1234'), isTrue);
    expect(service.isValidPin('12345678'), isTrue);
    expect(service.isValidPin('123'), isFalse);
    expect(service.isValidPin('123456789'), isFalse);
    expect(service.isValidPin('12a4'), isFalse);
  });

  test('immediate timeout locks when the app resumes', () {
    config.settings[ConfigKey.APP_LOCK_TIMEOUT_SECONDS]!.value = 0;

    service.onBackgrounded(AppLifecycleState.paused);
    service.onResumed();

    expect(service.isLocked.value, isTrue);
  });

  test('nonzero timeout keeps a short background visit unlocked', () {
    config.settings[ConfigKey.APP_LOCK_TIMEOUT_SECONDS]!.value = 30;

    service.onBackgrounded(AppLifecycleState.paused);
    service.onResumed();

    expect(service.isLocked.value, isFalse);
  });

  test('disabled timeout never locks after a background visit', () {
    expect(config[ConfigKey.APP_LOCK_TIMEOUT_SECONDS], -1);

    service.onBackgrounded(AppLifecycleState.paused);
    service.onResumed();

    expect(service.isLocked.value, isFalse);
  });

  test('screen lock locks when the option is enabled', () {
    config.settings[ConfigKey.APP_LOCK_AFTER_SCREEN_OFF]!.value = true;

    service.onSystemScreenLocked();

    expect(service.isLocked.value, isTrue);
  });

  test('screen lock is ignored when the option is disabled', () {
    service.onSystemScreenLocked();

    expect(service.isLocked.value, isFalse);
  });

  test('disabled app lock ignores lifecycle changes', () {
    config.settings[ConfigKey.APP_LOCK_ENABLED]!.value = false;
    config.settings[ConfigKey.APP_LOCK_TIMEOUT_SECONDS]!.value = 0;

    service.onBackgrounded(AppLifecycleState.paused);
    service.onResumed();

    expect(service.isLocked.value, isFalse);
  });

  group('凭据读失败 ≠ 没有凭据（HIGH#1）', () {
    test('读不出来时保持开启并锁定，不再静默关掉应用锁', () async {
      await _seedCredential(storage, '1234');
      storage.failReads = true;

      await service.init();

      expect(service.enabled, isTrue, reason: '读失败不该把开关持久化关掉');
      expect(service.isLocked.value, isTrue);
      expect(service.credentialUnavailable.value, isTrue);
    });

    test('真的没有凭据（备份还原）才关掉应用锁', () async {
      config.settings[ConfigKey.APP_LOCK_BIOMETRICS_ENABLED]!.value = true;

      await service.init();

      expect(service.enabled, isFalse);
      expect(service.biometricsEnabled, isFalse);
      expect(service.isLocked.value, isFalse);
      expect(service.credentialUnavailable.value, isFalse);
    });

    test('凭据字段损坏算读失败，不算「没有」', () async {
      await storage.writeSecureObject('app_lock_pin_v1', {
        'version': 1,
        'iterations': 10000,
        'salt': '不是 base64!!',
        'hash': 'nope',
      });

      await service.init();

      expect(service.enabled, isTrue);
      expect(service.credentialUnavailable.value, isTrue);
    });

    test('读失败期间输 PIN 不计入失败次数（不会被自己的封锁挡住）', () async {
      await _seedCredential(storage, '1234');
      storage.failReads = true;
      await service.init();

      for (var i = 0; i < 6; i++) {
        expect(await service.unlockWithPin('1234'), isFalse);
      }

      expect(service.failedAttempts.value, 0);
      expect(service.retryAfter, Duration.zero);
    });

    test('生物识别在读失败期间照常可用（否则只剩「重置=关掉锁」这条更弱的路）', () async {
      final auth = _FakeLocalAuth(result: true);
      service = buildService(localAuth: auth);
      await _seedCredential(storage, '1234');
      config.settings[ConfigKey.APP_LOCK_BIOMETRICS_ENABLED]!.value = true;
      storage.failReads = true;
      await service.init();
      expect(service.isLocked.value, isTrue);

      expect(await service.authenticateBiometrically(), isTrue);
      expect(service.isLocked.value, isFalse);
      expect(service.enabled, isTrue, reason: '生物解锁不该顺手关掉应用锁');
    });

    test('重试之后凭据仍然没有，出口依旧只有重置', () async {
      await _seedCredential(storage, '1234');
      storage.failReads = true;
      await service.init();

      // 凭据在我们眼皮底下消失（不是读失败，是真没了）
      storage.failReads = false;
      await storage.deleteSecureData('app_lock_pin_v1');

      expect(await service.retryCredential(), isFalse);
      expect(service.credentialUnavailable.value, isTrue);
      expect(await service.resetAfterCredentialFailure(), isTrue);
    });

    test('重试成功后回到正常锁屏', () async {
      await _seedCredential(storage, '1234');
      storage.failReads = true;
      await service.init();
      expect(service.credentialUnavailable.value, isTrue);

      storage.failReads = false;
      expect(await service.retryCredential(), isTrue);
      expect(service.credentialUnavailable.value, isFalse);
      expect(await service.unlockWithPin('1234'), isTrue);
    });

    test('显式重置是唯一出口，且只在读失败时开放', () async {
      await _seedCredential(storage, '1234');
      await service.init();

      // 正常状态下重置无效（否则等于给了一条随手关锁的后门）
      expect(await service.resetAfterCredentialFailure(), isFalse);
      expect(service.enabled, isTrue);

      storage.failReads = true;
      await service.retryCredential();
      expect(await service.resetAfterCredentialFailure(), isTrue);
      expect(service.enabled, isFalse);
      expect(service.isLocked.value, isFalse);
    });
  });

  group('生物识别不能绕过后台超时锁定（HIGH#2）', () {
    test('认证框弹着时按 Home 再回来取消认证 → 照样锁上', () async {
      config.settings[ConfigKey.APP_LOCK_TIMEOUT_SECONDS]!.value = 0;
      final auth = _FakeLocalAuth(result: false);
      service = buildService(localAuth: auth);
      await _seedCredential(storage, '1234');
      await service.init();
      service.isLocked.value = false;

      auth.onAuthenticate = () async {
        // 系统认证框把 App 打成 inactive（同一 Activity 上的对话框）
        service.onBackgrounded(AppLifecycleState.inactive);
        // 用户按 Home：这才是真的进后台
        service.onBackgrounded(AppLifecycleState.paused);
        // 回到前台，认证框还在
        service.onResumed();
      };

      expect(await service.authenticateBiometrically(), isFalse);
      expect(
        service.isLocked.value,
        isTrue,
        reason: '认证被取消后要结算真实的后台时长',
      );
    });

    test('只弹认证框、没真的进后台 → 不会被「立即锁定」误伤', () async {
      config.settings[ConfigKey.APP_LOCK_TIMEOUT_SECONDS]!.value = 0;
      final auth = _FakeLocalAuth(result: false);
      service = buildService(localAuth: auth);
      await _seedCredential(storage, '1234');
      await service.init();
      service.isLocked.value = false;

      auth.onAuthenticate = () async {
        service.onBackgrounded(AppLifecycleState.inactive);
        service.onResumed();
      };

      expect(await service.authenticateBiometrically(), isFalse);
      expect(service.isLocked.value, isFalse);
    });

    test('认证通过就等于解过一次锁，不再补锁', () async {
      config.settings[ConfigKey.APP_LOCK_TIMEOUT_SECONDS]!.value = 0;
      final auth = _FakeLocalAuth(result: true);
      service = buildService(localAuth: auth);
      await _seedCredential(storage, '1234');
      await service.init();

      auth.onAuthenticate = () async {
        service.onBackgrounded(AppLifecycleState.paused);
        service.onResumed();
      };

      expect(await service.authenticateBiometrically(), isTrue);
      expect(service.isLocked.value, isFalse);
    });
  });

  group('PIN 封锁跨重启保持（MED#5）', () {
    test('输错五次后重启进程，封锁仍然生效', () async {
      await _seedCredential(storage, '1234');
      await service.init();

      for (var i = 0; i < 5; i++) {
        expect(await service.unlockWithPin('0000'), isFalse);
      }
      expect(service.retryAfter, greaterThan(Duration.zero));

      // 强杀重启：同一份配置 + 同一份安全存储，换一个全新的 service 实例
      final restarted = buildService();
      await restarted.init();

      expect(restarted.failedAttempts.value, 5);
      expect(
        restarted.retryAfter,
        greaterThan(Duration.zero),
        reason: '封锁只放内存的话，强杀重启就能立刻再试五次',
      );
      expect(await restarted.unlockWithPin('1234'), isFalse, reason: '封锁期内一律拒绝');
    });

    test('认证成功后清空封锁与失败计数', () async {
      await _seedCredential(storage, '1234');
      await service.init();

      for (var i = 0; i < 5; i++) {
        await service.unlockWithPin('0000');
      }
      expect(config[ConfigKey.APP_LOCK_BLOCKED_UNTIL_MS], greaterThan(0));

      // 把封锁手动过期，模拟等够了时间
      config.settings[ConfigKey.APP_LOCK_BLOCKED_UNTIL_MS]!.value = 1;
      expect(await service.unlockWithPin('1234'), isTrue);

      expect(service.failedAttempts.value, 0);
      expect(config[ConfigKey.APP_LOCK_FAILED_ATTEMPTS], 0);
      expect(config[ConfigKey.APP_LOCK_BLOCKED_UNTIL_MS], 0);
    });

    test('时钟被往前拨出天际时封锁按最长一档截断，不会把人永久关在外面', () async {
      config.settings[ConfigKey.APP_LOCK_BLOCKED_UNTIL_MS]!.value = DateTime.now()
          .add(const Duration(days: 3650))
          .millisecondsSinceEpoch;

      expect(
        service.retryAfter,
        lessThanOrEqualTo(const Duration(seconds: 30 * 32)),
      );
    });
  });
}
