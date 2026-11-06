import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/token_manager.dart';
import 'package:i_iwara/app/services/storage_service.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 构造一个结构合法的 JWT（不校验签名，TokenManager.validateToken 只看 payload）。
String _jwt(String type, {required int expEpochSec, String? id}) {
  String seg(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  final header = seg({'alg': 'HS256', 'typ': 'JWT'});
  final payload = seg({
    'type': type,
    'exp': expEpochSec,
    'id': ?id,
  });
  return '$header.$payload.sig';
}

int get _nowSec => DateTime.now().millisecondsSinceEpoch ~/ 1000;

/// 由 Completer 控制响应时机的 Dio 适配器，用于复现"刷新在途时登出"的竞态。
class _GatedAdapter implements HttpClientAdapter {
  final Future<void> gate;
  final String Function() bodyBuilder;
  _GatedAdapter(this.gate, this.bodyBuilder);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await gate;
    return ResponseBody.fromString(
      bodyBuilder(),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// 第一次请求被 gate 阻塞并返回 [firstBody]，其后的请求立即返回 [laterBody]。
/// 用于复现"旧刷新在途时新登录发起刷新"的并发(HIGH#1)。
class _SequencedAdapter implements HttpClientAdapter {
  int _calls = 0;
  final Future<void> firstGate;
  final String firstBody;
  final String laterBody;
  _SequencedAdapter({
    required this.firstGate,
    required this.firstBody,
    required this.laterBody,
  });

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final n = _calls++;
    if (n == 0) {
      await firstGate;
      return _jsonBody(firstBody);
    }
    return _jsonBody(laterBody);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonBody(String body) => ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );

/// 第一次请求返回 200+[firstBody]，其后返回 [laterStatus]（用于模拟登录换取 token 失败）。
class _LoginSeqAdapter implements HttpClientAdapter {
  int _c = 0;
  final String firstBody;
  final int laterStatus;
  _LoginSeqAdapter(this.firstBody, this.laterStatus);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final n = _c++;
    if (n == 0) return _jsonBody(firstBody);
    return ResponseBody.fromString('', laterStatus, headers: {
      Headers.contentTypeHeader: ['application/json'],
    });
  }

  @override
  void close({bool force = false}) {}
}

Dio _dioWith(HttpClientAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
  dio.httpClientAdapter = adapter;
  return dio;
}

/// 每次返回固定 status + body 的适配器（刷新端点异常分类测试）。
class _FixedAdapter implements HttpClientAdapter {
  final int status;
  final String body;
  _FixedAdapter(this.status, this.body);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(body, status, headers: {
      Headers.contentTypeHeader: ['application/json'],
    });
  }

  @override
  void close({bool force = false}) {}
}

class _Resp {
  final int status;
  final String body;
  const _Resp(this.status, this.body);
}

/// 按序返回 [responses] 中每个 (status, body)，用尽后重复最后一个。
class _SeqStatusAdapter implements HttpClientAdapter {
  final List<_Resp> responses;
  int _i = 0;
  _SeqStatusAdapter(this.responses);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final r = responses[_i < responses.length ? _i : responses.length - 1];
    _i++;
    return ResponseBody.fromString(r.body, r.status, headers: {
      Headers.contentTypeHeader: ['application/json'],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // TokenManager 在多个路径上调用 LogUtils，需先初始化其 late logger。
    await LogUtils.init(isProduction: true, enablePersistence: false);
  });

  // flutter_secure_storage 的内存 mock —— 让 StorageService 走安全存储分支，
  // 不触碰 get_storage（无需 init）。
  const secureChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  late Map<String, String> secureStore;

  setUp(() {
    secureStore = <String, String>{};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureChannel, (call) async {
      final args = (call.arguments as Map?)?.cast<String, dynamic>() ?? {};
      switch (call.method) {
        case 'write':
          secureStore[args['key'] as String] = args['value'] as String;
          return null;
        case 'read':
          return secureStore[args['key'] as String];
        case 'delete':
          secureStore.remove(args['key'] as String);
          return null;
        case 'readAll':
          return secureStore;
        case 'deleteAll':
          secureStore.clear();
          return null;
        case 'containsKey':
          return secureStore.containsKey(args['key'] as String);
      }
      return null;
    });
    // StorageService 是进程级单例，_useSecureStorage 可能被上一用例置 false，
    // 每个用例复位为可用。
    StorageService().debugSetSecureStorageAvailable(true);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureChannel, null);
  });

  group('validateToken', () {
    test('accepts a well-formed access token and rejects wrong type', () {
      final tm = TokenManager(tokenDio: _dioWith(_GatedAdapter(
        Future.value(),
        () => '{}',
      )));
      final access = _jwt('access_token', expEpochSec: _nowSec + 3600);
      expect(
        tm.validateToken(access, isAuthToken: false),
        TokenValidationResult.valid,
      );
      // 用 access token 充当 auth token → 类型错误
      expect(
        tm.validateToken(access, isAuthToken: true),
        TokenValidationResult.wrongType,
      );
    });

    test('flags an expired token', () {
      final tm = TokenManager(tokenDio: _dioWith(_GatedAdapter(
        Future.value(),
        () => '{}',
      )));
      final expired = _jwt('access_token', expEpochSec: _nowSec - 10);
      expect(
        tm.validateToken(expired, isAuthToken: false),
        TokenValidationResult.expired,
      );
    });
  });

  group('authTokenSubject', () {
    test('extracts the id claim from the stored auth token', () async {
      final tm = TokenManager(tokenDio: _dioWith(_GatedAdapter(
        Future.value(),
        () => '{}',
      )));
      await tm.saveAuthToken(
        _jwt('refresh_token', expEpochSec: _nowSec + 30 * 24 * 3600, id: 'userA'),
      );
      expect(tm.authTokenSubject, 'userA');
    });
  });

  group('refresh epoch guard (#1)', () {
    test('discards a stale refresh response that returns after clearTokens',
        () async {
      final gate = Completer<void>();
      final staleAccess = _jwt('access_token', expEpochSec: _nowSec + 3600,
          id: 'userA');
      final tm = TokenManager(
        tokenDio: _dioWith(
          _GatedAdapter(gate.future, () => jsonEncode({'accessToken': staleAccess})),
        ),
      );

      await tm.saveAuthToken(
        _jwt('refresh_token', expEpochSec: _nowSec + 30 * 24 * 3600, id: 'userA'),
      );

      // 发起刷新但不等待：它会停在 adapter 的 gate 上。
      final refreshFuture = tm.refreshAccessToken();
      await Future<void>.delayed(Duration.zero); // 让刷新推进到 await gate

      // 刷新在途时登出（递增代次、清空 token）。
      await tm.clearTokens();

      // 现在放行陈旧响应。
      gate.complete();
      final result = await refreshFuture;

      // 陈旧回包必须被丢弃，不得写回 access token。
      expect(result.success, isFalse);
      // superseded 不是认证失败：调用方不得据此登出(HIGH#1)。
      expect(result.isAuthError, isFalse);
      expect(result.errorMessage, contains('superseded'));
      expect(tm.accessToken, isNull);
    });

    test('new login during an in-flight refresh succeeds; stale refresh is '
        'superseded (not an auth error) — HIGH#1', () async {
      final gate = Completer<void>();
      final accessOld = _jwt('access_token', expEpochSec: _nowSec + 3600,
          id: 'userA');
      final accessNew = _jwt('access_token', expEpochSec: _nowSec + 3600,
          id: 'userB');
      final tm = TokenManager(
        tokenDio: _dioWith(_SequencedAdapter(
          firstGate: gate.future,
          firstBody: jsonEncode({'accessToken': accessOld}),
          laterBody: jsonEncode({'accessToken': accessNew}),
        )),
      );

      // 旧会话：保存 refresh A，并发起一次刷新(被 gate 卡住，模拟后台刷新在途)。
      await tm.saveAuthToken(
        _jwt('refresh_token', expEpochSec: _nowSec + 30 * 24 * 3600, id: 'userA'),
      );
      final staleRefresh = tm.refreshAccessToken();
      await Future<void>.delayed(Duration.zero); // 推进到 gate

      // 新登录：保存 refresh B（代次递增），随后发起登录侧刷新。
      await tm.saveAuthToken(
        _jwt('refresh_token', expEpochSec: _nowSec + 30 * 24 * 3600, id: 'userB'),
      );
      final loginRefresh = await tm.refreshAccessToken();

      // 登录侧刷新必须成功并写回新 token（不被旧刷新拖累）。
      expect(loginRefresh.success, isTrue);
      expect(tm.accessToken, accessNew);

      // 放行旧刷新：它必须被判为 superseded，且不是认证失败，
      // 否则后台路径会据此把新会话登出(HIGH#1)。
      gate.complete();
      final staleResult = await staleRefresh;
      expect(staleResult.success, isFalse);
      expect(staleResult.isAuthError, isFalse);
      // 新会话的 token 不能被旧刷新覆盖。
      expect(tm.accessToken, accessNew);
    });

    test('a normal refresh (no session change) writes the access token',
        () async {
      final gate = Completer<void>()..complete();
      final newAccess = _jwt('access_token', expEpochSec: _nowSec + 3600,
          id: 'userA');
      final tm = TokenManager(
        tokenDio: _dioWith(
          _GatedAdapter(gate.future, () => jsonEncode({'accessToken': newAccess})),
        ),
      );

      await tm.saveAuthToken(
        _jwt('refresh_token', expEpochSec: _nowSec + 30 * 24 * 3600, id: 'userA'),
      );

      final result = await tm.refreshAccessToken();

      expect(result.success, isTrue);
      expect(tm.accessToken, newAccess);
    });
  });

  group('fail-closed token storage (HIGH#1)', () {
    test('does not persist token to plaintext when secure storage unavailable',
        () async {
      // 安全存储不可用：token 写入必须 fail-closed（不落明文/普通存储）。
      StorageService().debugSetSecureStorageAvailable(false);
      final tm = TokenManager(tokenDio: _dioWith(_GatedAdapter(
        Future.value(),
        () => '{}',
      )));

      // 不应抛错（若降级到未初始化的 GetStorage box 会抛 StateError）。
      await tm.saveAuthToken(
        _jwt('refresh_token', expEpochSec: _nowSec + 30 * 24 * 3600, id: 'userA'),
      );

      // token 仅保留在内存（当前会话可用），但未写入安全存储。
      expect(tm.hasRefreshToken, isTrue);
      expect(secureStore.containsKey(KeyConstants.authToken), isFalse);
    });
  });

  group('logout revocation tombstone (HIGH#3)', () {
    test('residual token from a revoked session is discarded on restart',
        () async {
      final tm1 = TokenManager(tokenDio: _dioWith(_GatedAdapter(
        Future.value(),
        () => '{}',
      )));
      await tm1.saveAuthToken(
        _jwt('refresh_token', expEpochSec: _nowSec + 30 * 24 * 3600, id: 'userA'),
      );
      // 此时 secureStore 有 token，stamp='0'，counter 未写(=0)。
      expect(secureStore[KeyConstants.authTokenStamp], '0');

      // 模拟"登出时 secure 删除失败但代次已 bump"：手动把作废代次推进到 1，
      // 同时保留残留 token 与旧 stamp('0')。
      secureStore[KeyConstants.authRevocationCounter] = '1';

      // 重启：新的 TokenManager 加载残留数据。
      final tm2 = TokenManager(tokenDio: _dioWith(_GatedAdapter(
        Future.value(),
        () => '{}',
      )));
      await tm2.init();

      // 代次不符(stamp=0 != counter=1) → 残留 token 被作废，无法复活。
      expect(tm2.hasRefreshToken, isFalse);
      expect(tm2.accessToken, isNull);
    });

    test('legacy token without stamp is kept and back-stamped (upgrade-safe)',
        () async {
      // 模拟升级前：仅有 token，无 stamp、无 counter。
      secureStore[KeyConstants.authToken] =
          _jwt('refresh_token', expEpochSec: _nowSec + 30 * 24 * 3600, id: 'userA');

      final tm = TokenManager(tokenDio: _dioWith(_GatedAdapter(
        Future.value(),
        () => '{}',
      )));
      await tm.init();

      // 旧 token 不应被误丢弃，且应补盖当前代次(0)纳入墓碑保护。
      expect(tm.hasRefreshToken, isTrue);
      expect(secureStore[KeyConstants.authTokenStamp], '0');
    });
  });

  group('refresh 401 容错 (治根因B)', () {
    test('首个 401 按可重试网络错误处理不登出；连续第二个才判定失效', () async {
      final tm = TokenManager(tokenDio: _dioWith(_FixedAdapter(401, '')));
      await tm.saveAuthToken(
        _jwt('refresh_token', expEpochSec: _nowSec + 30 * 24 * 3600, id: 'userA'),
      );

      var now = DateTime.now();
      tm.clock = () => now;

      // 第 1 次 401：网络错误(可重试)，绝不据此登出——保住完好的 30 天 token。
      final r1 = await tm.refreshAccessToken();
      expect(r1.success, isFalse);
      expect(r1.isAuthError, isFalse, reason: '首个 401 不得据此登出(治根因B)');
      expect(tm.hasRefreshToken, isTrue);

      // 隔 30 秒以上的第 2 次 401：确认失效，返回认证错误。
      now = now.add(const Duration(seconds: 31));
      final r2 = await tm.refreshAccessToken();
      expect(r2.isAuthError, isTrue);
    });

    test('几秒内连打的两次 401 算同一次抖动，不登出', () async {
      final tm = TokenManager(tokenDio: _dioWith(_FixedAdapter(401, '')));
      await tm.saveAuthToken(
        _jwt('refresh_token', expEpochSec: _nowSec + 30 * 24 * 3600, id: 'userA'),
      );
      var now = DateTime.now();
      tm.clock = () => now;

      final r1 = await tm.refreshAccessToken();
      now = now.add(const Duration(seconds: 3));
      final r2 = await tm.refreshAccessToken();
      expect(r1.isAuthError, isFalse);
      expect(r2.isAuthError, isFalse, reason: '请求前补刷只隔几秒，不能凑满两次');
      // 401 之后的退避至少 30 秒，请求前补刷的 3 秒冷却会被拉长。
      expect(tm.refreshFailedWithin(const Duration(seconds: 3)), isTrue);
    });

    test('刷新成功后清零 401 计数，瞬时 401 不累积到登出', () async {
      final access = _jwt('access_token', expEpochSec: _nowSec + 3600, id: 'userA');
      final tm = TokenManager(
        tokenDio: _dioWith(_SeqStatusAdapter([
          const _Resp(401, ''), // 第 1 次瞬时 401
          _Resp(200, jsonEncode({'accessToken': access})), // 第 2 次成功
          const _Resp(401, ''), // 第 3 次又一次瞬时 401
        ])),
      );
      await tm.saveAuthToken(
        _jwt('refresh_token', expEpochSec: _nowSec + 30 * 24 * 3600, id: 'userA'),
      );

      final r1 = await tm.refreshAccessToken();
      expect(r1.isAuthError, isFalse); // 计数=1
      final r2 = await tm.refreshAccessToken();
      expect(r2.success, isTrue); // 成功 → 计数清零
      final r3 = await tm.refreshAccessToken();
      expect(r3.isAuthError, isFalse, reason: '成功后已清零，单个 401 不再登出');
      expect(tm.hasRefreshToken, isTrue);
    });

    test('非 401 的非成功响应(429 等)一律按可重试网络错误，不登出', () async {
      // validateStatus 放宽到 <500（对齐生产 IwaraNetworkService），使 429 以
      // 响应而非异常抵达刷新分类逻辑。
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      dio.options.validateStatus = (s) => (s ?? 0) < 500;
      dio.httpClientAdapter = _FixedAdapter(429, '');
      final tm = TokenManager(tokenDio: dio);
      await tm.saveAuthToken(
        _jwt('refresh_token', expEpochSec: _nowSec + 30 * 24 * 3600, id: 'userA'),
      );

      final r = await tm.refreshAccessToken();
      expect(r.success, isFalse);
      expect(r.isAuthError, isFalse);
      expect(tm.hasRefreshToken, isTrue);
    });
  });

  group('login staging/commit (MEDIUM#4)', () {
    test('successful login commits the new session', () async {
      final access = _jwt('access_token', expEpochSec: _nowSec + 3600,
          id: 'userA');
      final tm = TokenManager(tokenDio: _dioWith(_GatedAdapter(
        Future.value(),
        () => jsonEncode({'accessToken': access}),
      )));
      final refresh = _jwt('refresh_token', expEpochSec: _nowSec + 30 * 24 * 3600,
          id: 'userA');

      final result = await tm.loginWithRefreshToken(refresh);

      expect(result.success, isTrue);
      expect(tm.authToken, refresh);
      expect(tm.accessToken, access);
    });

    test('failed token exchange does NOT destroy the existing session',
        () async {
      final oldRefresh = _jwt('refresh_token',
          expEpochSec: _nowSec + 30 * 24 * 3600, id: 'userOld');
      final oldAccess = _jwt('access_token', expEpochSec: _nowSec + 3600,
          id: 'userOld');
      // 第一次换取成功(提交旧会话)，第二次返回 401(新登录失败)。
      final tm = TokenManager(tokenDio: _dioWith(
        _LoginSeqAdapter(jsonEncode({'accessToken': oldAccess}), 401),
      ));

      final first = await tm.loginWithRefreshToken(oldRefresh);
      expect(first.success, isTrue);
      expect(tm.accessToken, oldAccess);

      // 新登录的 token 交换失败：旧会话必须完好无损(MEDIUM#4)。
      final newRefresh = _jwt('refresh_token',
          expEpochSec: _nowSec + 30 * 24 * 3600, id: 'userNew');
      final second = await tm.loginWithRefreshToken(newRefresh);

      expect(second.success, isFalse);
      expect(tm.authToken, oldRefresh);
      expect(tm.accessToken, oldAccess);
    });
  });
}
