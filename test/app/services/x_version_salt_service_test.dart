import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/services/x_version_salt_service.dart';
import 'package:i_iwara/utils/x_version_calculator_utils.dart';

/// 签名盐值自动更新的单测。
///
/// 盐值不对时文件服务器不报错，只返回 360 / preview 两档，所以「清单里
/// 有没有 Source」是唯一能抓到的信号；提取盐值则依赖官网前端的写法。
/// 下面的 HTML / JS 片段取自 2026-10 的 www.iwara.tv。
void main() {
  tearDown(
    () => XVersionCalculatorUtil.salt = XVersionCalculatorUtil.defaultSalt,
  );

  group('提取盐值', () {
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
  });

  group('X-Version', () {
    const url =
        'https://filesq.iwara.tv/file/41e79d9c-2e9b-4a8e-8050-6e7397030753'
        '?expires=1791709923380&hash=abc';

    test('按当前盐值计算', () {
      // sha1("41e79d9c-2e9b-4a8e-8050-6e7397030753_1791709923380_mSvL05GfEmeEmsEYfGCnVpEjYgTJraJN")
      expect(
        XVersionCalculatorUtil.calculateXVersion(url),
        'e77183e3a5aff892c701c0a7a9738bf3649d7a69',
      );
      XVersionCalculatorUtil.salt = 'AnotherSaltValue0123';
      expect(
        XVersionCalculatorUtil.calculateXVersion(url),
        isNot('e77183e3a5aff892c701c0a7a9738bf3649d7a69'),
      );
    });

    test('签过名的清单直接返回，不重发', () async {
      final sentHeaders = <Map<String, dynamic>>[];
      final res = await XVersionSaltService.instance.requestVideoSources(url, (
        headers,
      ) async {
        sentHeaders.add(headers);
        return _response([
          {'name': 'Source'},
          {'name': '360'},
        ]);
      });
      expect(sentHeaders, hasLength(1));
      expect((res.data as List).first['name'], 'Source');
    });

    test('盐值已被并发请求更新时，用新盐值重发一次', () async {
      final sentHeaders = <Map<String, dynamic>>[];
      final res = await XVersionSaltService.instance.requestVideoSources(url, (
        headers,
      ) async {
        sentHeaders.add(headers);
        if (sentHeaders.length == 1) {
          // 模拟另一个请求在此期间从官网拿到了新盐值
          XVersionCalculatorUtil.salt = 'AnotherSaltValue0123';
          return _response([
            {'name': '360'},
            {'name': 'preview'},
          ]);
        }
        return _response([
          {'name': 'Source'},
          {'name': '360'},
        ]);
      });
      expect(sentHeaders, hasLength(2));
      expect(sentHeaders[1]['X-Version'], isNot(sentHeaders[0]['X-Version']));
      expect((res.data as List).first['name'], 'Source');
    });
  });
}

Response<dynamic> _response(List<Map<String, dynamic>> data) => Response(
  data: data,
  statusCode: 200,
  requestOptions: RequestOptions(path: '/file'),
);
