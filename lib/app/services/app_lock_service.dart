import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/storage_service.dart';
import 'package:local_auth/local_auth.dart';

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
  static const int _iterations = 120000;
  static const int _saltLength = 16;

  final ConfigService _config;
  final StorageService _storage;
  final LocalAuthentication _localAuth;

  final RxBool isLocked = false.obs;
  final RxBool biometricAvailable = false.obs;
  final RxBool isAuthenticating = false.obs;
  final RxInt failedAttempts = 0.obs;

  DateTime? _backgroundedAt;
  DateTime? _blockedUntil;

  bool get enabled => _config[ConfigKey.APP_LOCK_ENABLED] as bool;
  bool get biometricsEnabled =>
      _config[ConfigKey.APP_LOCK_BIOMETRICS_ENABLED] as bool;
  int get timeoutSeconds => _config[ConfigKey.APP_LOCK_TIMEOUT_SECONDS] as int;

  Duration get retryAfter {
    final until = _blockedUntil;
    if (until == null) return Duration.zero;
    final remaining = until.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Future<AppLockService> init() async {
    final credential = await _readCredential();
    if (enabled && credential == null) {
      // A database restore may contain the preference but not the deliberately
      // non-exported secure credential. Fail safe without trapping the user.
      await _config.setSetting(ConfigKey.APP_LOCK_ENABLED, false);
      await _config.setSetting(ConfigKey.APP_LOCK_BIOMETRICS_ENABLED, false);
    }
    isLocked.value = enabled;
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
    isLocked.value = false;
    _resetFailures();
    return true;
  }

  Future<bool> verifyPin(String pin) async {
    if (retryAfter > Duration.zero) return false;
    final credential = await _readCredential();
    if (credential == null) return false;
    final salt = base64Decode(credential['salt']! as String);
    final expected = base64Decode(credential['hash']! as String);
    final iterations = credential['iterations']! as int;
    final actual = await _derive(pin, salt, iterations);
    final valid = _constantTimeEquals(actual, expected);
    if (valid) {
      _resetFailures();
    } else {
      _recordFailure();
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
    await _config.setSetting(ConfigKey.APP_LOCK_ENABLED, false);
    await _config.setSetting(ConfigKey.APP_LOCK_BIOMETRICS_ENABLED, false);
    await _storage.deleteSecureData(_credentialKey);
    isLocked.value = false;
    _backgroundedAt = null;
    return true;
  }

  Future<void> setTimeoutSeconds(int seconds) async {
    await _config.setSetting(ConfigKey.APP_LOCK_TIMEOUT_SECONDS, seconds);
  }

  Future<void> setBiometricsEnabled(bool value) async {
    await _config.setSetting(ConfigKey.APP_LOCK_BIOMETRICS_ENABLED, value);
  }

  Future<bool> authenticateBiometrically({required String reason}) async {
    if (!biometricAvailable.value || isAuthenticating.value) return false;
    isAuthenticating.value = true;
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        // Windows Hello does not expose a biometric-only mode. It still uses
        // the OS-protected strong-authentication prompt on that platform.
        biometricOnly: !GetPlatform.isWindows,
        persistAcrossBackgrounding: true,
      );
      if (authenticated) {
        isLocked.value = false;
        _resetFailures();
      }
      return authenticated;
    } catch (_) {
      await refreshBiometricAvailability();
      return false;
    } finally {
      isAuthenticating.value = false;
      _backgroundedAt = null;
    }
  }

  void onBackgrounded() {
    if (!enabled || isAuthenticating.value) return;
    _backgroundedAt ??= DateTime.now();
  }

  void onResumed() {
    if (!enabled || isAuthenticating.value) return;
    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;
    if (backgroundedAt == null) return;
    if (DateTime.now().difference(backgroundedAt).inSeconds >= timeoutSeconds) {
      isLocked.value = true;
    }
  }

  void lockNow() {
    if (enabled) isLocked.value = true;
  }

  Future<Map<String, Object>?> _readCredential() async {
    final raw = await _storage.readSecureObject(_credentialKey);
    if (raw == null) return null;
    final salt = raw['salt'];
    final hash = raw['hash'];
    final iterations = raw['iterations'];
    if (salt is! String || hash is! String || iterations is! int) return null;
    try {
      final saltBytes = base64Decode(salt);
      final hashBytes = base64Decode(hash);
      if (saltBytes.length != _saltLength ||
          hashBytes.length != 32 ||
          iterations < 10000 ||
          iterations > 1000000) {
        return null;
      }
      return <String, Object>{
        'salt': salt,
        'hash': hash,
        'iterations': iterations,
      };
    } on FormatException {
      return null;
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

  void _recordFailure() {
    failedAttempts.value++;
    if (failedAttempts.value >= 5) {
      final exponent = min(failedAttempts.value - 5, 5);
      _blockedUntil = DateTime.now().add(
        Duration(seconds: 30 * (1 << exponent)),
      );
    }
  }

  void _resetFailures() {
    failedAttempts.value = 0;
    _blockedUntil = null;
  }
}
