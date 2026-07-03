import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:i_iwara/app/services/secure_fallback_cipher.dart';
import 'package:i_iwara/app/services/storage_service.dart';
import 'package:i_iwara/app/services/token_manager.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 构造一个结构合法的 JWT（TokenManager.validateToken 只看 payload）。
String _jwt(String type, {required int expEpochSec}) {
  String seg(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  final header = seg({'alg': 'HS256', 'typ': 'JWT'});
  final payload = seg({'type': type, 'exp': expEpochSec});
  return '$header.$payload.sig';
}

int get _nowSec => DateTime.now().millisecondsSinceEpoch ~/ 1000;

class _NoopAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw StateError('本测试不应发起网络请求');
  }

  @override
  void close({bool force = false}) {}
}

Dio _dummyDio() =>
    Dio(BaseOptions(baseUrl: 'https://example.com'))
      ..httpClientAdapter = _NoopAdapter();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  late Map<String, String> secureStore;

  /// 读取抛出的异常消息（模拟损坏），null 表示正常。
  String? readThrowsMessage;
  int deleteAllCalls = 0;

  late Directory tempRoot;
  late GetStorage box;

  const pathChannel = MethodChannel('plugins.flutter.io/path_provider');

  setUpAll(() async {
    await LogUtils.init(isProduction: true, enablePersistence: false);
    tempRoot = await Directory.systemTemp.createTemp('i_iwara_fallback_test');
    // GetStorage/path_provider 在测试环境无原生实现，统一指到临时目录。
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (call) async => tempRoot.path);
    // GetStorage 按容器名缓存实例，全程共用一个，用例间 erase。
    box = GetStorage('fallback_test_box', tempRoot.path);
    await box.initStorage;
  });

  tearDownAll(() async {
    // 最后一个用例结束时框架已自动清掉 mock handler，而 GetStorage 的异步
    // flush 队列可能还没排干：先挂回 handler，排干队列，再清理临时目录。
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (call) async => tempRoot.path);
    try {
      await box.save();
    } catch (_) {}
    try {
      await tempRoot.delete(recursive: true);
    } catch (_) {}
  });

  setUp(() async {
    secureStore = <String, String>{};
    readThrowsMessage = null;
    deleteAllCalls = 0;

    // flutter_test 每个用例后会清空 mock handler，须逐用例重注册；
    // GetStorage 的异步 flush 备份路径也会请求 path_provider。
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (call) async => tempRoot.path);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureChannel, (call) async {
      final args = (call.arguments as Map?)?.cast<String, dynamic>() ?? {};
      switch (call.method) {
        case 'write':
          secureStore[args['key'] as String] = args['value'] as String;
          return null;
        case 'read':
          if (readThrowsMessage != null) {
            throw PlatformException(code: 'Unknown', message: readThrowsMessage);
          }
          return secureStore[args['key'] as String];
        case 'delete':
          secureStore.remove(args['key'] as String);
          return null;
        case 'readAll':
          return secureStore;
        case 'deleteAll':
          deleteAllCalls++;
          secureStore.clear();
          return null;
        case 'containsKey':
          return secureStore.containsKey(args['key'] as String);
      }
      return null;
    });

    await box.erase();
    final storage = StorageService();
    storage.debugBox = box;
    storage.debugSetSecureStorageAvailable(true);
    final keyDir = await tempRoot.createTemp('keys');
    storage.debugFallbackCipher = SecureFallbackCipher(keyDir: keyDir);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureChannel, null);
  });

  group('SecureFallbackCipher', () {
    test('加解密 roundtrip，篡改后返回 null', () async {
      final dir = await tempRoot.createTemp('cipher');
      final cipher = SecureFallbackCipher(keyDir: dir);
      final envelope = await cipher.encrypt('hello 世界');
      expect(envelope, isNotNull);
      expect(SecureFallbackCipher.isEnvelope(envelope!), isTrue);
      expect(envelope.contains('hello'), isFalse); // 非明文

      expect(await cipher.decrypt(envelope), 'hello 世界');

      // 篡改密文 → MAC 校验失败 → null
      final parts = envelope.split(':');
      final tampered =
          '${parts[0]}:${parts[1]}:${base64Encode(List.filled(8, 0))}:${parts[3]}';
      expect(await cipher.decrypt(tampered), isNull);
    });

    test('密钥文件丢失后旧密文不可解（返回 null 而非抛错）', () async {
      final dir = await tempRoot.createTemp('cipher2');
      final cipher = SecureFallbackCipher(keyDir: dir);
      final envelope = await cipher.encrypt('secret');
      // 模拟换机：密文还原了、密钥文件没跟过来
      for (final f in dir.listSync()) {
        f.deleteSync();
      }
      final fresh = SecureFallbackCipher(keyDir: dir);
      expect(await fresh.decrypt(envelope!), isNull);
    });
  });

  group('StorageService 降级加密兜底', () {
    test('安全存储不可用时写入落加密兜底且可读回，磁盘无明文', () async {
      final storage = StorageService();
      storage.debugSetSecureStorageAvailable(false);

      final result = await storage.writeSecureData('k1', 'top-secret');
      expect(result, SecureWriteResult.encryptedFallback);
      expect(secureStore.containsKey('k1'), isFalse);

      final raw = box.read<String>('secure_k1');
      expect(raw, isNotNull);
      expect(raw!.startsWith('enc1:'), isTrue);
      expect(raw.contains('top-secret'), isFalse);

      expect(await storage.readSecureData('k1'), 'top-secret');
    });

    test('fail-closed 策略（none）下不落任何盘', () async {
      final storage = StorageService();
      storage.debugSetSecureStorageAvailable(false);

      final result = await storage.writeSecureData(
        'k2',
        'v',
        fallback: SecureWriteFallback.none,
      );
      expect(result, SecureWriteResult.skipped);
      expect(box.read<String>('secure_k2'), isNull);
    });

    test('历史明文遗留可读出，并被就地升级为加密封皮', () async {
      final storage = StorageService();
      storage.debugSetSecureStorageAvailable(false);
      await box.write('secure_legacy', 'plain-old-value');

      expect(await storage.readSecureData('legacy'), 'plain-old-value');

      final upgraded = box.read<String>('secure_legacy');
      expect(upgraded, isNotNull);
      expect(upgraded!.startsWith('enc1:'), isTrue);
      // 升级后仍可读
      expect(await storage.readSecureData('legacy'), 'plain-old-value');
    });

    test('安全存储健康时兜底副本迁移回安全存储并删除副本', () async {
      final storage = StorageService();
      // 先在不可用状态写入兜底副本
      storage.debugSetSecureStorageAvailable(false);
      await storage.writeSecureData('mig', 'value-1');
      // 恢复可用后读取 → 迁移
      storage.debugSetSecureStorageAvailable(true);
      expect(await storage.readSecureData('mig'), 'value-1');
      expect(secureStore['mig'], 'value-1');
      expect(box.read<String>('secure_mig'), isNull);
    });

    test('读到损坏数据时清空自愈且安全存储保持启用', () async {
      final storage = StorageService();
      secureStore['bad'] = 'ciphertext';
      readThrowsMessage =
          'javax.crypto.BadPaddingException: error:1e000065:Cipher '
          'functions:OPENSSL_internal:BAD_DECRYPT';

      final value = await storage.readSecureData('bad');
      expect(value, isNull);
      expect(deleteAllCalls, 1); // 自愈清空
      expect(storage.isSecureStorageAvailable, isTrue); // 不再整会话降级
      expect(
        storage.secureStorageHealth,
        SecureStorageHealth.recoveredAfterReset,
      );

      // 自愈后写入正常
      readThrowsMessage = null;
      expect(
        await storage.writeSecureData('bad', 'new'),
        SecureWriteResult.secure,
      );
    });

    test('非损坏型读取失败仍整会话降级，走兜底', () async {
      final storage = StorageService();
      readThrowsMessage = 'Some transient keystore hiccup';

      expect(await storage.readSecureData('x'), isNull);
      expect(deleteAllCalls, 0); // 不乱清数据
      expect(storage.isSecureStorageAvailable, isFalse);

      // 降级后写入落兜底
      expect(
        await storage.writeSecureData('x', 'v'),
        SecureWriteResult.encryptedFallback,
      );
    });

    test('deleteSecureData 同时清除兜底副本', () async {
      final storage = StorageService();
      storage.debugSetSecureStorageAvailable(false);
      await storage.writeSecureData('d1', 'v');
      expect(box.read<String>('secure_d1'), isNotNull);

      await storage.deleteSecureData('d1');
      expect(box.read<String>('secure_d1'), isNull);
      expect(await storage.readSecureData('d1'), isNull);
    });
  });

  group('TokenManager 静默丢失检测与双写', () {
    test('连续两次静默丢失后标记不可信，此后 token 双写', () async {
      final storage = StorageService();
      final refresh = _jwt(
        'refresh_token',
        expEpochSec: _nowSec + 30 * 24 * 3600,
      );

      // 第一次：有标记无 token → 计数 1，不降级
      await box.write('auth_session_marker', 'secure');
      final tm1 = TokenManager(tokenDio: _dummyDio());
      await tm1.init();
      expect(box.read<int>('auth_secure_loss_count'), 1);
      expect(storage.secureStorageUntrusted, isFalse);
      expect(box.read<String>('auth_session_marker'), isNull); // 标记已消费

      // 第二次：再次丢失 → 计数 2 → 标记不可信
      await box.write('auth_session_marker', 'secure');
      final tm2 = TokenManager(tokenDio: _dummyDio());
      await tm2.init();
      expect(storage.secureStorageUntrusted, isTrue);

      // 此后保存 token：安全存储成功 + 兜底副本常备（双写）
      final tm3 = TokenManager(tokenDio: _dummyDio());
      await tm3.saveAuthToken(refresh);
      expect(secureStore[KeyConstants.authToken], refresh);
      final copy = box.read<String>('secure_${KeyConstants.authToken}');
      expect(copy, isNotNull);
      expect(copy!.startsWith('enc1:'), isTrue);
      expect(box.read<String>('auth_session_marker'), 'secure');

      // 模拟插件冷启动清空：安全存储没了，兜底副本救回会话
      secureStore.clear();
      final tm4 = TokenManager(tokenDio: _dummyDio());
      await tm4.init();
      expect(tm4.hasRefreshToken, isTrue);
      expect(tm4.authToken, refresh);
    });

    test('正常登出不计为静默丢失', () async {
      final storage = StorageService();
      final refresh = _jwt(
        'refresh_token',
        expEpochSec: _nowSec + 30 * 24 * 3600,
      );

      final tm = TokenManager(tokenDio: _dummyDio());
      await tm.saveAuthToken(refresh);
      expect(box.read<String>('auth_session_marker'), isNotNull);

      await tm.clearTokens();
      expect(box.read<String>('auth_session_marker'), isNull);

      final tm2 = TokenManager(tokenDio: _dummyDio());
      await tm2.init();
      expect(box.read<int>('auth_secure_loss_count'), isNull);
      expect(storage.secureStorageUntrusted, isFalse);
    });

    test('会话成功恢复时重置丢失计数', () async {
      final refresh = _jwt(
        'refresh_token',
        expEpochSec: _nowSec + 30 * 24 * 3600,
      );

      // 一次历史丢失
      await box.write('auth_secure_loss_count', 1);
      final tm = TokenManager(tokenDio: _dummyDio());
      await tm.saveAuthToken(refresh);

      final tm2 = TokenManager(tokenDio: _dummyDio());
      await tm2.init();
      expect(tm2.hasRefreshToken, isTrue);
      expect(box.read<int>('auth_secure_loss_count'), isNull); // 已重置
    });
  });
}
