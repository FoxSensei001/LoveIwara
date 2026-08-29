import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/app/models/iwara_site.dart';
import 'package:i_iwara/app/utils/iwara_different_site_recovery.dart';
import 'package:i_iwara/utils/logger_utils.dart';

DioException _differentSiteError(String siteId, {int statusCode = 403}) {
  final requestOptions = RequestOptions(path: '/video/xh6MMHdobHOEi3');
  return DioException.badResponse(
    statusCode: statusCode,
    requestOptions: requestOptions,
    response: Response<dynamic>(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: {'message': 'errors.differentSite', 'siteId': siteId},
    ),
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await LogUtils.init(isProduction: true, enablePersistence: false);
  });

  group('mayBeWrongSite：值不值得换个站再试一次', () {
    DioException plainError(int statusCode) {
      final requestOptions = RequestOptions(path: '/playlist/abc');
      return DioException.badResponse(
        statusCode: statusCode,
        requestOptions: requestOptions,
        response: Response<dynamic>(
          requestOptions: requestOptions,
          statusCode: statusCode,
          data: {'message': 'errors.notFound'},
        ),
      );
    }

    test('服务端明说跨站 → 算', () {
      expect(
        IwaraDifferentSiteRecovery.mayBeWrongSite(_differentSiteError('iwara')),
        isTrue,
      );
    });

    test('⛔ 干巴巴的 404 也算——属于另一个站的播放列表就只回这个', () {
      expect(
        IwaraDifferentSiteRecovery.mayBeWrongSite(plainError(404)),
        isTrue,
      );
      expect(
        IwaraDifferentSiteRecovery.isDifferentSiteError(plainError(404)),
        isFalse,
        reason: '它只是"嫌疑"，不能拿去下"这就是跨站"的结论',
      );
    });

    test('其它状态码不算：换个站重试解决不了 403 / 500', () {
      expect(
        IwaraDifferentSiteRecovery.mayBeWrongSite(plainError(403)),
        isFalse,
      );
      expect(
        IwaraDifferentSiteRecovery.mayBeWrongSite(plainError(500)),
        isFalse,
      );
      expect(IwaraDifferentSiteRecovery.mayBeWrongSite(null), isFalse);
    });
  });

  group('IwaraSiteUtils.fromSiteId', () {
    test('maps server site ids', () {
      expect(IwaraSiteUtils.fromSiteId('iwara_ai'), IwaraSite.ai);
      expect(IwaraSiteUtils.fromSiteId('iwara'), IwaraSite.main);
      expect(IwaraSiteUtils.fromSiteId(' IWARA_AI '), IwaraSite.ai);
    });

    test('falls back to host parsing when a host is returned', () {
      expect(IwaraSiteUtils.fromSiteId('www.iwara.ai'), IwaraSite.ai);
      expect(IwaraSiteUtils.fromSiteId('www.iwara.tv'), IwaraSite.main);
    });

    test('returns null for unknown or empty ids', () {
      expect(IwaraSiteUtils.fromSiteId(null), isNull);
      expect(IwaraSiteUtils.fromSiteId(''), isNull);
      expect(IwaraSiteUtils.fromSiteId('something-else'), isNull);
    });
  });

  group('IwaraDifferentSiteRecovery.resolveTargetSite', () {
    setUp(IwaraDifferentSiteRecovery.clearAttempts);

    test('resolves the AI site from a main-site request rejection', () {
      expect(
        IwaraDifferentSiteRecovery.resolveTargetSite(
          _differentSiteError('iwara_ai'),
        ),
        IwaraSite.ai,
      );
    });

    test('resolves the main site from an AI-site request rejection', () {
      expect(
        IwaraDifferentSiteRecovery.resolveTargetSite(
          _differentSiteError('iwara'),
        ),
        IwaraSite.main,
      );
    });

    test('works regardless of the status code the server picks', () {
      expect(
        IwaraDifferentSiteRecovery.resolveTargetSite(
          _differentSiteError('iwara_ai', statusCode: 400),
        ),
        IwaraSite.ai,
      );
    });

    test('accepts a raw response body map', () {
      expect(
        IwaraDifferentSiteRecovery.resolveTargetSite({
          'message': 'errors.differentSite',
          'siteId': 'iwara_ai',
        }),
        IwaraSite.ai,
      );
    });

    test('ignores unrelated api errors', () {
      final requestOptions = RequestOptions(path: '/video/xh6MMHdobHOEi3');
      final privateVideo = DioException.badResponse(
        statusCode: 403,
        requestOptions: requestOptions,
        response: Response<dynamic>(
          requestOptions: requestOptions,
          statusCode: 403,
          data: {'message': 'errors.privateVideo'},
        ),
      );

      expect(
        IwaraDifferentSiteRecovery.isDifferentSiteError(privateVideo),
        isFalse,
      );
      expect(IwaraDifferentSiteRecovery.isDifferentSiteError(null), isFalse);
      expect(
        IwaraDifferentSiteRecovery.isDifferentSiteError(Exception('boom')),
        isFalse,
      );
    });

    test('ignores a cross-site error without a usable siteId', () {
      expect(
        IwaraDifferentSiteRecovery.resolveTargetSite(
          _differentSiteError('mystery-site'),
        ),
        isNull,
      );
    });
  });

  group('IwaraDifferentSiteRecovery.recover', () {
    setUp(IwaraDifferentSiteRecovery.clearAttempts);

    test('does not claim non cross-site errors', () async {
      final handled = await IwaraDifferentSiteRecovery.recover(
        Exception('boom'),
        resourceKey: 'video:xh6MMHdobHOEi3',
      );
      expect(handled, isFalse);
    });

    test('gives up when AppService is unavailable', () async {
      // No GetX bindings in this test env: recovery must degrade to "not handled"
      // so the caller still shows its own error UI.
      final handled = await IwaraDifferentSiteRecovery.recover(
        _differentSiteError('iwara_ai'),
        resourceKey: 'video:xh6MMHdobHOEi3',
      );
      expect(handled, isFalse);
    });
  });
}
