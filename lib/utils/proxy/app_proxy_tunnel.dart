import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:i_iwara/utils/logger_utils.dart';
import 'package:i_iwara/utils/loopback_host.dart';

/// 应用内 HTTP 代理：HTTPS 的 CONNECT 隧道由我们自己建，不交给 `dart:io`。
///
/// ⛔ 为什么不直接 `findProxy = 'PROXY host:port'`：`dart:io` 经 HTTP 代理访问
/// HTTPS 时**永远不复用连接**。`http_impl.dart` 的 `_getConnection` 按「代理地址」
/// （`ssh:127.0.0.1:7890`）找空闲连接，隧道建好后却按「目标站」
/// （`ssh:api.iwara.tv:443`）登记、归还，两个键永远对不上。于是每个请求都重新
/// CONNECT + TLS 握手（经代理每次约 0.65–1.5 s），空闲隧道还在错误的池子里
/// 挂满 idleTimeout 才关。2026-11-17 在 Mac 上实测：PROXY 下 4 次请求建 4 条连接，
/// DIRECT 下只建 1 条。
///
/// 做法：对 HTTPS 告诉 `dart:io`「这是直连」，真正的连接由 [connectionFactory]
/// 建好：连代理 → CONNECT → TLS 握手 → 交回一个现成的 [SecureSocket]。`dart:io`
/// 于是按目标站登记它，连接池正常复用。明文 HTTP 仍走 `dart:io` 原生的代理路径
/// （它按代理地址登记、也按代理地址查，本来就能复用）。
///
/// 代理连不上、CONNECT 被拒、隧道里握手失败：一律改走直连，和原来
/// `PROXY x; DIRECT` 的语义一致（用户 2026-11-17 定：「代理连不上时走 TUN」）。
class AppProxyTunnel {
  AppProxyTunnel(
    this.proxyHost,
    this.proxyPort, {
    bool Function(String host)? bypass,
    this.proxyConnectTimeout = const Duration(seconds: 3),
    this.connectResponseTimeout = const Duration(seconds: 8),
    this.onBadCertificate,
  }) : _bypass = bypass ?? isLoopbackHost;

  final String proxyHost;
  final int proxyPort;

  /// 连代理端口的上限，超时就改走直连。
  ///
  /// ⛔ 必须远小于调用方的连接超时（Dio 是 15 s，管整个 `openUrl`）：代理机器
  /// 关机、手机换了网段时 SYN 被丢，系统层要挂约 75 s，等不到它报错整个请求
  /// 就已经超时被取消，「改走直连」根本轮不到。代理一般在本机或局域网，3 s 足够。
  final Duration proxyConnectTimeout;

  /// 代理接了 TCP、却迟迟不回 CONNECT 的上限，超时就改走直连。代理要先连上
  /// 远端才回 200，慢节点要几秒；留出 15 s 里剩下的给直连。
  final Duration connectResponseTimeout;

  /// 隧道里的 TLS 由我们握手，`HttpClient.badCertificateCallback` 管不到这里。
  /// 需要自定义证书校验的客户端从这里传（目前经代理的客户端都没有，只有测试用）。
  final bool Function(X509Certificate certificate)? onBadCertificate;

  /// 哪些主机不进代理。默认只放过本机回环（与原 `findProxy` 一致）；测试里换掉，
  /// 好让回环上的假服务器也走隧道。
  final bool Function(String host) _bypass;

  static const String _tag = 'AppProxyTunnel';

  /// 给 [client] 装上代理。[context] 必须是创建 [client] 时用的那个——隧道里的
  /// TLS 握手由我们做，`dart:io` 不会再替我们传。
  void install(HttpClient client, {SecurityContext? context}) {
    client.findProxy = (uri) {
      if (_bypass(uri.host)) return 'DIRECT';
      if (uri.scheme == 'https') return 'DIRECT';
      return 'PROXY $proxyHost:$proxyPort; DIRECT';
    };
    client.connectionFactory = (uri, viaProxyHost, viaProxyPort) {
      // findProxy 选了代理（只有明文 HTTP 会这样）：交给 dart:io 原样处理。
      if (viaProxyHost != null) {
        return Socket.startConnect(viaProxyHost, viaProxyPort!);
      }
      if (uri.scheme != 'https') {
        return Socket.startConnect(uri.host, uri.port);
      }
      if (_bypass(uri.host)) {
        return SecureSocket.startConnect(
          uri.host,
          uri.port,
          context: context,
          onBadCertificate: onBadCertificate,
        );
      }
      return Future.value(_startTunnel(uri.host, uri.port, context));
    };
  }

  ConnectionTask<SecureSocket> _startTunnel(
    String host,
    int port,
    SecurityContext? context,
  ) {
    final attempt = _TunnelAttempt();
    return ConnectionTask.fromSocket(
      _openWithFallback(host, port, context, attempt),
      attempt.cancel,
    );
  }

  Future<SecureSocket> _openWithFallback(
    String host,
    int port,
    SecurityContext? context,
    _TunnelAttempt attempt,
  ) async {
    try {
      return await _openTunnel(host, port, context, attempt);
    } catch (e) {
      if (attempt.cancelled) rethrow;
      LogUtils.w('经代理 $proxyHost:$proxyPort 连 $host:$port 失败，改走直连: $e', _tag);
      final task = await SecureSocket.startConnect(
        host,
        port,
        context: context,
        onBadCertificate: onBadCertificate,
      );
      attempt.onCancel(task.cancel);
      return attempt.keep(await task.socket);
    }
  }

  Future<SecureSocket> _openTunnel(
    String host,
    int port,
    SecurityContext? context,
    _TunnelAttempt attempt,
  ) async {
    final connectTask = await Socket.startConnect(proxyHost, proxyPort);
    attempt.onCancel(connectTask.cancel);
    final socket = attempt.keep(
      await connectTask.socket.timeout(
        proxyConnectTimeout,
        onTimeout: () {
          connectTask.cancel();
          throw SocketException('连代理超时（${proxyConnectTimeout.inSeconds}s）');
        },
      ),
    );
    // 握手阶段 destroy 管不住（底层已交给 SecureSocket），靠 keep 在握手完成后收尾。
    attempt.onCancel(socket.destroy);
    try {
      final authority = host.contains(':') ? '[$host]:$port' : '$host:$port';
      socket.add(
        ascii.encode('CONNECT $authority HTTP/1.1\r\nHost: $authority\r\n\r\n'),
      );
      await _readConnectResponse(socket).timeout(connectResponseTimeout);
      // 不能先 pause：SecureSocket.secure 会接管底层订阅，暂停着的订阅它不收。
      // 代理回完 200 之后、我们发 ClientHello 之前不会再来数据，不会丢字节。
      return attempt.keep(
        await SecureSocket.secure(
          socket,
          host: host,
          context: context,
          onBadCertificate: onBadCertificate,
        ),
      );
    } catch (_) {
      socket.destroy();
      rethrow;
    }
  }

  /// 读到 CONNECT 响应头结束为止，状态码不是 200 就抛。
  Future<void> _readConnectResponse(Socket socket) {
    final completer = Completer<void>();
    final buffer = BytesBuilder(copy: false);
    late final StreamSubscription<Uint8List> sub;
    sub = socket.listen(
      (data) {
        if (completer.isCompleted) return;
        buffer.add(data);
        final bytes = buffer.toBytes();
        final end = _headerEnd(bytes);
        if (end < 0) {
          if (bytes.length > 16 * 1024) {
            completer.completeError(const SocketException('代理的 CONNECT 响应头过长'));
          }
          return;
        }
        if (end != bytes.length) {
          completer.completeError(
            const SocketException('代理在 CONNECT 响应头之后多发了数据'),
          );
          return;
        }
        final statusLine = latin1
            .decode(bytes.sublist(0, end))
            .split('\r\n')
            .first;
        final parts = statusLine.split(' ');
        final code = parts.length >= 2 ? int.tryParse(parts[1]) : null;
        if (code == 200) {
          completer.complete();
        } else {
          completer.completeError(SocketException('代理拒绝 CONNECT: $statusLine'));
        }
      },
      onError: (Object e, StackTrace st) {
        if (!completer.isCompleted) completer.completeError(e, st);
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.completeError(
            const SocketException('代理在回复 CONNECT 前关闭了连接'),
          );
        }
      },
    );
    // 失败时把订阅收掉；成功时订阅留给 SecureSocket.secure 去接管。
    return completer.future.catchError((Object e, StackTrace st) {
      unawaited(sub.cancel());
      Error.throwWithStackTrace(e, st);
    });
  }

  /// `\r\n\r\n` 之后的下标；没找到返回 -1。
  static int _headerEnd(Uint8List b) {
    for (var i = 3; i < b.length; i++) {
      if (b[i - 3] == 13 && b[i - 2] == 10 && b[i - 1] == 13 && b[i] == 10) {
        return i + 1;
      }
    }
    return -1;
  }

  /// 解析 `host:port` / `http://host:port` / `[::1]:7890`。不合法时抛 [ArgumentError]。
  static (String, int) parseAddress(String url) {
    var cleaned = url.trim();
    if (cleaned.startsWith('http://')) cleaned = cleaned.substring(7);
    if (cleaned.startsWith('https://')) cleaned = cleaned.substring(8);
    if (cleaned.endsWith('/')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }

    String host;
    String portStr;
    if (cleaned.startsWith('[')) {
      // IPv6 字面量: [::1]:7890 —— 不能用 lastIndexOf(':') 切分
      final end = cleaned.indexOf(']');
      if (end == -1) throw ArgumentError('Invalid IPv6 proxy URL: $url');
      host = cleaned.substring(1, end);
      final rest = cleaned.substring(end + 1);
      if (!rest.startsWith(':')) {
        throw ArgumentError('Missing proxy port in URL: $url');
      }
      portStr = rest.substring(1);
    } else {
      final colonIdx = cleaned.lastIndexOf(':');
      if (colonIdx == -1) throw ArgumentError('Invalid proxy URL: $url');
      host = cleaned.substring(0, colonIdx);
      portStr = cleaned.substring(colonIdx + 1);
    }
    final port = int.tryParse(portStr.trim());
    if (port == null || port < 1 || port > 65535) {
      throw ArgumentError('Invalid proxy port in URL: $url');
    }
    return (host, port);
  }
}

/// 一次建隧道（含回退直连）的取消状态。
///
/// ⛔ `dart:io` 在连接超时时只调 `cancel()`、不会替我们关掉之后才落地的 socket：
/// 取消时还在连的，要真的把连接掐掉；掐不掉的（隧道里的 TLS 握手），等它落地
/// 由 [keep] 关掉，否则就是一条没人管的连接。
class _TunnelAttempt {
  bool cancelled = false;
  void Function()? _abort;

  /// 登记「取消时要做的事」，替换上一阶段的。已经取消了就当场执行。
  void onCancel(void Function() abort) {
    if (cancelled) {
      abort();
    } else {
      _abort = abort;
    }
  }

  void cancel() {
    if (cancelled) return;
    cancelled = true;
    final abort = _abort;
    _abort = null;
    abort?.call();
  }

  /// 取消之后才落地的 socket 已经没人要了：关掉并抛错。
  T keep<T extends Socket>(T socket) {
    if (cancelled) {
      socket.destroy();
      throw const SocketException('连接任务已取消');
    }
    return socket;
  }
}

final Object _directHttpClientZoneKey = Object();

/// 建一个**绕过应用内代理**的 [HttpClient]。
///
/// ⛔ 要直连的地方（局域网投屏、本机网关、NAS）只设 `findProxy = DIRECT` 已经不够：
/// 全局 `HttpOverrides` 会给每个 `HttpClient()` 装上 [AppProxyTunnel] 的
/// `connectionFactory`，它在「直连」请求里照样会建隧道。在这个 zone 里创建的
/// 客户端，`MyHttpOverrides` 不会装代理。
HttpClient createDirectHttpClient({SecurityContext? context}) {
  final client = runZoned(
    () => HttpClient(context: context),
    zoneValues: {_directHttpClientZoneKey: true},
  );
  client.findProxy = (_) => 'DIRECT';
  return client;
}

/// 当前是否在 [createDirectHttpClient] 的创建过程中（给 `HttpOverrides` 判断用）。
bool get isCreatingDirectHttpClient =>
    Zone.current[_directHttpClientZoneKey] == true;
