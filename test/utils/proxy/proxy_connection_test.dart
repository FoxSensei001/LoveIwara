import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i_iwara/utils/proxy/proxy_util.dart';

void main() {
  test('probe routes the request through the chosen proxy', () async {
    final proxy = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final requests = <Uri>[];
    proxy.listen((request) async {
      requests.add(request.uri);
      request.response.write('from proxy');
      await request.response.close();
    });
    final client = ProxyUtil.createTestClient('127.0.0.1:${proxy.port}');
    try {
      final response = await client.get<String>(
        'http://proxy-probe.invalid/resource',
      );
      expect(response.data, 'from proxy');
      expect(requests.single.host, 'proxy-probe.invalid');
    } finally {
      client.close(force: true);
      await proxy.close(force: true);
    }
  });

  test(
    'unreachable proxy cannot pass by falling back to a direct request',
    () async {
      final unused = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final closedPort = unused.port;
      await unused.close();
      final target = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      var directRequests = 0;
      target.listen((request) async {
        directRequests++;
        await request.response.close();
      });
      final client = ProxyUtil.createTestClient('127.0.0.1:$closedPort');
      try {
        await expectLater(
          client.get<dynamic>('http://127.0.0.1:${target.port}/'),
          throwsA(isA<DioException>()),
        );
        expect(directRequests, 0);
      } finally {
        client.close(force: true);
        await target.close(force: true);
      }
    },
  );
}
