import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/storage_service.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

/// Owns app-lock credentials and runtime lock state.
///
/// The PIN itself is never persisted. Only a salted PBKDF2 digest is written
/// through [StorageService], which uses the platform keystore/keychain where
/// available. Biometrics authorize this process through the operating system;
/// biometric templates never leave the device secure hardware.
class AppLockService extends GetxService {
  AppLockService({
    ConfigService? configService,
    StorageService? storageService,
    LocalAuthentication? localAuthentication,
  }) : _config = configService ?? Get.find<ConfigService>(),
       _storage = storageService ?? StorageService(),
       _localAuth = localAuthentication ?? LocalAuthentication();

  static const String _credentialKey = 'app_lock_pin_v1';
  static const MethodChannel _platformChannel = MethodChannel(
    'i_iwara/app_lock',
  );
  static const int _iterations = 120000;
  static const int _saltLength = 16;

  /// 连续失败到这个次数开始封锁。
  static const int _blockAfterFailures = 5;

  /// 封锁基数与退避上限：30s × 2^n，n 最多 5 → 最长 16 分钟。
  static const int _blockBaseSeconds = 30;
  static const int _blockMaxExponent = 5;

  final ConfigService _config;
  final StorageService _storage;
  final LocalAuthentication _localAuth;

  final RxBool isLocked = false.obs;
  final RxBool biometricAvailable = false.obs;
  final RxBool isAuthenticating = false.obs;
  final RxInt failedAttempts = 0.obs;

  /// 凭据读不出来（Keystore 异常 / 密文或 JSON 损坏），**不是**没有凭据。
  ///
  /// 这时 PIN 永远校验不过，生物识别也没有可回退的凭据，所以应用保持锁定，
  /// 由锁屏提供「重试」与「重置应用锁」两个显式出口——绝不能因为读不到就
  /// 把锁悄悄关掉（fail-open）。
  final RxBool credentialUnavailable = false.obs;

  DateTime? _backgroundedAt;

  bool get enabled => _config[ConfigKey.APP_LOCK_ENABLED] as bool;
  bool get biometricsEnabled =>
      _config[ConfigKey.APP_LOCK_BIOMETRICS_ENABLED] as bool;
  int get timeoutSeconds => _config[ConfigKey.APP_LOCK_TIMEOUT_SECONDS] as int;
  bool get lockAfterScreenOff =>
      _config[ConfigKey.APP_LOCK_AFTER_SCREEN_OFF] as bool;

  /// 封锁截止时间。持久化在配置里——只放内存的话，输错 5 次后强杀重启就能
  /// 立刻再试 5 次，4 位 PIN 可以这样一直枚举下去。
  DateTime? get _blockedUntil {
    final ms = _config[ConfigKey.APP_LOCK_BLOCKED_UNTIL_MS] as int;
    if (ms <= 0) return null;
    final until = DateTime.fromMillisecondsSinceEpoch(ms);
    // 时钟被往回拨过 / 配置被写坏时，剩余时长会变成一个荒谬的大数，
    // 这里按最长一档封锁截断，避免把用户永久关在外面。
    final maxBlock = Duration(
      seconds: _blockBaseSeconds * (1 << _blockMaxExponent),
    );
    if (until.difference(DateTime.now()) > maxBlock) {
      return DateTime.now().add(maxBlock);
    }
    return until;
  }

  Duration get retryAfter {
    final until = _blockedUntil;
    if (until == null) return Duration.zero;
    final remaining = until.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Future<AppLockService> init() async {
    failedAttempts.value = _config[ConfigKey.APP_LOCK_FAILED_ATTEMPTS] as int;
    final credential = await _readCredential();
    if (enabled) {
      switch (credential.status) {
        case SecureReadStatus.missing:
          // A database restore may contain the preference but not the
          // deliberately non-exported secure credential. Fail safe without
          // trapping the user.
          await _config.setSetting(ConfigKey.APP_LOCK_ENABLED, false);
          await _config.setSetting(
            ConfigKey.APP_LOCK_BIOMETRICS_ENABLED,
            false,
          );
          await _resetFailures();
        case SecureReadStatus.failed:
          // 读失败 ≠ 没有。保持开启并锁上，出口交给锁屏上的显式重置。
          credentialUnavailable.value = true;
        case SecureReadStatus.found:
          break;
      }
    }
    isLocked.value = enabled;
    if (GetPlatform.isAndroid) {
      _platformChannel.setMethodCallHandler(_handlePlatformCall);
    }
    await refreshBiometricAvailability();
    return this;
  }

  Future<void> refreshBiometricAvailability() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final enrolled = supported
          ? await _localAuth.getAvailableBiometrics()
          : const <BiometricType>[];
      biometricAvailable.value = supported && enrolled.isNotEmpty;
    } catch (_) {
      biometricAvailable.value = false;
    }
  }

  bool isValidPin(String pin) => RegExp(r'^\d{4,8}$').hasMatch(pin);

  Future<bool> enableWithPin(String pin) async {
    if (!isValidPin(pin)) return false;
    final salt = _randomBytes(_saltLength);
    final hash = await _derive(pin, salt, _iterations);
    final result = await _storage.writeSecureObject(_credentialKey, {
      'version': 1,
      'iterations': _iterations,
      'salt': base64Encode(salt),
      'hash': base64Encode(hash),
    });
    if (result == SecureWriteResult.skipped) return false;
    await _config.setSetting(ConfigKey.APP_LOCK_ENABLED, true);
    credentialUnavailable.value = false;
    isLocked.value = false;
    await _resetFailures();
    return true;
  }

  Future<bool> verifyPin(String pin) async {
    if (retryAfter > Duration.zero) return false;
    final read = await _readCredential();
    if (read.isFailed) {
      // 读不出来不是「输错了」，不该算进失败计数去触发封锁。
      credentialUnavailable.value = true;
      return false;
    }
    final credential = read.value;
    if (credential == null) return false;
    credentialUnavailable.value = false;
    final salt = base64Decode(credential['salt']! as String);
    final expected = base64Decode(credential['hash']! as String);
    final iterations = credential['iterations']! as int;
    final actual = await _derive(pin, salt, iterations);
    final valid = _constantTimeEquals(actual, expected);
    if (valid) {
      await _resetFailures();
    } else {
      await _recordFailure();
    }
    return valid;
  }

  Future<bool> unlockWithPin(String pin) async {
    final valid = await verifyPin(pin);
    if (valid) isLocked.value = false;
    return valid;
  }

  Future<bool> changePin(String currentPin, String newPin) async {
    if (!isValidPin(newPin) || !await verifyPin(currentPin)) return false;
    return enableWithPin(newPin);
  }

  Future<bool> disable(String pin) async {
    if (!await verifyPin(pin)) return false;
    await _clearLockState();
    return true;
  }

  /// 凭据读不出来时的**唯一**出口：用户在锁屏上显式确认后清空凭据并关掉应用锁。
  ///
  /// 只在 [credentialUnavailable] 为真时开放。它确实是一条 fail-open 路径，
  /// 但要人在设备上主动点两下才走得通——攻击者没法凭空制造一次读失败，而
  /// 真遇上 Keystore 损坏的用户不至于被永久关在 App 外面。
  Future<bool> resetAfterCredentialFailure() async {
    if (!credentialUnavailable.value) return false;
    await _clearLockState();
    return true;
  }

  /// 再读一次凭据。Keystore 抽风多半是瞬时的，重试成功就回到正常锁屏。
  ///
  /// 只有真的读到凭据才算好了：这一刻变成 [SecureReadStatus.missing]
  /// 意味着凭据在我们眼皮底下没了，PIN 依然校验不过，出口仍然只能是重置。
  Future<bool> retryCredential() async {
    final read = await _readCredential();
    credentialUnavailable.value = !read.isFound;
    return read.isFound;
  }

  Future<void> _clearLockState() async {
    await _config.setSetting(ConfigKey.APP_LOCK_ENABLED, false);
    await _config.setSetting(ConfigKey.APP_LOCK_BIOMETRICS_ENABLED, false);
    await _storage.deleteSecureData(_credentialKey);
    await _resetFailures();
    credentialUnavailable.value = false;
    isLocked.value = false;
    _backgroundedAt = null;
  }

  Future<void> setTimeoutSeconds(int seconds) async {
    await _config.setSetting(ConfigKey.APP_LOCK_TIMEOUT_SECONDS, seconds);
  }

  Future<void> setLockAfterScreenOff(bool value) async {
    await _config.setSetting(ConfigKey.APP_LOCK_AFTER_SCREEN_OFF, value);
  }

  Future<void> setBiometricsEnabled(bool value) async {
    await _config.setSetting(ConfigKey.APP_LOCK_BIOMETRICS_ENABLED, value);
  }

  Future<bool> authenticateBiometrically() async {
    if (!biometricAvailable.value || isAuthenticating.value) return false;
    isAuthenticating.value = true;
    var authenticated = false;
    try {
      authenticated = GetPlatform.isAndroid
          ? await _localAuth.authenticate(
              // Android requires a non-empty reason, but the native prompt's
              // description is optional. A space keeps that redundant row
              // visually empty while the OS provides the sensor guidance.
              localizedReason: ' ',
              authMessages: [
                AndroidAuthMessages(
                  signInTitle: slang.t.settings.appLockUseBiometrics,
                  signInHint: '',
                  cancelButton: slang.t.common.cancel,
                ),
              ],
              biometricOnly: true,
              persistAcrossBackgrounding: true,
            )
          : await _localAuth.authenticate(
              localizedReason: slang.t.settings.appLockAuthenticateReason,
              // Windows Hello does not expose a biometric-only mode. It still
              // uses the OS-protected strong-authentication prompt.
              biometricOnly: !GetPlatform.isWindows,
              persistAcrossBackgrounding: true,
            );
      if (authenticated) {
        isLocked.value = false;
        await _resetFailures();
      }
      return authenticated;
    } catch (_) {
      await refreshBiometricAvailability();
      return false;
    } finally {
      isAuthenticating.value = false;
      if (authenticated) {
        // 刚刚通过了系统级强认证，等同于解过一次锁。
        _backgroundedAt = null;
      } else {
        // ⛔ 这里**不能**无条件清空 _backgroundedAt。
        //
        // 设置页开启生物识别时也会走这条路：认证框弹着的时候按 Home、超过
        // 超时再回来、然后取消认证——原实现在 finally 里把后台时长抹掉，
        // 应用于是停在未锁状态，等于用「打开一次认证框」绕过了超时锁定。
        // 认证没过就照常结算这段真实的后台时长。
        _settleBackgroundElapsed();
      }
    }
  }

  /// App 进入非前台。[state] 只应是 `inactive` / `paused` / `hidden`。
  void onBackgrounded(AppLifecycleState state) {
    if (!enabled) return;
    // 系统生物识别弹窗是盖在同一个 Activity 上的对话框，只会把 App 打成
    // inactive——那不是真进后台，超时不该从这里起算（否则「立即锁定」档一
    // 弹认证框就注定要锁）。paused / hidden 是真的离开了前台，认证期间照记。
    if (isAuthenticating.value && state == AppLifecycleState.inactive) return;
    _backgroundedAt ??= DateTime.now();
  }

  void onResumed() {
    if (!enabled) return;
    // 认证进行中先不结算：这次 resume 可能只是认证框收起来。等
    // [authenticateBiometrically] 拿到结果再统一结算。
    if (isAuthenticating.value) return;
    _settleBackgroundElapsed();
  }

  /// 结算一次后台时长：超过超时就锁上，无论如何都清掉起算点。
  void _settleBackgroundElapsed() {
    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;
    if (backgroundedAt == null) return;
    final timeout = timeoutSeconds;
    if (timeout < 0) return;
    if (DateTime.now().difference(backgroundedAt).inSeconds >= timeout) {
      isLocked.value = true;
    }
  }

  void onSystemScreenLocked() {
    if (enabled && lockAfterScreenOff) isLocked.value = true;
  }

  void lockNow() {
    if (enabled) isLocked.value = true;
  }

  Future<void> _handlePlatformCall(MethodCall call) async {
    if (call.method == 'onSystemScreenLocked') {
      onSystemScreenLocked();
    }
  }

  Future<SecureReadResult<Map<String, Object>>> _readCredential() async {
    final raw = await _storage.readSecureObjectDetailed(_credentialKey);
    switch (raw.status) {
      case SecureReadStatus.missing:
        return const SecureReadResult<Map<String, Object>>.missing();
      case SecureReadStatus.failed:
        return SecureReadResult<Map<String, Object>>.failed(raw.error);
      case SecureReadStatus.found:
        break;
    }
    final value = raw.value!;
    final salt = value['salt'];
    final hash = value['hash'];
    final iterations = value['iterations'];
    // 字段缺失 / 类型不对 / base64 解不开 / 长度越界 —— 数据在，只是坏了。
    // 当作「没有凭据」会把应用锁静默关掉，一律算读失败。
    if (salt is! String || hash is! String || iterations is! int) {
      return const SecureReadResult<Map<String, Object>>.failed(
        '凭据字段缺失或类型不符',
      );
    }
    try {
      final saltBytes = base64Decode(salt);
      final hashBytes = base64Decode(hash);
      if (saltBytes.length != _saltLength ||
          hashBytes.length != 32 ||
          iterations < 10000 ||
          iterations > 1000000) {
        return const SecureReadResult<Map<String, Object>>.failed('凭据参数越界');
      }
      return SecureReadResult<Map<String, Object>>.found(<String, Object>{
        'salt': salt,
        'hash': hash,
        'iterations': iterations,
      });
    } on FormatException catch (e) {
      return SecureReadResult<Map<String, Object>>.failed(e);
    }
  }

  Future<List<int>> _derive(String pin, List<int> salt, int iterations) async {
    final algorithm = Pbkdf2.hmacSha256(iterations: iterations, bits: 256);
    final key = await algorithm.deriveKeyFromPassword(
      password: pin,
      nonce: salt,
    );
    return key.extractBytes();
  }

  List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }

  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var difference = 0;
    for (var i = 0; i < a.length; i++) {
      difference |= a[i] ^ b[i];
    }
    return difference == 0;
  }

  Future<void> _recordFailure() async {
    failedAttempts.value++;
    await _config.setSetting(
      ConfigKey.APP_LOCK_FAILED_ATTEMPTS,
      failedAttempts.value,
    );
    if (failedAttempts.value >= _blockAfterFailures) {
      final exponent = min(
        failedAttempts.value - _blockAfterFailures,
        _blockMaxExponent,
      );
      final until = DateTime.now().add(
        Duration(seconds: _blockBaseSeconds * (1 << exponent)),
      );
      await _config.setSetting(
        ConfigKey.APP_LOCK_BLOCKED_UNTIL_MS,
        until.millisecondsSinceEpoch,
      );
    }
  }

  Future<void> _resetFailures() async {
    failedAttempts.value = 0;
    await _config.setSetting(ConfigKey.APP_LOCK_FAILED_ATTEMPTS, 0);
    await _config.setSetting(ConfigKey.APP_LOCK_BLOCKED_UNTIL_MS, 0);
  }
}
