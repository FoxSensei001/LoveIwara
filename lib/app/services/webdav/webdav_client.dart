import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:i_iwara/app/services/webdav/webdav_propfind.dart';

/// 连上一个 WebDAV 服务器所需的一切。**只含可跨 isolate 传递的纯数据**：
/// 列目录在 `Isolate.run` 里跑、网关在后台 isolate 里跑，都要把它发过去。
class WebDavEndpoint {
  const WebDavEndpoint({
    required this.sourceId,
    required this.origin,
    required this.username,
    required this.password,
    this.tlsFingerprint,
  });

  final String sourceId;

  /// `scheme://host[:port]`，不带路径、不带凭据。
  final String origin;
  final String username;
  final String password;

  /// 用户确认信任过的证书 SHA-256（小写 hex）。null = 走系统信任。
  final String? tlsFingerprint;

  Uri urlFor(String serverPath) {
    final base = Uri.parse(origin);
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      // ⛔ 一律按段交给 Uri 编码，禁止字符串拼接（`#`/`%`/`?`/空格）。
      pathSegments: serverPath.split('/').where((s) => s.isNotEmpty),
    );
  }

  bool isSameOrigin(Uri other) {
    final base = Uri.parse(origin);
    return other.scheme == base.scheme &&
        other.host == base.host &&
        other.port == base.port;
  }

  Map<String, Object?> toMessage() => {
    'sourceId': sourceId,
    'origin': origin,
    'username': username,
    'password': password,
    'tlsFingerprint': tlsFingerprint,
  };

  /// 连接信息是否完全相同（凭据、指纹都算）。网关据此决定要不要换 client。
  bool sameAs(WebDavEndpoint other) =>
      sourceId == other.sourceId &&
      origin == other.origin &&
      username == other.username &&
      password == other.password &&
      tlsFingerprint == other.tlsFingerprint;

  factory WebDavEndpoint.fromMessage(Map<Object?, Object?> m) => WebDavEndpoint(
    sourceId: m['sourceId'] as String,
    origin: m['origin'] as String,
    username: m['username'] as String,
    password: m['password'] as String,
    tlsFingerprint: m['tlsFingerprint'] as String?,
  );
}

enum WebDavFailureKind {
  /// 401/403：账号密码不对，或没有权限。
  auth,

  /// 证书不受信（自签且未确认），或与确认过的指纹不符。
  cert,

  /// 连不上 / 超时 / DNS 失败。
  unreachable,

  /// 连上了但回的东西不对（不是 WebDAV、解析失败、404 等）。
  protocol,
}

class WebDavFailure implements Exception {
  const WebDavFailure(
    this.kind, {
    this.message,
    this.certFingerprint,
    this.statusCode,
    this.digestRequired = false,
  });

  final WebDavFailureKind kind;
  final String? message;

  /// [WebDavFailureKind.cert] 时服务器实际出示的证书指纹，给 TOFU 弹窗用。
  final String? certFingerprint;
  final int? statusCode;

  /// 服务器只接受 Digest。
  final bool digestRequired;

  @override
  String toString() =>
      'WebDavFailure(${kind.name}, status=$statusCode, $message)';
}

/// 证书 DER → SHA-256 小写 hex（TOFU 指纹的唯一口径）。
String certificateFingerprint(X509Certificate certificate) =>
    sha256.convert(certificate.der).toString();

/// 建一个连 NAS 专用的 [HttpClient]。
///
/// ⛔ 每一条都是踩过或审查出来的：
/// - `findProxy` 固定 DIRECT：全局 `HttpOverrides` 会把所有请求送进用户代理，
///   明文 NAS 的 Basic 凭据就这样被发给第三方；代理在另一台机器上时还根本连不上
///   局域网地址。
/// - `autoUncompress = false`：网关要原样透传字节与 `Content-Length`/
///   `Content-Range`，一解压就对不上，拖进度会坏。
/// - 固定了指纹的源用 `SecurityContext(withTrustedRoots: false)`：让**每一次**
///   握手都进 `badCertificateCallback` 比指纹。不这样的话，NAS 换成一张系统
///   受信的证书后回调根本不触发，「指纹变了就拦」形同虚设；事后读
///   `response.certificate` 再比对则凭据已经发出去了。
/// - 鉴权走 `authenticate` 回调：同一个回调同时接住 Basic 与 Digest，且只在
///   服务器挑战时才给凭据。
HttpClient createWebDavHttpClient(
  WebDavEndpoint endpoint, {
  void Function(String fingerprint)? onUntrustedCertificate,
  void Function(String scheme)? onAuthScheme,
}) {
  final pinned = endpoint.tlsFingerprint;
  final client =
      HttpClient(
          context: pinned != null
              ? SecurityContext(withTrustedRoots: false)
              : null,
        )
        ..findProxy = ((_) => 'DIRECT')
        ..autoUncompress = false
        ..connectionTimeout = const Duration(seconds: 10)
        ..idleTimeout = const Duration(seconds: 20)
        ..userAgent = 'LoveIwara-WebDAV';
  client.badCertificateCallback = (certificate, host, port) {
    final fingerprint = certificateFingerprint(certificate);
    if (pinned != null && fingerprint == pinned) return true;
    onUntrustedCertificate?.call(fingerprint);
    return false;
  };
  // ⛔ 同一 (方案, realm) **3 秒内**只给一次凭据。
  // - 不能不限：凭据被拒时 HttpClient 会**再次**调这个回调，一直返回 true 就是
  //   无限重试（实测错密码时卡满超时才返回，而不是立刻拿到 401）。
  // - 也不能「终身只给一次」：长寿的网关 client 上，SDK 会在并发的首批 Digest
  //   挑战（每次挑战新 nonce 的服务器）、NAS 重启换 nonce 密钥、一次瞬时 401 之后
  //   摘掉已有凭据再来问——那时回 false，这个 client 就永远 401。
  final lastGiven = <String, DateTime>{};
  client.authenticate = (url, scheme, realm) async {
    final key = '${scheme.toLowerCase()}\u0000$realm';
    final now = DateTime.now();
    final last = lastGiven[key];
    if (last != null && now.difference(last) < const Duration(seconds: 3)) {
      return false;
    }
    lastGiven[key] = now;
    onAuthScheme?.call(scheme.toLowerCase());
    final credentials = scheme.toLowerCase() == 'digest'
        ? HttpClientDigestCredentials(endpoint.username, endpoint.password)
        : HttpClientBasicCredentials(endpoint.username, endpoint.password);
    // ⛔ 凭据挂在**服务器根**上，不是挂在这次请求的 URL 上：HttpClient 只对
    // 「以该 URL 为前缀」的请求复用凭据。挂在某个文件上的话，网关换一个路径就
    // 会被重新挑战，而上面那道「只给一次」的闸门已经用掉了，结果是好好的文件
    // 回 401（实测：先播 A 再请求 B，B 直接 401）。
    client.addCredentials(
      Uri(scheme: url.scheme, host: url.host, port: url.port, path: '/'),
      realm ?? '',
      credentials,
    );
    return true;
  };
  return client;
}

/// 列一个目录（`PROPFIND Depth: 1`）。纯 Dart，可以在任何 isolate 里跑。
///
/// ⛔ PROPFIND 不带 body（RFC 4918：无 body 即 allprop）。带 body 的请求在
/// 401 挑战后由 HttpClient 自动重发时 body 不一定能重放。
///
/// ⛔ 不跟随重定向：跨主机的重定向会把凭据带去别处。同源重定向（常见的是
/// 目录补结尾 `/`）手动跟一次。
Future<List<DavEntry>> webDavListFolder(
  WebDavEndpoint endpoint,
  String serverPath, {
  Duration timeout = const Duration(seconds: 20),
  void Function(String scheme)? onAuthScheme,
}) async {
  String? untrustedFingerprint;
  var digestSeen = false;
  final client = createWebDavHttpClient(
    endpoint,
    onUntrustedCertificate: (fp) => untrustedFingerprint = fp,
    onAuthScheme: (scheme) {
      if (scheme == 'digest') digestSeen = true;
      onAuthScheme?.call(scheme);
    },
  );
  try {
    var url = endpoint.urlFor(serverPath);
    // 目录 URL 带结尾 `/`，省掉一次「补斜杠」的 301。
    if (!url.path.endsWith('/')) url = url.replace(path: '${url.path}/');
    for (var hop = 0; hop < 3; hop++) {
      final request = await client.openUrl('PROPFIND', url).timeout(timeout);
      request.followRedirects = false;
      request.headers.set('Depth', '1');
      // autoUncompress 关着：服务器压缩的话 utf8 解码拿到的是 gzip 字节。
      request.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');
      final response = await request.close().timeout(timeout);
      final status = response.statusCode;
      if (status == 301 || status == 302 || status == 307 || status == 308) {
        await response.drain<void>();
        final location = response.headers.value(HttpHeaders.locationHeader);
        final next = location == null ? null : url.resolve(location);
        if (next == null || !endpoint.isSameOrigin(next)) {
          throw WebDavFailure(
            WebDavFailureKind.protocol,
            statusCode: status,
            message: '跨主机重定向已拒绝',
          );
        }
        url = next;
        continue;
      }
      if (status == 401 || status == 403) {
        await response.drain<void>();
        throw WebDavFailure(
          WebDavFailureKind.auth,
          statusCode: status,
          digestRequired: digestSeen,
        );
      }
      if (status != 207) {
        await response.drain<void>();
        throw WebDavFailure(
          WebDavFailureKind.protocol,
          statusCode: status,
          message: status == 405 ? '服务器不支持 WebDAV（PROPFIND 被拒）' : null,
        );
      }
      final body = await utf8.decoder.bind(response).join().timeout(timeout);
      // 跟过同源重定向的话，响应描述的是**最终**那个路径。
      final finalPath = url.pathSegments.where((s) => s.isNotEmpty).join('/');
      final ({List<DavEntry> entries, bool containsSelf}) listing;
      try {
        listing = parsePropfindListing(body, requestServerPath: '/$finalPath');
      } on FormatException catch (e) {
        throw WebDavFailure(WebDavFailureKind.protocol, message: '$e');
      }
      if (!listing.containsSelf) {
        throw const WebDavFailure(
          WebDavFailureKind.protocol,
          message: '响应里没有请求的目录本身',
        );
      }
      return listing.entries;
    }
    throw const WebDavFailure(WebDavFailureKind.protocol, message: '重定向过多');
  } on WebDavFailure {
    rethrow;
  } on HandshakeException catch (e) {
    throw WebDavFailure(
      WebDavFailureKind.cert,
      certFingerprint: untrustedFingerprint,
      message: '$e',
    );
  } on TlsException catch (e) {
    throw WebDavFailure(
      WebDavFailureKind.cert,
      certFingerprint: untrustedFingerprint,
      message: '$e',
    );
  } on SocketException catch (e) {
    throw WebDavFailure(WebDavFailureKind.unreachable, message: '$e');
  } on TimeoutException catch (e) {
    throw WebDavFailure(WebDavFailureKind.unreachable, message: '$e');
  } on HttpException catch (e) {
    throw WebDavFailure(WebDavFailureKind.unreachable, message: '$e');
  } finally {
    client.close(force: true);
  }
}
