import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/x_version_salt_service.dart';
import 'package:i_iwara/utils/x_version_calculator_utils.dart';

/// 签名盐值自动更新的单测。
///
/// 盐值不对时文件服务器不报错，只返回 360 / preview 两档，所以「清单里
/// 有没有 Source」是唯一能抓到的信号；提取盐值则依赖官网前端的写法。
/// 下面的 HTML / JS 片段取自 2026-10 的 www.iwara.tv。
///
/// 官网刷新相关的用例走真正的 `_checkSite()`：持久化、网络、时钟都换成假的，
/// 文件服务器只在 X-Version 用对了盐值时才给 Source。
void main() {
  tearDown(
    () => XVersionCalculatorUtil.salt = XVersionCalculatorUtil.defaultSalt,
  );

  group('提取规则', () {
    test('从首页 HTML 里找到 main.js', () {
      const html =
          '<link rel="icon" href="/logo.png"><script defer="defer" '
          'src="/main.838884031a28ff0e346d.js"></script></head><body>';
      expect(
        XVersionSaltService.extractMainScriptPath(html),
        '/main.838884031a28ff0e346d.js',
      );
      expect(
        XVersionSaltService.extractMainScriptPath('<html></html>'),
        isNull,
      );
    });

    test('从 main.js 里提取盐值', () {
      const js =
          'c=null!==(r=l[l.length-1])&&void 0!==r?r:"",A(!0),e.next=7,'
          '(0,u.q4)(c+"_"+o.expires+"_mSvL05GfEmeEmsEYfGCnVpEjYgTJraJN");'
          'case 7:return f=e.sent,d={"X-Version":f}';
      expect(
        XVersionSaltService.extractSalt(js),
        'mSvL05GfEmeEmsEYfGCnVpEjYgTJraJN',
      );
      expect(XVersionSaltService.extractSalt('var a="_"+b+"_";'), isNull);
    });

    test('盐值格式校验', () {
      expect(
        XVersionSaltService.isValidSalt('mSvL05GfEmeEmsEYfGCnVpEjYgTJraJN'),
        isTrue,
      );
      expect(XVersionSaltService.isValidSalt(''), isFalse);
      expect(XVersionSaltService.isValidSalt('short'), isFalse);
      expect(XVersionSaltService.isValidSalt('has space in it 12345'), isFalse);
    });

    test('盐值记录：往返一致，字段不合法时当作没有记录', () {
      const record = XVersionSaltRecord(
        salt: _newSalt,
        script: _script,
        builtinSalt: XVersionCalculatorUtil.defaultSalt,
      );
      final parsed = XVersionSaltRecord.fromJson(record.toJson())!;
      expect(parsed.salt, _newSalt);
      expect(parsed.script, _script);
      expect(parsed.builtinSalt, XVersionCalculatorUtil.defaultSalt);

      expect(XVersionSaltRecord.fromJson(<String, dynamic>{}), isNull);
      expect(XVersionSaltRecord.fromJson('x'), isNull);
      expect(
        XVersionSaltRecord.fromJson({
          'salt': 'bad salt',
          'script': _script,
          'builtin': XVersionCalculatorUtil.defaultSalt,
        }),
        isNull,
      );
    });
  });

  group('识别签名失效', () {
    test('带 Source 的清单是签过名的', () {
      expect(
        XVersionSaltService.looksUnsigned([
          {'name': 'Source'},
          {'name': '540'},
          {'name': '360'},
          {'name': 'preview'},
        ]),
        isFalse,
      );
    });

    test('只有 360 / preview 时视为签名失效', () {
      expect(
        XVersionSaltService.looksUnsigned([
          {'name': '360'},
          {'name': 'preview'},
        ]),
        isTrue,
      );
      // 老视频没有 preview，签名失效时只剩 360
      expect(
        XVersionSaltService.looksUnsigned([
          {'name': '360'},
        ]),
        isTrue,
      );
    });

    test('空清单和非清单不算', () {
      expect(XVersionSaltService.looksUnsigned([]), isFalse);
      expect(XVersionSaltService.looksUnsigned(null), isFalse);
      expect(XVersionSaltService.looksUnsigned({'message': 'x'}), isFalse);
    });

    test('X-Version 按当前盐值计算', () {
      // sha1("41e79d9c-2e9b-4a8e-8050-6e7397030753_1791709923380_mSvL05GfEmeEmsEYfGCnVpEjYgTJraJN")
      expect(
        XVersionCalculatorUtil.calculateXVersion(_url),
        'e77183e3a5aff892c701c0a7a9738bf3649d7a69',
      );
      XVersionCalculatorUtil.salt = _newSalt;
      expect(
        XVersionCalculatorUtil.calculateXVersion(_url),
        isNot('e77183e3a5aff892c701c0a7a9738bf3649d7a69'),
      );
    });
  });

  group('官网刷新', () {
    test('缺 Source 时从官网取新盐值、保存并重发', () async {
      final store = _MemoryStore();
      final site = _FakeSite(salt: _newSalt);
      final server = _FakeFileServer(validSalt: _newSalt);

      final res = await _service(
        store,
        site,
      ).requestVideoSources(_url, server.send);

      expect(_names(res), contains('Source'));
      expect(server.sent, [
        _xv(XVersionCalculatorUtil.defaultSalt),
        _xv(_newSalt),
      ]);
      expect(site.homeHits, 1);
      expect(site.scriptHits, 1);
      expect(XVersionCalculatorUtil.salt, _newSalt);
      expect(store.record!.salt, _newSalt);
      expect(store.record!.script, _script);
      expect(store.record!.builtinSalt, XVersionCalculatorUtil.defaultSalt);
    });

    test('保存过的盐值重启后直接用，不再请求官网', () async {
      final store = _MemoryStore(
        const XVersionSaltRecord(
          salt: _newSalt,
          script: _script,
          builtinSalt: XVersionCalculatorUtil.defaultSalt,
        ),
      );
      final site = _FakeSite(salt: _newSalt);
      final server = _FakeFileServer(validSalt: _newSalt);

      final res = await _service(
        store,
        site,
      ).requestVideoSources(_url, server.send);

      expect(_names(res), contains('Source'));
      expect(server.sent, [_xv(_newSalt)]);
      expect(site.requests, isEmpty);
    });

    test('⛔ 新版内置盐值变了时，旧缓存不能盖掉它（官网不可达也要能看）', () async {
      // 之前自动保存了 S1，后来官网换成 S2，用户装上内置 S2 的新版
      final store = _MemoryStore(
        const XVersionSaltRecord(
          salt: _oldSalt,
          script: _script,
          builtinSalt: 'PreviousBuiltinSalt0123',
        ),
      );
      final site = _FakeSite()..error = const SocketException('官网不可达');
      final server = _FakeFileServer(
        validSalt: XVersionCalculatorUtil.defaultSalt,
      );

      final res = await _service(
        store,
        site,
      ).requestVideoSources(_url, server.send);

      expect(_names(res), contains('Source'));
      expect(XVersionCalculatorUtil.salt, XVersionCalculatorUtil.defaultSalt);
      expect(server.sent, [_xv(XVersionCalculatorUtil.defaultSalt)]);
      expect(site.requests, isEmpty);
    });

    test('旧记录作废时，它记的 main.js 路径也不能拦住刷新', () async {
      final store = _MemoryStore(
        const XVersionSaltRecord(
          salt: _oldSalt,
          script: _script,
          builtinSalt: 'PreviousBuiltinSalt0123',
        ),
      );
      final site = _FakeSite(script: _script, salt: _newSalt);
      final server = _FakeFileServer(validSalt: _newSalt);

      final res = await _service(
        store,
        site,
      ).requestVideoSources(_url, server.send);

      expect(_names(res), contains('Source'));
      expect(site.scriptHits, 1);
      expect(store.record!.builtinSalt, XVersionCalculatorUtil.defaultSalt);
    });

    test('main.js 没变时不重复下载，原样返回第一次结果', () async {
      // 盐值是对的，只是这个视频本来就没有 Source
      final store = _MemoryStore(
        const XVersionSaltRecord(
          salt: _newSalt,
          script: _script,
          builtinSalt: XVersionCalculatorUtil.defaultSalt,
        ),
      );
      final site = _FakeSite(script: _script, salt: _newSalt);
      final server = _FakeFileServer(validSalt: null);

      final res = await _service(
        store,
        site,
      ).requestVideoSources(_url, server.send);

      expect(_names(res), ['360', 'preview']);
      expect(site.homeHits, 1);
      expect(site.scriptHits, 0);
      expect(server.sent, hasLength(1));
      expect(store.writes, 0);
    });

    test('10 分钟内只检查一次官网，过后再查', () async {
      var now = DateTime(2026, 10, 12, 12);
      final store = _MemoryStore();
      final site = _FakeSite(salt: XVersionCalculatorUtil.defaultSalt);
      final server = _FakeFileServer(validSalt: null);
      final service = _service(store, site, now: () => now);

      await service.requestVideoSources(_url, server.send);
      expect(site.homeHits, 1);
      expect(site.scriptHits, 1);

      now = now.add(const Duration(minutes: 9));
      await service.requestVideoSources(_url, server.send);
      expect(site.homeHits, 1);

      now = now.add(const Duration(minutes: 2));
      await service.requestVideoSources(_url, server.send);
      expect(site.homeHits, 2);
      // 前端没换版本，第二次不必再下 main.js
      expect(site.scriptHits, 1);
    });

    test('并发请求共用同一次官网检查', () async {
      final store = _MemoryStore();
      final site = _FakeSite(salt: _newSalt)..gate = Completer<void>();
      final server = _FakeFileServer(validSalt: _newSalt);
      final service = _service(store, site);

      final pending = List.generate(
        10,
        (_) => service.requestVideoSources(_url, server.send),
      );
      await pumpEventQueue();
      site.gate!.complete();
      final results = await Future.wait(pending);

      expect(results.map(_names), everyElement(contains('Source')));
      expect(site.homeHits, 1);
      expect(site.scriptHits, 1);
      expect(store.writes, 1);
      expect(server.sent, hasLength(20));
    });

    test('官网不可达时原样返回第一次结果，不抛异常', () async {
      final site = _FakeSite()..error = const SocketException('官网不可达');
      final server = _FakeFileServer(validSalt: _newSalt);

      final res = await _service(
        _MemoryStore(),
        site,
      ).requestVideoSources(_url, server.send);

      expect(_names(res), ['360', 'preview']);
      expect(server.sent, hasLength(1));
      expect(XVersionCalculatorUtil.salt, XVersionCalculatorUtil.defaultSalt);
    });
  });

  group('新盐值要换来 Source 才算数', () {
    test('⛔ 提取到的盐值换不来 Source 时不换、不存，内置值照常能用', () async {
      // 内置值是对的，这个视频本来就没有 Source；提取规则失配抓到了错值
      final store = _MemoryStore();
      final site = _FakeSite(salt: _newSalt);
      final service = _service(store, site);

      final res = await service.requestVideoSources(
        _url,
        _FakeFileServer(validSalt: null).send,
      );
      expect(_names(res), ['360', 'preview']);
      expect(XVersionCalculatorUtil.salt, XVersionCalculatorUtil.defaultSalt);
      expect(store.writes, 0);

      // 下一个视频照常用内置值拿到 Source
      final server = _FakeFileServer(
        validSalt: XVersionCalculatorUtil.defaultSalt,
      );
      final next = await service.requestVideoSources(_url, server.send);
      expect(_names(next), contains('Source'));
      expect(server.sent, [_xv(XVersionCalculatorUtil.defaultSalt)]);
      expect(store.writes, 0);
    });

    test('触发检查的视频没有 Source 时，新盐值等下一个视频证实后再换上', () async {
      final store = _MemoryStore();
      final site = _FakeSite(salt: _newSalt);
      final service = _service(store, site);

      await service.requestVideoSources(
        _url,
        _FakeFileServer(validSalt: null).send,
      );
      expect(XVersionCalculatorUtil.salt, XVersionCalculatorUtil.defaultSalt);

      // 节流期间不再请求官网，直接拿上次的候选盐值试
      final server = _FakeFileServer(validSalt: _newSalt);
      final res = await service.requestVideoSources(_url, server.send);
      expect(_names(res), contains('Source'));
      expect(site.homeHits, 1);
      expect(site.scriptHits, 1);
      expect(XVersionCalculatorUtil.salt, _newSalt);
      expect(store.record!.salt, _newSalt);
    });

    test('播放器等官网超时先返回第一次结果，检查做完后下一次直接用', () async {
      final store = _MemoryStore();
      final site = _FakeSite(salt: _newSalt)..gate = Completer<void>();
      final server = _FakeFileServer(validSalt: _newSalt);
      final service = _service(store, site);

      final res = await service.requestVideoSources(
        _url,
        server.send,
        keepFirstOnRetryFailure: true,
        checkSiteTimeout: const Duration(milliseconds: 20),
      );
      expect(_names(res), ['360', 'preview']);
      expect(server.sent, hasLength(1));

      site.gate!.complete();
      await pumpEventQueue();

      final next = await service.requestVideoSources(_url, server.send);
      expect(_names(next), contains('Source'));
      expect(site.homeHits, 1);
      expect(store.record!.salt, _newSalt);
    });
  });

  group('播放器等官网超时', () {
    test('⛔ 过了节流期官网又挂住时，先拿上次的候选试，不干等', () async {
      var now = DateTime(2026, 10, 16, 12);
      final store = _MemoryStore();
      final site = _FakeSite(salt: _newSalt);
      final service = _service(store, site, now: () => now);

      // 触发检查的视频本来就没有 Source：拿到候选，证实不了
      await service.requestVideoSources(
        _url,
        _FakeFileServer(validSalt: null).send,
      );
      expect(XVersionCalculatorUtil.salt, XVersionCalculatorUtil.defaultSalt);

      // 隔了 15 分钟再开视频，官网这次一直不回
      now = now.add(const Duration(minutes: 15));
      site.gate = Completer<void>();
      final res = await service.requestVideoSources(
        _url,
        _FakeFileServer(validSalt: _newSalt).send,
        keepFirstOnRetryFailure: true,
        checkSiteTimeout: const Duration(milliseconds: 20),
      );

      expect(_names(res), contains('Source'));
      expect(XVersionCalculatorUtil.salt, _newSalt);
      expect(store.record!.salt, _newSalt);

      site.gate!.complete();
      await pumpEventQueue();
    });
  });

  group('重签后的请求失败', () {
    DioException timeout() => DioException.connectionTimeout(
      timeout: const Duration(seconds: 15),
      requestOptions: RequestOptions(path: '/file'),
    );

    test('⛔ 默认（下载刷新链接）：把异常交给调用方，不能当成 Source 没了', () async {
      final server = _FakeFileServer(validSalt: _newSalt)
        ..retryError = timeout();

      final future = _service(
        _MemoryStore(),
        _FakeSite(salt: _newSalt),
      ).requestVideoSources(_url, server.send);

      await expectLater(
        future,
        throwsA(
          isA<DioException>().having(
            (e) => e.type,
            'type',
            DioExceptionType.connectionTimeout,
          ),
        ),
      );
    });

    test('播放器：沿用第一次拿到的低清晰度', () async {
      final server = _FakeFileServer(validSalt: _newSalt)
        ..retryError = timeout();

      final res = await _service(
        _MemoryStore(),
        _FakeSite(salt: _newSalt),
      ).requestVideoSources(_url, server.send, keepFirstOnRetryFailure: true);

      expect(_names(res), ['360', 'preview']);
      expect(server.sent, hasLength(2));
    });

    test('播放器：重发被取消时照常抛出', () async {
      final server = _FakeFileServer(validSalt: _newSalt)
        ..retryError = DioException.requestCancelled(
          requestOptions: RequestOptions(path: '/file'),
          reason: 'page closed',
        );

      final future = _service(
        _MemoryStore(),
        _FakeSite(salt: _newSalt),
      ).requestVideoSources(_url, server.send, keepFirstOnRetryFailure: true);

      await expectLater(future, throwsA(isA<DioException>()));
    });
  });
}

const _url =
    'https://filesq.iwara.tv/file/41e79d9c-2e9b-4a8e-8050-6e7397030753'
    '?expires=1791709923380&hash=abc';
const _script = '/main.838884031a28ff0e346d.js';
const _newSalt = 'NewSiteSalt0123456789AB';
const _oldSalt = 'OldCachedSalt0123456789';

XVersionSaltService _service(
  XVersionSaltStore store,
  _FakeSite site, {
  DateTime Function()? now,
}) => XVersionSaltService.forTest(store: store, fetch: site.fetch, now: now);

/// 用指定盐值算出的 X-Version（不改动全局盐值）。
String _xv(String salt) =>
    XVersionCalculatorUtil.calculateXVersion(_url, withSalt: salt);

List<String> _names(Response<dynamic> res) => [
  for (final item in res.data as List) (item as Map)['name'] as String,
];

class _MemoryStore implements XVersionSaltStore {
  _MemoryStore([this.record]);

  XVersionSaltRecord? record;
  int writes = 0;

  @override
  XVersionSaltRecord? read() => record;

  @override
  Future<void> write(XVersionSaltRecord record) async {
    this.record = record;
    writes++;
  }
}

/// 官网：首页指向 [script]，main.js 里写着 [salt]。
class _FakeSite {
  _FakeSite({this.script = _script, this.salt = _newSalt});

  final String script;
  final String salt;
  final List<String> requests = [];

  /// 设上就挂住所有响应，直到它完成（用来制造并发）。
  Completer<void>? gate;
  Object? error;

  int get homeHits => requests.where((p) => p == '/').length;
  int get scriptHits => requests.where((p) => p != '/').length;

  Future<String> fetch(Uri uri) async {
    // `https://www.iwara.tv` 的 path 是空串
    final path = uri.path.isEmpty ? '/' : uri.path;
    requests.add(path);
    if (gate != null) await gate!.future;
    if (error != null) throw error!;
    if (path == '/') {
      return '<script defer="defer" src="$script"></script>';
    }
    return '(0,u.q4)(c+"_"+o.expires+"_$salt");';
  }
}

/// 文件服务器：X-Version 用 [validSalt] 算出来才给 Source，否则只给
/// 360 / preview（[validSalt] 为 null 时永远不给，模拟本来就没有原档的视频）。
class _FakeFileServer {
  _FakeFileServer({required this.validSalt});

  final String? validSalt;
  final List<String> sent = [];

  /// 第二次及以后的请求抛出它（模拟重签后的请求失败）。
  Object? retryError;

  Future<Response<dynamic>> send(Map<String, dynamic> headers) async {
    final xVersion = headers['X-Version'] as String;
    sent.add(xVersion);
    if (sent.length > 1 && retryError != null) throw retryError!;
    final signed = validSalt != null && xVersion == _xv(validSalt!);
    return Response(
      data: signed
          ? [
              {'name': 'Source'},
              {'name': '360'},
            ]
          : [
              {'name': '360'},
              {'name': 'preview'},
            ],
      statusCode: 200,
      requestOptions: RequestOptions(path: '/file'),
    );
  }
}
