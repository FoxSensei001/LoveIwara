import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:i_iwara/app/models/iwara_site.dart';
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/app/services/auth_service.dart';
import 'package:i_iwara/app/services/message_service.dart';
import 'package:i_iwara/app/utils/iwara_different_site_recovery.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// iwara 用「3xx + JSON body、且不带 Location」表达跨站业务错误：
///
///   `GET /image/<ai-site-id>` (x-site: www.iwara.tv)
///   -> 301 {"message":"errors.differentSite","siteId":"iwara_ai"}
///
/// dart:io 的自动重定向遇到这种响应会抛 RedirectException 并丢掉 body，跨站因此
/// 永远无法被识别。ApiService 关闭了自动跟随并自己跟随「真重定向」，这里锁住这个行为。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HttpServer server;
  late ApiService apiService;

  setUpAll(() async {
    // flutter_test 的 binding 默认给所有 HttpClient 装了返回 400 的 mock，
    // 这里需要真实 socket 才能验证重定向行为。
    HttpOverrides.global = null;
    await LogUtils.init(isProduction: true, enablePersistence: false);
    Get.put<MessageService>(MessageService());
    Get.put<AuthService>(AuthService());
    apiService = await ApiService.getInstance();
  });

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      final response = request.response;
      response.headers.contentType = ContentType.json;

      switch (request.uri.path) {
        case '/image/cross-site':
          // 关键用例：3xx + body，无 Location。
          response.statusCode = 301;
          response.write(
            jsonEncode({
              'message': 'errors.differentSite',
              'siteId': 'iwara_ai',
            }),
          );
          break;
        case '/image/moved':
          response.statusCode = 302;
          response.headers.set(HttpHeaders.locationHeader, '/image/ok');
          break;
        case '/image/ok':
          response.statusCode = 200;
          response.write(jsonEncode({'id': 'ok', 'via': request.uri.query}));
          break;
        case '/image/loop':
          response.statusCode = 302;
          response.headers.set(HttpHeaders.locationHeader, '/image/loop');
          break;
        default:
          response.statusCode = 404;
          response.write(jsonEncode({'message': 'errors.notFound'}));
      }
      await response.close();
    });

    apiService.dio.options.baseUrl = 'http://127.0.0.1:${server.port}';
    // 绕过 HttpClientFactory（代理/证书配置依赖 ConfigService），直连本地测试服务器。
    apiService.dio.httpClientAdapter = IOHttpClientAdapter();
  });

  tearDown(() async {
    await server.close(force: true);
  });

  test('keeps the body of a 3xx that carries no Location header', () async {
    Object? captured;
    try {
      await apiService.get<dynamic>('/image/cross-site');
      fail('expected a DioException for the 301 response');
    } on DioException catch (e) {
      captured = e;
    }

    final error = captured as DioException;
    expect(error.response?.statusCode, 301);
    expect(error.response?.data, isA<Map>());
    expect(
      IwaraDifferentSiteRecovery.resolveTargetSite(error),
      IwaraSite.ai,
      reason: '跨站错误必须能被解析出目标站点，否则无法自动切站',
    );
  });

  test('still follows a real redirect that has a Location header', () async {
    final response = await apiService.get<dynamic>(
      '/image/moved',
      queryParameters: {'foo': 'bar'},
    );

    expect(response.statusCode, 200);
    expect((response.data as Map)['id'], 'ok');
    // Location 指向的目标已经是完整地址，原 query 不应被重复拼接上去。
    expect((response.data as Map)['via'], isEmpty);
  });

  test('gives up after too many redirect hops instead of looping', () async {
    try {
      await apiService.get<dynamic>('/image/loop');
      fail('expected a DioException once the redirect budget is exhausted');
    } on DioException catch (e) {
      expect(e.response?.statusCode, 302);
    }
  });
}
