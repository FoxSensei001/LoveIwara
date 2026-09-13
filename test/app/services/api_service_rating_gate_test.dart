import 'dart:convert';
import 'dart:io';

import 'package:dio/io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:i_iwara/app/services/api_service.dart';
import 'package:i_iwara/app/services/auth_service.dart';
import 'package:i_iwara/app/services/message_service.dart';
import 'package:i_iwara/common/constants.dart';
import 'package:i_iwara/utils/logger_utils.dart';

/// `CommonConstants.enableR18` 是 R18 内容的总闸，语义是"关了就一条 R18 都不许
/// 出现在响应里"，靠拦截器把出站请求的 `rating` 一律改写成 `general` 实现。
///
/// 这段逻辑曾在 84670146 重写拦截器时被整段删掉，开关留在 constants.dart 里但
/// 再没人读它——值改成什么都不会有反应，而且**不报错**。这个文件就是那道闸门：
/// 谁再把 rating 改写从拦截器里搬走，这里会红。
///
/// 覆盖策略是刻意选的"强制覆盖全站"：搜索页筛选里手动选的 `ecchi`、作者页写死
/// 的 `all` 在总闸关闭时都会被压成 `general`。留口子等于没关。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HttpServer server;
  late ApiService apiService;

  setUpAll(() async {
    // flutter_test 的 binding 默认给所有 HttpClient 装了返回 400 的 mock，
    // 这里需要真实 socket 才能读到服务端实际收到的 query。
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
      response.statusCode = 200;
      // 原样回显服务端真正收到的 query，断言不看客户端自己以为发了什么。
      response.write(jsonEncode({'query': request.uri.query}));
      await response.close();
    });

    apiService.dio.options.baseUrl = 'http://127.0.0.1:${server.port}';
    // 绕过 HttpClientFactory（代理/证书配置依赖 ConfigService），直连本地测试服务器。
    apiService.dio.httpClientAdapter = IOHttpClientAdapter();
  });

  tearDown(() async {
    CommonConstants.enableR18 = true;
    await server.close(force: true);
  });

  Future<Map<String, String>> send(Map<String, dynamic> query) async {
    final response = await apiService.get<dynamic>(
      '/image/echo',
      queryParameters: query,
    );
    return Uri.splitQueryString((response.data as Map)['query'] as String);
  }

  test('总闸关闭时，覆盖掉调用方显式传的 rating', () async {
    CommonConstants.enableR18 = false;

    final sent = await send({'rating': 'ecchi', 'foo': 'bar'});

    expect(sent['rating'], 'general', reason: '总闸关闭必须压过筛选里手动选的 ecchi');
    expect(sent['foo'], 'bar', reason: '改写 rating 不能顺手把其余 query 丢掉');
  });

  test('总闸关闭时，作者页写死的 rating=all 同样被覆盖', () async {
    CommonConstants.enableR18 = false;

    final sent = await send({'rating': 'all'});

    expect(sent['rating'], 'general');
  });

  test('总闸关闭时，没带 rating 的请求被补上 general', () async {
    CommonConstants.enableR18 = false;

    final sent = await send({'sort': 'date'});

    expect(sent['rating'], 'general');
  });

  test('总闸开启时，不改写调用方传的 rating', () async {
    CommonConstants.enableR18 = true;

    final sent = await send({'rating': 'ecchi'});

    expect(sent['rating'], 'ecchi', reason: '开启时调用方传什么就是什么');
  });

  test('总闸开启时，不给没带 rating 的请求注入任何东西', () async {
    CommonConstants.enableR18 = true;

    final sent = await send({'sort': 'date'});

    expect(sent.containsKey('rating'), isFalse, reason: '开启时不该注入，也不该删参数');
  });
}
