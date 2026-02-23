import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:oktoast/oktoast.dart';

import '../../../../../utils/logger_utils.dart';
import '../../../../../utils/proxy/proxy_util.dart';
import '../../../../services/config_service.dart';

import 'package:i_iwara/i18n/strings.g.dart' as slang;

abstract class BaseProxyWidget extends StatefulWidget {
  const BaseProxyWidget({super.key});

  @override
  BaseProxyWidgetState<BaseProxyWidget> createState();
}

abstract class BaseProxyWidgetState<T extends BaseProxyWidget> extends State<T> {
  final TextEditingController proxyController = TextEditingController();
  final RxBool isProxyEnabled = false.obs;
  final RxBool isChecking = false.obs;

  // 创建一个全局的 HTTP 客户端
  late Dio dioClient;

  // 定义中文标签
  static const String tag = '代理设置';

  ConfigService get configService;

  @override
  void initState() {
    super.initState();
    dioClient = Dio()..options.persistentConnection = false;

    // 初始化控件的值
    proxyController.text =
        configService[ConfigKey.PROXY_URL]?.toString() ?? '';
    isProxyEnabled.value =
        configService[ConfigKey.USE_PROXY] as bool? ?? false;

    LogUtils.d(
        '初始化完成, 代理地址: ${proxyController.text}, 是否启用代理: $isProxyEnabled',
        tag);
  }

  @override
  void dispose() {
    proxyController.dispose();
    dioClient.close();
    super.dispose();
    LogUtils.d('代理设置组件已销毁', tag);
  }

  // 校验代理地址
  bool isValidProxyAddress(String address) {
    // 允许 IP:端口 或 域名:端口 格式，支持只写 IP:端口，也支持前面带有协议的地址，localhost:7890
    final RegExp regex = RegExp(
        r'^(?:(?:https?|socks[45]):\/\/)?(?:[a-zA-Z0-9-_.]+|\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}):[1-9]\d{0,4}$');
    return regex.hasMatch(address);
  }

  // 检测代理是否正常
  Future<void> checkProxy() async {
    final proxyUrl = configService[ConfigKey.PROXY_URL]?.toString() ?? '';
    LogUtils.i('开始检测代理: $proxyUrl', tag);
    if (proxyUrl.isEmpty) {
      showToastWidget(
          MDToastWidget(
              message: slang.t.settings.proxyAddressCannotBeEmpty,
              type: MDToastType.error),
          position: ToastPosition.top);
      LogUtils.e('检测代理失败: 代理地址为空', tag: tag);
      return;
    }

    if (!isValidProxyAddress(proxyUrl)) {
      LogUtils.e('检测代理格式失败: $proxyUrl', tag: tag);
      showToastWidget(
          MDToastWidget(
              message: slang.t.settings
                  .invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort,
              type: MDToastType.error),
          position: ToastPosition.top);
      return;
    }

    setState(() {
      isChecking.value = true;
    });
    LogUtils.d('开始发送测试请求以检测代理', tag);

    try {
      // 使用 Dio 发送请求到谷歌
      final response = await dioClient.get('https://www.google.com');
      if (response.statusCode == 200 || response.statusCode == 302) {
        showToastWidget(
            MDToastWidget(
                message: slang.t.settings.proxyNormalWork,
                type: MDToastType.success),
            position: ToastPosition.bottom);
        LogUtils.i('代理检测成功，响应状态码: ${response.statusCode}', tag);
      } else {
        showToastWidget(
            MDToastWidget(
                message: slang.t.settings.testProxyFailedWithStatusCode(
                    code: response.statusCode.toString()),
                type: MDToastType.error),
            position: ToastPosition.bottom);
        LogUtils.e('代理检测失败，响应状态码: ${response.statusCode}', tag: tag);
      }
    } catch (e) {
      showToastWidget(
          MDToastWidget(
              message: slang.t.settings
                  .testProxyFailedWithException(exception: e.toString()),
              type: MDToastType.error),
          position: ToastPosition.bottom);
      LogUtils.e('代理请求出错: $e', tag: tag);
    } finally {
      setState(() {
        isChecking.value = false;
      });
      LogUtils.d('代理检测完成', tag);
    }
  }

  // 设置flutter的代理
  void setFlutterEngineProxy(String proxyUrl) {
    if (ProxyUtil.isSupportedPlatform()) {
      // 显示需要重启的提示
      showToastWidget(
        MDToastWidget(
          message: slang.t.settings.needRestartToApply,
          type: MDToastType.info,
        ),
        position: ToastPosition.bottom,
      );
    } else {
      LogUtils.e('当前平台不支持设置代理', tag: tag);
    }
  }

  // 构建代理地址输入组件
  Widget buildProxyAddressInput(BuildContext context) {
    final t = slang.Translations.of(context);

    return Obx(
      () => isChecking.value
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            )
          : ElevatedButton.icon(
              onPressed: checkProxy,
              icon: const Icon(Icons.search_rounded),
              label: Text(t.settings.checkProxy),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
            ),
    );
  }

  // 构建代理启用开关组件
  Widget buildProxySwitch(BuildContext context) {
    final t = slang.Translations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.vpn_key,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              t.settings.enableProxy,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Obx(() => Switch(
                value: isProxyEnabled.value,
                onChanged: (value) {
                  LogUtils.d(
                      '启用代理: $value, 代理地址: ${configService[ConfigKey.PROXY_URL]}',
                      tag);
                  isProxyEnabled.value = value;
                  configService[ConfigKey.USE_PROXY] = value;
                  if (value) {
                    setFlutterEngineProxy(proxyController.text.trim());
                    LogUtils.i('代理已启用', tag);
                  } else {
                    setFlutterEngineProxy(proxyController.text.trim());
                    LogUtils.i('代理已禁用（重启后生效）', tag);
                  }
                },
                activeThumbColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : null,
              )),
        ],
      ),
    );
  }
}
