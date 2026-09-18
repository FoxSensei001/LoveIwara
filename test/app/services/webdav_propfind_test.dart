import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/webdav/webdav_propfind.dart';
import 'package:i_iwara/utils/loopback_host.dart';

String _multistatus(String prefix, String responses) =>
    '<?xml version="1.0" encoding="utf-8"?>'
    '<$prefix:multistatus xmlns:$prefix="DAV:">$responses</$prefix:multistatus>';

String _response(
  String prefix,
  String href, {
  bool dir = false,
  String? length,
  String? modified,
  String status = 'HTTP/1.1 200 OK',
}) =>
    '<$prefix:response><$prefix:href>$href</$prefix:href>'
    '<$prefix:propstat><$prefix:prop>'
    '<$prefix:resourcetype>${dir ? '<$prefix:collection/>' : ''}</$prefix:resourcetype>'
    '${length != null ? '<$prefix:getcontentlength>$length</$prefix:getcontentlength>' : ''}'
    '${modified != null ? '<$prefix:getlastmodified>$modified</$prefix:getlastmodified>' : ''}'
    '</$prefix:prop><$prefix:status>$status</$prefix:status></$prefix:propstat>'
    '</$prefix:response>';

void main() {
  group('parsePropfind', () {
    test('按命名空间认元素，与前缀无关', () {
      for (final prefix in ['D', 'd', 'ns0']) {
        final body = _multistatus(
          prefix,
          _response(prefix, '/video/', dir: true) +
              _response(
                prefix,
                '/video/EP01%20%5BSBS%5D.mp4',
                length: '2000',
                modified: 'Fri, 18 Sep 2026 12:19:56 GMT',
              ) +
              _response(prefix, '/video/%E5%89%A7%E9%9B%86/', dir: true),
        );
        final entries = parsePropfind(body, requestServerPath: '/video');
        expect(entries.map((e) => e.serverPath), [
          '/video/EP01 [SBS].mp4',
          '/video/剧集',
        ], reason: prefix);
        expect(entries.first.size, 2000);
        expect(
          entries.first.modifiedMs,
          DateTime.utc(2026, 9, 18, 12, 19, 56).millisecondsSinceEpoch,
        );
        expect(entries.last.isDirectory, isTrue);
        expect(entries.last.size, isNull);
      }
    });

    test('href 是绝对 URL 时只取路径；`+` 在路径里不是空格；非法 % 保留原文', () {
      final body = _multistatus(
        'D',
        _response('D', 'http://nas:5005/a/') +
            _response('D', 'http://nas:5005/a/x+y%231.mp4', length: '1') +
            _response('D', '/a/100%.mp4', length: '1'),
      );
      final entries = parsePropfind(body, requestServerPath: '/a/');
      expect(entries.map((e) => e.serverPath), ['/a/x+y#1.mp4', '/a/100%.mp4']);
    });

    test('只读 200 的 propstat；只收直接子项', () {
      final body = _multistatus(
        'D',
        [
          _response('D', '/a/b.mp4', length: '5'),
          _response('D', '/a/deep/c.mp4', length: '1'),
          '<D:response><D:href>/a/z.mp4</D:href>'
              '<D:propstat><D:prop><D:getcontentlength>9</D:getcontentlength></D:prop>'
              '<D:status>HTTP/1.1 200 OK</D:status></D:propstat>'
              '<D:propstat><D:prop><D:resourcetype><D:collection/></D:resourcetype></D:prop>'
              '<D:status>HTTP/1.1 404 Not Found</D:status></D:propstat>'
              '</D:response>',
        ].join(),
      );
      final entries = parsePropfind(body, requestServerPath: '/a');
      expect(entries.map((e) => e.serverPath), ['/a/b.mp4', '/a/z.mp4']);
      expect(entries.last.isDirectory, isFalse);
      expect(entries.last.size, 9);
    });

    test('根目录', () {
      final body = _multistatus(
        'D',
        _response('D', '/', dir: true) + _response('D', '/v.mp4', length: '1'),
      );
      expect(
        parsePropfind(body, requestServerPath: '/').single.serverPath,
        '/v.mp4',
      );
    });
  });

  test('isLoopbackHost', () {
    expect(isLoopbackHost('127.0.0.1'), isTrue);
    expect(isLoopbackHost('LOCALHOST'), isTrue);
    expect(isLoopbackHost('::1'), isTrue);
    expect(isLoopbackHost('192.168.1.5'), isFalse);
    expect(isLoopbackHost('127example.com'), isFalse);
  });
}
