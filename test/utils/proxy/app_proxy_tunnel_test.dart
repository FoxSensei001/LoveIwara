import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/utils/proxy/app_proxy_tunnel.dart';

// 本地自签证书（CN/SAN = localhost，有效期 100 年），只给这个测试用。
const _certPem = '''-----BEGIN CERTIFICATE-----
MIIDADCCAeigAwIBAgIUAWiAe/NpZyzTQSBmJgRxSqg9YrowDQYJKoZIhvcNAQEL
BQAwFDESMBAGA1UEAwwJbG9jYWxob3N0MCAXDTI2MTExNzE0MjM1N1oYDzIxMjYx
MDI0MTQyMzU3WjAUMRIwEAYDVQQDDAlsb2NhbGhvc3QwggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQDCuoBVOAmy1ZjmOAfx9HKtjbKdHx2PgQAUmfSzyVLl
BpaMr39DFrGD6Itqp5trNulF8obGdF4zAxObZB7/1IT7LriIaXIn1UFqfLsvl1r7
PV/E5lEW/oyAKtS9Wilr4PUQpugjlEopDj+ga27shSQ7Z/vE6n25LAsri4/L919x
AmKIPZ99RGSTN5zN5NAFmClz/QiVa8HjQmmnlDXbVJVnVcJfbcJybSQK+RYVMbU3
eiqOyXyjrK32Q6C9hmzXyuXTmCnWJK1d0qB4GyW8jS5qC7kWcqHrY4bodbBRSF0t
T2KlZ7V8wQfo3KuEeE0vmKbRNkzlmtL2HZRs33OJ26UpAgMBAAGjSDBGMB0GA1Ud
DgQWBBRJjSqxACfW3wElYhrMgU05scVUiTAPBgNVHRMBAf8EBTADAQH/MBQGA1Ud
EQQNMAuCCWxvY2FsaG9zdDANBgkqhkiG9w0BAQsFAAOCAQEAvtk4JXoVkyRCTiCY
onTxYi7LfjMKQ06EPrOs6CrSn43JKbj5bbfoH3ioCpx7+AtrQ/dJHRca6X+4lief
jeIwGkRTj6XJSMYtXHOday2fHdnrXEZGYJwN2kJxmKrSd6P8AJ02qW0G4UIAgwI1
MI9IXutnziLVljJCOVshmDiSbLixYeN7izk71NXcddbK3f0gGXdmdBnsmAgM1X38
yjLLSrPXLTtWk3C16ORonDXTlYX5NWSCsvmJqrn22sYQZwRqieaZnF5ouEKYvNXZ
4UdguHRLoD7mPXAQi4dEbrLNmS2KWYbQFis1a+JMXrzZ1UuNDJbzuknhF5LrFKuN
GEx9gg==
-----END CERTIFICATE-----''';
const _keyPem = '''-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDCuoBVOAmy1Zjm
OAfx9HKtjbKdHx2PgQAUmfSzyVLlBpaMr39DFrGD6Itqp5trNulF8obGdF4zAxOb
ZB7/1IT7LriIaXIn1UFqfLsvl1r7PV/E5lEW/oyAKtS9Wilr4PUQpugjlEopDj+g
a27shSQ7Z/vE6n25LAsri4/L919xAmKIPZ99RGSTN5zN5NAFmClz/QiVa8HjQmmn
lDXbVJVnVcJfbcJybSQK+RYVMbU3eiqOyXyjrK32Q6C9hmzXyuXTmCnWJK1d0qB4
GyW8jS5qC7kWcqHrY4bodbBRSF0tT2KlZ7V8wQfo3KuEeE0vmKbRNkzlmtL2HZRs
33OJ26UpAgMBAAECggEACbxy8a/XVkx1NF+NUCTpffF1goMdgoEP7LfE4x9YCHDz
oo2cxpEyJ3b/T4IZVHs+nxtw7ye+1PycpJqVLTPmQTvVCKcDCOhR+L3LSyYda63m
Ja1hVQ29nyPlFqGVLBpnjmFV/n9p1NMsTbxJY8SFav34OeCCkDlaRp9X/Xn9GOSQ
Bfo5h8cqMhwkqRT/e3adVp0M6PvU7z6HQpWDZ+/AdnyXvuis77A/BgxJLUMiKm+G
IUuHkkftDkFZvSfDVklAxADHpG8whm+R3cp6krjHnLOOnAePFoG3uMRh2pW6I7da
/xeEOadlQFxi4FZim/bcZl2VMSPzgB7QUXd/Qor8PQKBgQDrw0gLzYMj8xHkfXAv
Uy7eHTDxb5Le5cbROMjk50SfPIX1zsAZl+RWCc0sfGgbSvExISqUoR4i1qqA1uVm
YDPiGlJE5+MfztZzDbbv3BIRP0zZdi7JfhuekhCEdjLq13aJyLk3ZVLMbBizvZCh
ifjJImNkXbWUhSeay88jAaGxlQKBgQDTcYVKF2nAzycf6VsOT5z4gel7yo6xVcSu
oaIL/cvX6exvB0eyjUrahVY9RCcQup38MkB7T+vlwVOhvwTVAmnBguTFpNmg9o2u
8K7U4xcRGRNrvRSW5LZDMw30GIYRSZnmXMm720OVNvzxQWfrNuIHqHU7A8Ddeya7
DDVtJImoRQKBgFygOGoKr/8rvFfcwHqXX858AYKZp0ZTWC1S9fqYsektyiOsuuRT
PK5g428a4Xv3kZMPyL7kHgbp98ruoun52eh3FuNjh2QzyyUgukK6X47PI848FF2t
YgSGtl6UYaTKShQP/FS7RjByN7JGQ9BzeH7tN8dy2agkOE8ky5ihR3mRAoGAMSWE
xrj0csVzoZ469POaV8TSgVyOmDeIVNLq+ICQXepYc2Iszxq6WFp/thPeRKwrxo/j
nwXvneK2zrS4qc46yKjlBe+QSjKkshHtgTwbg3Thp7w2SfB1UN9QEfmVR/VkmT/e
ABUx+z/hwS3juq9yEDeesA3qSVCzquxmiqzgdkUCgYEAhkyKHSuzRWJmjxQ69Uvs
6nEnZSRIlvEGLznKxzvIes9Q7qzSIX8wiCoJcvkeiwlAczqeLV2NqJzumhbsSnuz
ul8xwq0EbN//p8lzsoRS2LGORSgfegHmXUnlz/yepzU+bvlWMkyNIFkjPgeLUWOM
k60+4ua4nFrfOdEP8UW16XY=
-----END PRIVATE KEY-----''';

/// 假的 HTTP 代理：记下每一次 CONNECT，按 [reject] 决定放行还是拒绝。
class _FakeConnectProxy {
  _FakeConnectProxy._(this._server, this.reject);

  final ServerSocket _server;
  final bool reject;
  final List<String> connects = [];

  int get port => _server.port;

  static Future<_FakeConnectProxy> start({bool reject = false}) async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final proxy = _FakeConnectProxy._(server, reject);
    server.listen(proxy._handle);
    return proxy;
  }

  void _handle(Socket client) {
    final buf = <int>[];
    late StreamSubscription<List<int>> sub;
    sub = client.listen((data) async {
      buf.addAll(data);
      final text = latin1.decode(buf);
      if (!text.contains('\r\n\r\n')) return;
      sub.pause();
      final target = text.split('\r\n').first.split(' ')[1];
      connects.add(target);
      if (reject) {
        client.add(ascii.encode('HTTP/1.1 403 Forbidden\r\n\r\n'));
        await client.close();
        return;
      }
      final i = target.lastIndexOf(':');
      final upstream = await Socket.connect(
        target.substring(0, i),
        int.parse(target.substring(i + 1)),
      );
      client.add(ascii.encode('HTTP/1.1 200 Connection established\r\n\r\n'));
      upstream.listen(client.add, onDone: client.destroy, onError: (_) {});
      sub.onData(upstream.add);
      sub.onDone(upstream.destroy);
      sub.resume();
    }, onError: (_) {});
  }

  Future<void> close() => _server.close();
}

void main() {
  late HttpServer origin;
  late SecurityContext clientContext;
  bool acceptTestCert(X509Certificate c) => c.pem.trim() == _certPem.trim();

  setUp(() async {
    final serverContext = SecurityContext()
      ..useCertificateChainBytes(utf8.encode(_certPem))
      ..usePrivateKeyBytes(utf8.encode(_keyPem));
    origin = await HttpServer.bindSecure(
      InternetAddress.loopbackIPv4,
      0,
      serverContext,
    );
    origin.listen(
      (r) => r.response
        ..write('ok')
        ..close(),
    );
    // macOS 的系统校验不认 825 天以上的自签证书，所以不走信任根，
    // 改为在 onBadCertificate 里逐字比对就是这张证书。
    clientContext = SecurityContext(withTrustedRoots: false);
  });

  tearDown(() => origin.close(force: true));

  Future<List<String>> getTimes(HttpClient client, int n) async {
    final bodies = <String>[];
    for (var i = 0; i < n; i++) {
      final res = await (await client.getUrl(
        Uri.parse('https://localhost:${origin.port}/'),
      )).close();
      bodies.add(await res.transform(utf8.decoder).join());
    }
    return bodies;
  }

  test('经代理的 HTTPS 连接会被复用：4 次请求只 CONNECT 一次', () async {
    final proxy = await _FakeConnectProxy.start();
    final client = HttpClient(context: clientContext);
    AppProxyTunnel(
      '127.0.0.1',
      proxy.port,
      bypass: (_) => false,
      onBadCertificate: acceptTestCert,
    ).install(client, context: clientContext);

    expect(await getTimes(client, 4), everyElement('ok'));
    expect(proxy.connects, ['localhost:${origin.port}']);

    client.close(force: true);
    await proxy.close();
  });

  test('代理连不上：改走直连，请求照样成功', () async {
    final dead = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final deadPort = dead.port;
    await dead.close();
    final client = HttpClient(context: clientContext);
    AppProxyTunnel(
      '127.0.0.1',
      deadPort,
      bypass: (_) => false,
      onBadCertificate: acceptTestCert,
    ).install(client, context: clientContext);

    expect(await getTimes(client, 2), everyElement('ok'));
    client.close(force: true);
  });

  test('代理拒绝 CONNECT：改走直连，请求照样成功', () async {
    final proxy = await _FakeConnectProxy.start(reject: true);
    final client = HttpClient(context: clientContext);
    AppProxyTunnel(
      '127.0.0.1',
      proxy.port,
      bypass: (_) => false,
      onBadCertificate: acceptTestCert,
    ).install(client, context: clientContext);

    expect(await getTimes(client, 1), ['ok']);
    expect(proxy.connects, hasLength(1));
    client.close(force: true);
    await proxy.close();
  });

  test('默认放过本机回环：不经代理', () async {
    final proxy = await _FakeConnectProxy.start();
    final client = HttpClient(context: clientContext);
    AppProxyTunnel(
      '127.0.0.1',
      proxy.port,
      onBadCertificate: acceptTestCert,
    ).install(client, context: clientContext);

    expect(await getTimes(client, 1), ['ok']);
    expect(proxy.connects, isEmpty);
    client.close(force: true);
    await proxy.close();
  });

  test('createDirectHttpClient 在创建期间打上直连标记', () {
    var sawMarker = false;
    HttpOverrides.runZoned(
      () {
        createDirectHttpClient().close();
        expect(isCreatingDirectHttpClient, isFalse);
      },
      createHttpClient: (context) {
        sawMarker = isCreatingDirectHttpClient;
        return _plainClient(context);
      },
    );
    expect(sawMarker, isTrue);
  });

  test('parseAddress 兼容 http:// 前缀与 IPv6', () {
    expect(AppProxyTunnel.parseAddress('http://127.0.0.1:7890/'), (
      '127.0.0.1',
      7890,
    ));
    expect(AppProxyTunnel.parseAddress('[::1]:7890'), ('::1', 7890));
    expect(() => AppProxyTunnel.parseAddress('127.0.0.1'), throwsArgumentError);
  });
}

/// HttpOverrides.runZoned 里拿不到 super 实现，这里临时去掉覆盖再建一个原生客户端。
HttpClient _plainClient(SecurityContext? context) {
  final saved = HttpOverrides.current;
  HttpOverrides.global = null;
  try {
    return HttpOverrides.runWithHttpOverrides(
      () => HttpClient(context: context),
      _NoOverrides(),
    );
  } finally {
    HttpOverrides.global = saved;
  }
}

class _NoOverrides extends HttpOverrides {}
