import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:i_iwara/utils/logger_utils.dart';

/// 安全存储不可用时的降级加密器（AES-256-GCM）。
///
/// 密钥存放在应用私有目录的独立文件中，并被 Android 备份规则排除
/// （见 android/app/src/main/res/xml/backup_rules.xml）——因此：
/// - 磁盘上绝不出现明文；
/// - 系统备份/换机导出的密文因缺少密钥文件而不可解；
/// - 机密性弱于 Keystore（沙箱内攻击者可同时读到密钥与密文），
///   仅作为 Keystore 不可用设备上「保住登录态」的兜底，健康设备不走此路径。
class SecureFallbackCipher {
  static const String _tag = 'SecureFallbackCipher';

  /// 密文封皮前缀。用于与历史遗留的明文 fallback 数据区分。
  static const String envelopePrefix = 'enc1:';

  static const String _keyFileName = 'secure_fallback.key';

  final AesGcm _algorithm = AesGcm.with256bits();

  /// 测试注入：密钥文件所在目录；为空时使用应用支持目录。
  final Directory? _keyDirOverride;

  SecretKey? _cachedKey;
  bool _keyUnavailable = false;

  SecureFallbackCipher({Directory? keyDir}) : _keyDirOverride = keyDir;

  static bool isEnvelope(String value) => value.startsWith(envelopePrefix);

  /// 加密 [plaintext]，返回 `enc1:<b64 nonce>:<b64 密文>:<b64 mac>`。
  /// 平台不支持（Web）或密钥文件不可用时返回 null，由调用方决定放弃持久化。
  Future<String?> encrypt(String plaintext) async {
    final key = await _loadOrCreateKey(allowCreate: true);
    if (key == null) return null;
    try {
      final box = await _algorithm.encrypt(
        utf8.encode(plaintext),
        secretKey: key,
      );
      return '$envelopePrefix'
          '${base64Encode(box.nonce)}:'
          '${base64Encode(box.cipherText)}:'
          '${base64Encode(box.mac.bytes)}';
    } catch (e) {
      LogUtils.e('$_tag 加密失败', error: e);
      return null;
    }
  }

  /// 解密封皮数据。密钥缺失、封皮损坏或校验失败时返回 null
  /// （视作无数据，调用方应清理该条目）。
  Future<String?> decrypt(String envelope) async {
    if (!isEnvelope(envelope)) return null;
    // 解密只读取既有密钥，绝不新建——新建的密钥解不开旧密文，
    // 反而会让「密钥文件丢失」表现成永远解不开的僵尸数据。
    final key = await _loadOrCreateKey(allowCreate: false);
    if (key == null) return null;
    try {
      final parts = envelope.substring(envelopePrefix.length).split(':');
      if (parts.length != 3) return null;
      final box = SecretBox(
        base64Decode(parts[1]),
        nonce: base64Decode(parts[0]),
        mac: Mac(base64Decode(parts[2])),
      );
      final clear = await _algorithm.decrypt(box, secretKey: key);
      return utf8.decode(clear);
    } catch (e) {
      // MAC 校验失败/封皮损坏：按无数据处理，不向上抛。
      LogUtils.w('$_tag 解密失败（按无数据处理）: ${e.runtimeType}', _tag);
      return null;
    }
  }

  Future<SecretKey?> _loadOrCreateKey({required bool allowCreate}) async {
    if (_cachedKey != null) return _cachedKey;
    if (_keyUnavailable) return null;
    if (kIsWeb) {
      // Web 无文件系统隔离可言，不提供降级加密。
      _keyUnavailable = true;
      return null;
    }
    try {
      final dir = _keyDirOverride ?? await getApplicationSupportDirectory();
      final file = File('${dir.path}${Platform.pathSeparator}$_keyFileName');
      if (await file.exists()) {
        final raw = base64Decode((await file.readAsString()).trim());
        if (raw.length == 32) {
          _cachedKey = SecretKey(raw);
          return _cachedKey;
        }
        LogUtils.w('$_tag 密钥文件长度异常(${raw.length})，将重建', _tag);
      }
      if (!allowCreate) return null;
      final rng = Random.secure();
      final keyBytes = List<int>.generate(32, (_) => rng.nextInt(256));
      await file.parent.create(recursive: true);
      await file.writeAsString(base64Encode(keyBytes), flush: true);
      _cachedKey = SecretKey(keyBytes);
      LogUtils.i('$_tag 已生成降级加密密钥', _tag);
      return _cachedKey;
    } catch (e) {
      LogUtils.e('$_tag 密钥文件不可用，降级加密关闭', error: e);
      _keyUnavailable = true;
      return null;
    }
  }

  /// 测试专用：清除内存缓存的密钥状态。
  @visibleForTesting
  void debugReset() {
    _cachedKey = null;
    _keyUnavailable = false;
  }
}
