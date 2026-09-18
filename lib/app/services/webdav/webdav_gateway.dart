import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:i_iwara/app/services/webdav/webdav_client.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// 本机回环网关：NAS 上的字节只从这一个口进出。
///
/// 地址形如 `http://127.0.0.1:<端口>/<token>/<sourceId>/<按段编码的服务端路径>`。
/// mpv、Quest 的 ExoPlayer、图片查看器都只连它，**一个请求头都不用带**：
/// 鉴权（Basic/Digest）、TLS 指纹、绕开用户代理、同源重定向全在这里做。
///
/// # 为什么要网关而不是把请求头递给播放器
///
/// - mpv 的 `tls-verify` 默认关，per-Media 请求头靠 media_kit 的全局缓存；
///   证书指纹对播放那条链路会是摆设。
/// - 全局 `HttpOverrides` 把所有 Dart 请求送进用户代理，明文 Basic 会被发给
///   第三方。
/// - Quest 沉浸态的 ExoPlayer 是另一套网络栈；凭据要经 Intent 递过去，还要管
///   明文 HTTP 策略与自签证书。
///
/// # 约束
///
/// - ⛔ **库里、播放池里绝不存网关 URL**：打开那一刻由 [urlFor] 现算。token 在
///   进程内固定；网关重启优先重绑同一端口，所以正在播放的地址大多数时候还能用。
/// - 只绑 `127.0.0.1`；token 常量时间比较。
/// - 字节只透传不解析，跑在后台 isolate，不占 UI 线程。
class WebDavGateway {
  WebDavGateway._();

  static final WebDavGateway instance = WebDavGateway._();
  static const String _tag = 'WebDavGateway';

  /// 进程内固定。网关重启沿用同一个，已经发给播放器的地址才不会因此失效。
  final String _token = _randomToken();

  final Map<String, WebDavEndpoint> _endpoints = {};
  SendPort? _commands;
  int? _port;
  Future<void>? _starting;
  Isolate? _isolate;
  ReceivePort? _events;

  bool get isRunning => _port != null && _commands != null;

  /// 把一个源的连接信息交给网关（新建、改密码、确认证书之后都要再调一次）。
  ///
  /// ⛔ 内容没变就什么都不发：每列一次目录都会走到这里，而网关收到 put 就换
  /// client——换掉的那一刻正在播放的上游连接会被掐断（边播边浏览时实打实地发生）。
  void putEndpoint(WebDavEndpoint endpoint) {
    final existing = _endpoints[endpoint.sourceId];
    if (existing != null && existing.sameAs(endpoint)) return;
    _endpoints[endpoint.sourceId] = endpoint;
    _commands?.send(['put', endpoint.toMessage()]);
  }

  void removeEndpoint(String sourceId) {
    _endpoints.remove(sourceId);
    _commands?.send(['remove', sourceId]);
  }

  bool hasEndpoint(String sourceId) => _endpoints.containsKey(sourceId);

  /// 服务端路径 → 网关 URL。会按需把网关拉起来。
  Future<String> urlFor(String sourceId, String serverPath) async {
    await ensureStarted();
    return Uri(
      scheme: 'http',
      host: InternetAddress.loopbackIPv4.address,
      port: _port,
      pathSegments: [
        _token,
        sourceId,
        ...serverPath.split('/').where((s) => s.isNotEmpty),
      ],
    ).toString();
  }

  /// 这是不是网关发出去的地址。日志脱敏、代理放行都靠它。
  static bool isGatewayUrl(String url) =>
      instance._port != null &&
      url.startsWith('http://127.0.0.1:${instance._port}/${instance._token}/');

  /// 日志用：网关 URL 的路径里有 NAS 上的文件名和进程 token，一律不落盘。
  static String redact(String url) {
    if (!url.startsWith('http://127.0.0.1:')) return url;
    final segments = Uri.tryParse(url)?.pathSegments ?? const <String>[];
    if (segments.length < 2) return 'gw:/?';
    return 'gw:/${segments[1]}/…(len=${url.length})';
  }

  static final RegExp _gatewayUrlPattern = RegExp(
    r'http://127\.0\.0\.1:\d+/[0-9a-f]{48}/\S*',
  );

  /// 把一段任意文本（播放器错误、异常信息）里出现的网关地址全部脱敏。
  static String redactIn(String text) =>
      text.replaceAllMapped(_gatewayUrlPattern, (m) => redact(m.group(0)!));

  Future<void> ensureStarted() {
    if (isRunning) return Future.value();
    return _starting ??= _start().whenComplete(() {
      _starting = null;
    });
  }

  Future<void> _start() async {
    final events = ReceivePort();
    final ready = Completer<List<Object?>>();
    // ⛔ ReceivePort 只能 listen 一次：ready / died / onExit 全在这一个监听里分。
    events.listen((message) {
      if (message is List && message.isNotEmpty && message[0] == 'ready') {
        if (!ready.isCompleted) ready.complete(message);
        return;
      }
      // 'died'（server 流报错/关闭）或 onExit 发来的 null：网关没了。
      final reason = message is List && message.length > 1
          ? message[1]
          : 'exit';
      LogUtils.w('网关已停止：$reason', _tag);
      if (!ready.isCompleted) {
        ready.completeError(StateError('网关启动失败：$reason'));
      }
      if (identical(_events, events)) _markDead();
    });
    _events = events;
    final isolate = await Isolate.spawn(
      _gatewayMain,
      [events.sendPort, _token, _port ?? 0],
      debugName: 'webdav-gateway',
      onExit: events.sendPort,
      errorsAreFatal: false,
    );
    final List<Object?> message;
    try {
      message = await ready.future.timeout(const Duration(seconds: 5));
    } catch (_) {
      // 起不来：别留一个攥着端口、谁也 stop 不了的僵尸。
      isolate.kill(priority: Isolate.immediate);
      if (identical(_events, events)) _markDead();
      rethrow;
    }
    _isolate = isolate;
    _commands = message[1] as SendPort;
    _port = message[2] as int;
    for (final endpoint in _endpoints.values) {
      _commands!.send(['put', endpoint.toMessage()]);
    }
    LogUtils.i('网关已启动（端口 $_port）', _tag);
  }

  /// 停掉网关（测试用；正常运行时它跟进程同生共死）。
  ///
  /// ⛔ 不能直接 `Isolate.kill`：被杀的 isolate 不会及时放掉监听端口，紧接着
  /// 重启就绑不回原端口（实测），已发出的地址全部作废。先让它自己关服务。
  Future<void> stop() async {
    final commands = _commands;
    final isolate = _isolate;
    if (commands == null || isolate == null) return;
    final exited = ReceivePort();
    isolate.addOnExitListener(exited.sendPort);
    commands.send(['stop']);
    await exited.first.timeout(
      const Duration(seconds: 3),
      onTimeout: () => isolate.kill(priority: Isolate.immediate),
    );
    exited.close();
    _markDead();
  }

  void _markDead() {
    _commands = null;
    _isolate = null;
    _events?.close();
    _events = null;
    // ⛔ 端口留着：下次启动优先重绑同一个，已发出的地址还能接着用。
  }

  static String _randomToken() {
    final random = Random.secure();
    return List.generate(
      24,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }
}

// ---------------------------------------------------------------------------
// 以下全部跑在网关 isolate 里。只碰参数和本 isolate 的状态。
// ---------------------------------------------------------------------------

Future<void> _gatewayMain(List<Object?> args) async {
  final events = args[0] as SendPort;
  final token = args[1] as String;
  final preferredPort = args[2] as int;
  final endpoints = <String, WebDavEndpoint>{};
  final clients = <String, HttpClient>{};

  // 优先重绑原端口：已经发给播放器的地址还能接着用。上一个网关 isolate 刚被
  // 杀时端口可能还没释放（实测紧接着重绑会失败），所以先等一会儿重试几次；
  // 实在不行才换端口，那时已发出的地址失效，播放器按「连不上」处理。
  HttpServer? bound;
  if (preferredPort != 0) {
    for (var attempt = 0; attempt < 10 && bound == null; attempt++) {
      try {
        bound = await HttpServer.bind(
          InternetAddress.loopbackIPv4,
          preferredPort,
        );
      } on SocketException {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }
  }
  final server =
      bound ?? await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.autoCompress = false;

  final commands = ReceivePort();
  // 服务停了（stop 命令、或 server 流自己出错/关闭）就把本 isolate 的资源全放掉，
  // 让它自然退出，别留一个还攥着端口的僵尸。
  Future<void> shutdown() async {
    commands.close();
    for (final client in clients.values) {
      client.close(force: true);
    }
    clients.clear();
    await server.close(force: true);
  }

  commands.listen((message) {
    if (message is! List || message.isEmpty) return;
    switch (message[0]) {
      case 'stop':
        unawaited(shutdown());
      case 'put':
        final endpoint = WebDavEndpoint.fromMessage(
          message[1] as Map<Object?, Object?>,
        );
        final previous = endpoints[endpoint.sourceId];
        if (previous != null && previous.sameAs(endpoint)) return;
        endpoints[endpoint.sourceId] = endpoint;
        // 凭据/指纹真的变了才换 client。旧的用 force: false 关：在途的请求（正在
        // 播放的那条流）让它自然走完，不当场掐断。
        clients.remove(endpoint.sourceId)?.close();
      case 'remove':
        final id = message[1] as String;
        endpoints.remove(id);
        clients.remove(id)?.close(force: true);
    }
  });

  events.send(['ready', commands.sendPort, server.port]);

  server.listen(
    (request) => unawaited(
      _handle(request, token, endpoints, clients).catchError((Object e) {
        // 响应头可能已经发出去了：那时设状态码会抛，close 必须单独兜，否则下游
        // 连接一直挂着。
        try {
          request.response.statusCode = HttpStatus.badGateway;
        } catch (_) {}
        try {
          unawaited(request.response.close().catchError((_) {}));
        } catch (_) {}
      }),
    ),
    onError: (Object e) {
      events.send(['died', '$e']);
      unawaited(shutdown());
    },
    onDone: () {
      events.send(['died', 'server closed']);
      unawaited(shutdown());
    },
    cancelOnError: false,
  );
}

bool _constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diff == 0;
}

/// 透传时原样带回给播放器的响应头。⛔ 不带 `Transfer-Encoding`/`Connection`
/// 这类逐跳头；长度由 `contentLength` 单独设。
const List<String> _passthroughResponseHeaders = [
  HttpHeaders.contentTypeHeader,
  HttpHeaders.contentRangeHeader,
  HttpHeaders.acceptRangesHeader,
  HttpHeaders.lastModifiedHeader,
  HttpHeaders.etagHeader,
  HttpHeaders.contentEncodingHeader,
];

/// 从播放器转给上游的请求头。
const List<String> _passthroughRequestHeaders = [
  HttpHeaders.rangeHeader,
  HttpHeaders.ifRangeHeader,
];

Future<void> _handle(
  HttpRequest request,
  String token,
  Map<String, WebDavEndpoint> endpoints,
  Map<String, HttpClient> clients,
) async {
  final response = request.response;
  final segments = request.uri.pathSegments;
  if (segments.length < 2 || !_constantTimeEquals(segments[0], token)) {
    response.statusCode = HttpStatus.notFound;
    await response.close();
    return;
  }
  if (request.method != 'GET' && request.method != 'HEAD') {
    response.statusCode = HttpStatus.methodNotAllowed;
    await response.close();
    return;
  }
  final endpoint = endpoints[segments[1]];
  if (endpoint == null) {
    // 凭据还没送到（主 isolate 刚重启网关）。503 让播放器当临时错误。
    response.statusCode = HttpStatus.serviceUnavailable;
    await response.close();
    return;
  }
  final serverPath = '/${segments.skip(2).join('/')}';

  final HttpClientResponse upstream;
  try {
    final opened = await _openUpstream(request, endpoint, clients, serverPath);
    if (opened == null) {
      _fail(response, 'redirect');
      return;
    }
    upstream = opened.$2;
  } on HandshakeException {
    _fail(response, 'cert');
    return;
  } on TlsException {
    _fail(response, 'cert');
    return;
  } on TimeoutException {
    _fail(response, 'unreachable', status: HttpStatus.gatewayTimeout);
    return;
  } on SocketException {
    _fail(response, 'unreachable');
    return;
  } on HttpException {
    _fail(response, 'unreachable');
    return;
  }

  response.statusCode = upstream.statusCode;
  for (final name in _passthroughResponseHeaders) {
    final value = upstream.headers.value(name);
    if (value != null) response.headers.set(name, value);
  }
  // ⛔ 显式设长度：不设 Dart 就改走 chunked，ExoPlayer 可能判成不可 seek。
  if (upstream.contentLength >= 0) {
    response.contentLength = upstream.contentLength;
  }

  if (request.method == 'HEAD') {
    await upstream.drain<void>().catchError((_) {});
    await response.close();
    return;
  }
  await _pipe(upstream, response);
}

/// 连上游：注入凭据、只跟同源重定向、401 时换一个 client 再试一次。
/// 返回 null = 跨主机重定向被拒 / 重定向过多。
Future<(HttpClientRequest, HttpClientResponse)?> _openUpstream(
  HttpRequest request,
  WebDavEndpoint endpoint,
  Map<String, HttpClient> clients,
  String serverPath,
) async {
  var url = endpoint.urlFor(serverPath);
  var retriedAuth = false;
  for (var hop = 0; hop < 4; hop++) {
    final client = clients[endpoint.sourceId] ??= createWebDavHttpClient(
      endpoint,
    );
    final upstreamRequest = await client
        .openUrl(request.method, url)
        .timeout(_upstreamHeaderTimeout);
    upstreamRequest.followRedirects = false;
    // ⛔ 必须 identity：client 的 autoUncompress 关着（要原样透传长度），
    // 服务器一压缩，带 Range 的播放器拿到的就是它没要过的 gzip 字节。
    upstreamRequest.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');
    for (final name in _passthroughRequestHeaders) {
      final value = request.headers.value(name);
      if (value != null) upstreamRequest.headers.set(name, value);
    }
    final HttpClientResponse upstream;
    try {
      // ⛔ 等响应头也要有上限：connectionTimeout 只管建连。NAS 接了连接却不回
      // （硬盘卡住）时，没有这一道每次拖进度都会在这里挂一条。此时响应还没来，
      // abort 是有效的。
      upstream = await upstreamRequest.close().timeout(_upstreamHeaderTimeout);
    } on TimeoutException {
      upstreamRequest.abort();
      rethrow;
    }
    final status = upstream.statusCode;
    if (status == 401 && !retriedAuth) {
      // 同一个 client 上凭据可能已被 SDK 摘掉（并发的首批 Digest 挑战、NAS 重启
      // 换了 nonce 密钥）。换一个干净的 client 再挑战一次，而不是把 401 直接交给
      // 播放器。
      retriedAuth = true;
      await upstream.drain<void>().catchError((_) {});
      clients.remove(endpoint.sourceId)?.close();
      continue;
    }
    if (status == 301 || status == 302 || status == 307 || status == 308) {
      await upstream.drain<void>().catchError((_) {});
      final location = upstream.headers.value(HttpHeaders.locationHeader);
      final next = location == null ? null : url.resolve(location);
      // ⛔ 跨主机重定向不跟：会把凭据带去别处。
      if (next == null || !endpoint.isSameOrigin(next)) return null;
      url = next;
      continue;
    }
    return (upstreamRequest, upstream);
  }
  return null;
}

const Duration _upstreamHeaderTimeout = Duration(seconds: 30);
const Duration _upstreamIdleTimeout = Duration(seconds: 20);

/// 上游字节 → 播放器。
///
/// ⛔ 不用 `response.addStream`：下游（播放器）断开时 HttpResponse 会把 socket
/// 错误吞掉、addStream 照常返回，上游不会被取消；而响应头到了之后
/// `HttpClientRequest.abort()` 也不再起作用。所以自己订阅、自己取消：
/// - 背压：每块写完 flush，flush 完成才 resume——播放器读得慢，上游就停着；
/// - 下游断开（flush 失败 / `response.done` 结束）→ 立刻取消上游订阅，连接随之关闭；
/// - 空闲超时只在**等上游**时计：播放器暂停、缓冲满时上游本来就该停着，不算。
Future<void> _pipe(HttpClientResponse upstream, HttpResponse response) async {
  final finished = Completer<void>();
  Timer? idle;
  late final StreamSubscription<List<int>> sub;

  void finish() {
    idle?.cancel();
    if (!finished.isCompleted) finished.complete();
  }

  void armIdle() {
    idle?.cancel();
    idle = Timer(_upstreamIdleTimeout, () {
      unawaited(sub.cancel());
      finish();
    });
  }

  sub = upstream.listen(
    (chunk) {
      idle?.cancel();
      sub.pause();
      response.add(chunk);
      response.flush().then(
        (_) {
          if (finished.isCompleted) return;
          armIdle();
          sub.resume();
        },
        onError: (Object _) {
          unawaited(sub.cancel());
          finish();
        },
      );
    },
    onDone: finish,
    onError: (Object _) => finish(),
    cancelOnError: true,
  );
  unawaited(
    response.done.then<void>((_) {}, onError: (Object _) {}).whenComplete(() {
      unawaited(sub.cancel());
      finish();
    }),
  );
  armIdle();
  await finished.future;
  try {
    await response.close();
  } catch (_) {}
}

/// 上游失败时给播放器的回话。原因放进 `X-Dav-Error`，Quest 侧据此给具体文案。
void _fail(
  HttpResponse response,
  String reason, {
  int status = HttpStatus.badGateway,
}) {
  try {
    response.statusCode = status;
    response.headers.set('X-Dav-Error', reason);
    unawaited(response.close());
  } catch (_) {}
}
