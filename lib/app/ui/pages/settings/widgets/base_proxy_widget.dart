import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

import '../../../../../utils/logger_utils.dart';
import '../../../../../utils/proxy/http_proxy_address.dart';
import '../../../../../utils/proxy/proxy_util.dart';
import '../../../../services/config_service.dart';

abstract class BaseProxyWidget extends StatefulWidget {
  const BaseProxyWidget({super.key});

  @override
  BaseProxyWidgetState<BaseProxyWidget> createState();
}

abstract class BaseProxyWidgetState<T extends BaseProxyWidget>
    extends State<T> {
  final RxBool isProxyEnabled = false.obs;
  final RxBool isChecking = false.obs;
  String? proxyCheckMessage;
  bool proxyCheckSucceeded = false;
  Dio? _testClient;

  static const String tag = '代理设置';
  ConfigService get configService;
  String get proxyDraftAddress;

  @override
  void initState() {
    super.initState();
    isProxyEnabled.value = configService[ConfigKey.USE_PROXY] as bool? ?? false;
  }

  @override
  void dispose() {
    _testClient?.close(force: true);
    super.dispose();
  }

  /// Tests the draft through its own client, without changing the running app's
  /// proxy or allowing DIRECT fallback to produce a false positive.
  Future<void> checkProxy() async {
    if (isChecking.value) return;
    final address = normalizeHttpProxyAddress(proxyDraftAddress);
    if (address == null) return;
    final t = slang.Translations.of(context);
    setState(() {
      isChecking.value = true;
      proxyCheckMessage = null;
    });
    try {
      final client = ProxyUtil.createTestClient(address);
      _testClient = client;
      final response = await client.get<dynamic>(
        'https://www.google.com',
        options: Options(followRedirects: false, validateStatus: (_) => true),
      );
      if (!mounted) return;
      setState(() {
        proxyCheckSucceeded =
            response.statusCode == 200 || response.statusCode == 302;
        proxyCheckMessage = proxyCheckSucceeded
            ? t.settings.proxyEditor.testSuccess
            : t.settings.testProxyFailedWithStatusCode(
                code: '${response.statusCode}',
              );
      });
    } catch (error, stackTrace) {
      LogUtils.e('代理连接测试失败', tag: tag, error: error, stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        proxyCheckSucceeded = false;
        proxyCheckMessage = t.settings.proxyEditor.testFailure;
      });
    } finally {
      _testClient?.close(force: true);
      _testClient = null;
      if (mounted) setState(() => isChecking.value = false);
    }
  }
}
