import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:xml/xml.dart';

import '../cast_device.dart';
import '../lan_network.dart';

/// DLNA 投屏需要的三条 AVTransport 指令。
abstract interface class DlnaTransport {
  Future<void> setUrl(DlnaCastDevice device, String url, {String? title});

  Future<void> play(DlnaCastDevice device);

  Future<void> stop(DlnaCastDevice device);
}

/// 直接发 SOAP 的实现。
///
/// ⛔ 不用 dlna_dart 的 `DLNADevice`：它的静态 HttpClient 吃进程级代理覆盖
/// （见 [createLanHttpClient]），SOAPAction 写死 `AVTransport:1`，
/// 元数据也没按规范转义。
class SoapDlnaTransport implements DlnaTransport {
  SoapDlnaTransport({HttpClient? httpClient})
    : _http = httpClient ?? createLanHttpClient();

  final HttpClient _http;

  @override
  Future<void> setUrl(
    DlnaCastDevice device,
    String url, {
    String? title,
  }) async {
    final metadata = buildDidlMetadata(url, title: title);
    try {
      await _invoke(
        device,
        'SetAVTransportURI',
        '<InstanceID>0</InstanceID>'
            '<CurrentURI>${_esc(url)}</CurrentURI>'
            '<CurrentURIMetaData>${_esc(metadata)}</CurrentURIMetaData>',
      );
    } on CastException catch (e) {
      // 有些渲染器挑元数据（不认 protocolInfo、标题里有字符就 402/714），
      // 不带元数据重试一次——大多数电视只看 CurrentURI。设备没回话的不重试。
      if (e.kind != CastFailure.deviceRejected &&
          e.kind != CastFailure.mediaRejected) {
        rethrow;
      }
      await _invoke(
        device,
        'SetAVTransportURI',
        '<InstanceID>0</InstanceID>'
            '<CurrentURI>${_esc(url)}</CurrentURI>'
            '<CurrentURIMetaData></CurrentURIMetaData>',
      );
    }
  }

  @override
  Future<void> play(DlnaCastDevice device) =>
      _invoke(device, 'Play', '<InstanceID>0</InstanceID><Speed>1</Speed>');

  @override
  Future<void> stop(DlnaCastDevice device) =>
      _invoke(device, 'Stop', '<InstanceID>0</InstanceID>');

  Future<void> _invoke(
    DlnaCastDevice device,
    String action,
    String argumentsXml,
  ) async {
    final serviceType = device.avTransportServiceType;
    final body = utf8.encode(
      '<?xml version="1.0" encoding="utf-8"?>'
      '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" '
      's:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
      '<s:Body><u:$action xmlns:u="$serviceType">$argumentsXml</u:$action>'
      '</s:Body></s:Envelope>',
    );

    final HttpClientResponse response;
    final String text;
    try {
      final request = await _http
          .postUrl(device.avTransportControlUrl)
          .timeout(const Duration(seconds: 5));
      // 有些嵌入式服务器声明 HTTP/1.1 却回完就断：复用连接发下一条 Play 会撞上
      // 「Connection closed before full header」。每条指令单独建连。
      request.persistentConnection = false;
      request.headers
        ..set(HttpHeaders.contentTypeHeader, 'text/xml; charset="utf-8"')
        ..set('SOAPACTION', '"$serviceType#$action"');
      request.contentLength = body.length;
      request.add(body);
      response = await request.close().timeout(const Duration(seconds: 10));
      if (response.statusCode == HttpStatus.ok) {
        // 成功就不解析应答体：有的盒子回的不是合法 UTF-8，严格解码会把成功判成失败。
        await response.drain<void>().timeout(
          const Duration(seconds: 5),
          onTimeout: () {},
        );
        return;
      }
      // 错误体可能是 GBK 等编码：宽松解码，只用来抽错误码和描述。
      text = await response
          .transform(const Utf8Decoder(allowMalformed: true))
          .join()
          .timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw CastException(CastFailure.timeout, '$action 超时');
    } on SocketException catch (e) {
      throw CastException(CastFailure.unreachable, '$action: ${e.message}');
    } on HttpException catch (e) {
      throw CastException(CastFailure.unreachable, '$action: ${e.message}');
    }

    final fault = _parseUpnpError(text);
    final code = fault?.$1;
    // 714 非法 MIME / 715 资源被占用 / 716 资源找不到：都是「这个视频放不了」。
    final kind = (code == 714 || code == 715 || code == 716)
        ? CastFailure.mediaRejected
        : CastFailure.deviceRejected;
    throw CastException(
      kind,
      '$action HTTP ${response.statusCode}'
      '${code != null ? ' UPnP $code' : ''}: ${fault?.$2 ?? _shorten(text)}',
    );
  }

  static (int?, String?)? _parseUpnpError(String text) {
    try {
      final doc = XmlDocument.parse(text);
      String? find(String local) {
        for (final e in doc.descendantElements) {
          if (e.name.local == local) return e.innerText.trim();
        }
        return null;
      }

      final code = int.tryParse(find('errorCode') ?? '');
      final desc = find('errorDescription') ?? find('faultstring');
      if (code == null && desc == null) return null;
      return (code, desc);
    } catch (_) {
      return null;
    }
  }

  static String _shorten(String s) {
    final t = s.trim();
    return t.length > 200 ? '${t.substring(0, 200)}…' : t;
  }
}

/// SetAVTransportURI 的 DIDL-Lite 元数据（未转义，调用方整段转义后塞进去）。
String buildDidlMetadata(String url, {String? title}) {
  final mime = guessVideoMime(url);
  final name = (title == null || title.trim().isEmpty) ? 'Video' : title.trim();
  return '<DIDL-Lite xmlns="urn:schemas-upnp-org:metadata-1-0/DIDL-Lite/" '
      'xmlns:dc="http://purl.org/dc/elements/1.1/" '
      'xmlns:upnp="urn:schemas-upnp-org:metadata-1-0/upnp/" '
      'xmlns:dlna="urn:schemas-dlna-org:metadata-1-0/">'
      '<item id="0" parentID="-1" restricted="1">'
      '<dc:title>${_esc(name)}</dc:title>'
      '<upnp:class>object.item.videoItem</upnp:class>'
      '<res protocolInfo="http-get:*:$mime:*">${_esc(url)}</res>'
      '</item></DIDL-Lite>';
}

/// 按地址里的扩展名猜 MIME。Iwara 的直链是 `.../file/xxx?filename=yyy.mp4&...`，
/// 扩展名在查询参数里，所以整条地址一起看。
String guessVideoMime(String url) {
  final lower = url.toLowerCase();
  if (lower.contains('.m3u8')) return 'application/vnd.apple.mpegurl';
  if (lower.contains('.webm')) return 'video/webm';
  if (lower.contains('.mkv')) return 'video/x-matroska';
  if (lower.contains('.mov')) return 'video/quicktime';
  return 'video/mp4';
}

String _esc(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&apos;');
