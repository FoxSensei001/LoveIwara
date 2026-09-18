import 'dart:async';
import 'dart:io';

/// [fetchGatewayFileTo] 的结局。「太大」与「没拉到」必须分开：前者是这个文件
/// 自己的确定性结论（可以记负缓存），后者多半是网络暂时不好（只该计熔断）。
enum GatewayFetchResult { ok, tooLarge, failed }

/// 把本机网关上的一个 NAS 文件拉到本机 [target]。给封面 / 图片缩略图用。
///
/// - 超过 [maxBytes] 直接放弃（先看 `Content-Length`，没有长度就边收边数），
///   返回 [GatewayFetchResult.tooLarge]：封面不值得为一张巨图拉几十 MB。
/// - 先写临时文件再改名：半截文件绝不会以「成功的缓存」出现在 [target]。
/// - 直连（`findProxy` DIRECT）：网关在回环地址上，绝不能进用户代理。
Future<GatewayFetchResult> fetchGatewayFileTo(
  String gatewayUrl,
  File target, {
  required int maxBytes,
  Duration timeout = const Duration(seconds: 30),
}) async {
  final client = HttpClient()..findProxy = ((_) => 'DIRECT');
  final temp = File('${target.path}.part');
  try {
    final request = await client.getUrl(Uri.parse(gatewayUrl)).timeout(timeout);
    final response = await request.close().timeout(timeout);
    if (response.statusCode != HttpStatus.ok) {
      await response.drain<void>().catchError((_) {});
      return GatewayFetchResult.failed;
    }
    // 太大：不 drain（那会把整个文件下完），finally 里强关连接即掐断。
    if (response.contentLength > maxBytes) return GatewayFetchResult.tooLarge;
    await target.parent.create(recursive: true);
    final out = temp.openWrite();
    var received = 0;
    var tooLarge = false;
    try {
      await for (final chunk in response.timeout(timeout)) {
        received += chunk.length;
        if (received > maxBytes) {
          tooLarge = true;
          break;
        }
        out.add(chunk);
      }
    } finally {
      await out.close();
    }
    if (tooLarge) {
      await temp.delete().catchError((_) => temp);
      return GatewayFetchResult.tooLarge;
    }
    await temp.rename(target.path);
    return GatewayFetchResult.ok;
  } catch (_) {
    if (await temp.exists()) await temp.delete().catchError((_) => temp);
    return GatewayFetchResult.failed;
  } finally {
    client.close(force: true);
  }
}
