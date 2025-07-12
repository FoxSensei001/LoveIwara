import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:i_iwara/app/ui/pages/settings/widgets/setting_item_widget.dart';
import 'package:i_iwara/app/ui/widgets/MDToastWidget.dart';
import 'package:oktoast/oktoast.dart';

import '../../../../../utils/logger_utils.dart';
import '../../../../../utils/proxy/proxy_util.dart';
import '../../../../services/config_service.dart';

import 'package:i_iwara/i18n/strings.g.dart' as slang;

class MyHttpOverrides extends HttpOverrides {
  final String url;

  MyHttpOverrides(this.url);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..findProxy = (uri) {
        return 'PROXY $url';
      }
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
  }
}

class ProxySettingsWidget extends StatefulWidget {
  final ConfigService configService = Get.find();

  ProxySettingsWidget({super.key});

  @override
  _ProxySettingsWidgetState createState() => _ProxySettingsWidgetState();
}

class _ProxySettingsWidgetState extends State<ProxySettingsWidget> {
  final TextEditingController _proxyController = TextEditingController();
  final RxBool _isProxyEnabled = false.obs;
  final RxBool _isChecking = false.obs;

  // 创建一个全局的 HTTP 客户端
  late http.Client _httpClient;

  // 定义中文标签
  static const String _tag = '代理设置';

  @override
  void initState() {
    super.initState();
    _httpClient = http.Client();
    
    // 初始化控件的值
    _proxyController.text =
        widget.configService[ConfigKey.PROXY_URL]?.toString() ?? '';
    _isProxyEnabled.value =
        widget.configService[ConfigKey.USE_PROXY] as bool? ?? false;

    LogUtils.d(
        '初始化完成, 代理地址: ${_proxyController.text}, 是否启用代理: $_isProxyEnabled',
        _tag);
  }

  @override
  void dispose() {
    _proxyController.dispose();
    _httpClient.close();
    super.dispose();
    LogUtils.d('代理设置组件已销毁', _tag);
  }

  // 校验代理地址
  bool _isValidProxyAddress(String address) {
    // 允许 IP:端口 或 域名:端口 格式，支持只写 IP:端口，也支持前面带有协议的地址，localhost:7890
    final RegExp regex = RegExp(
        r'^(?:(?:https?|socks[45]):\/\/)?(?:[a-zA-Z0-9-_.]+|\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}):[1-9]\d{0,4}$');
    return regex.hasMatch(address);
  }

  // 检测代理是否正常
  Future<void> _checkProxy() async {
    final proxyUrl =
        widget.configService[ConfigKey.PROXY_URL]?.toString() ?? '';
    LogUtils.i('开始检测代理: $proxyUrl', _tag);
    if (proxyUrl.isEmpty) {
      showToastWidget(
          MDToastWidget(
              message: slang.t.settings.proxyAddressCannotBeEmpty,
              type: MDToastType.error),
          position: ToastPosition.top);
      LogUtils.e('检测代理失败: 代理地址为空', tag: _tag);
      return;
    }

    if (!_isValidProxyAddress(proxyUrl)) {
      LogUtils.e('检测代理格式失败: $proxyUrl', tag: _tag);
      showToastWidget(
          MDToastWidget(
              message: slang.t.settings
                  .invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort,
              type: MDToastType.error),
          position: ToastPosition.top);
      return;
    }

    setState(() {
      _isChecking.value = true;
    });
    LogUtils.d('开始发送测试请求以检测代理', _tag);

    try {
      // 使用 HTTP 包发送请求到谷歌
      final response = await _httpClient.get(Uri.parse('https://www.google.com'));
      if (response.statusCode == 200 || response.statusCode == 302) {
        showToastWidget(
            MDToastWidget(
                message: slang.t.settings.proxyNormalWork,
                type: MDToastType.success),
            position: ToastPosition.bottom);
        LogUtils.i('代理检测成功，响应状态码: ${response.statusCode}', _tag);
      } else {
        showToastWidget(
            MDToastWidget(
                message: slang.t.settings.testProxyFailedWithStatusCode(
                    code: response.statusCode.toString()),
                type: MDToastType.error),
            position: ToastPosition.bottom);
        LogUtils.e('代理检测失败，响应状态码: ${response.statusCode}', tag: _tag);
      }
    } catch (e) {
      showToastWidget(
          MDToastWidget(
              message: slang.t.settings
                  .testProxyFailedWithException(exception: e.toString()),
              type: MDToastType.error),
          position: ToastPosition.bottom);
      LogUtils.e('代理请求出错: $e', tag: _tag);
    } finally {
      setState(() {
        _isChecking.value = false;
      });
      LogUtils.d('代理检测完成', _tag);
    }
  }

  // 设置flutter的代理
  void _setFlutterEngineProxy(String proxyUrl) {
    if (ProxyUtil.isSupportedPlatform()) {
      LogUtils.i('设置 Flutter 代理: $proxyUrl', _tag);
      if (proxyUrl.isEmpty) {
        HttpOverrides.global = null;
        LogUtils.d('已清除 Flutter 全局代理', _tag);
      } else {
        HttpOverrides.global = MyHttpOverrides(proxyUrl);
        LogUtils.d('已设置 Flutter 全局代理为: $proxyUrl', _tag);
      }
      // 显示需要重启的提示
      showToastWidget(
        MDToastWidget(
          message: slang.t.settings.needRestartToApply,
          type: MDToastType.info,
        ),
        position: ToastPosition.bottom,
      );
      LogUtils.i('代理设置已更改，需要重启应用生效', _tag);
    } else {
      LogUtils.e('当前平台不支持设置代理', tag: _tag);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕宽度
    final double screenWidth = MediaQuery.of(context).size.width;
    // 定义内容的最大宽度
    final t = slang.Translations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.settings.proxyConfig,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Get.isDarkMode ? Colors.white : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                t.settings.thisIsHttpProxyAddress,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SettingItem(
                      label: t.settings.proxyAddress,
                      labelSuffix: Obx(
                        () => _isChecking.value
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
                                onPressed: _checkProxy,
                                icon: const Icon(Icons.search_rounded),
                                label: Text(t.settings.checkProxy),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                              ),
                      ),
                      initialValue: _proxyController.text,
                      validator: (value) {
                        if (value.isEmpty) {
                          return t.settings.proxyAddressCannotBeEmpty;
                        }
                        if (!_isValidProxyAddress(value)) {
                          return t.settings
                              .invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort;
                        }
                        return null;
                      },
                      onValid: (value) {
                        widget.configService[ConfigKey.PROXY_URL] = value;
                        LogUtils.d('保存代理地址: $value', _tag);
                        if (_isProxyEnabled.value) {
                          _setFlutterEngineProxy(value.trim());
                        }
                      },
                      icon: Icon(Icons.computer,
                          color: Get.isDarkMode ? Colors.white : null),
                      splitTwoLine: true,
                      inputDecoration: InputDecoration(
                        hintText: t.settings
                            .pleaseEnterTheUrlOfTheProxyServerForExample1270018080,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.vpn_key,
                            color: Get.isDarkMode ? Colors.white : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              t.settings.enableProxy,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          Obx(() => Switch(
                                value: _isProxyEnabled.value,
                                onChanged: (value) {
                                  LogUtils.d(
                                      '启用代理: $value, 代理地址: ${widget.configService[ConfigKey.PROXY_URL]}',
                                      _tag);
                                  _isProxyEnabled.value = value;
                                  widget.configService[
                                      ConfigKey.USE_PROXY] = value;
                                  if (value) {
                                    _setFlutterEngineProxy(
                                        _proxyController.text.trim());
                                    LogUtils.i('代理已启用', _tag);
                                  } else {
                                    HttpOverrides.global = null;
                                    LogUtils.i('代理已禁用', _tag);
                                  }
                                },
                                activeColor:
                                    Get.isDarkMode ? Colors.white : null,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
                height: Get.context != null
                    ? MediaQuery.of(Get.context!).padding.bottom
                    : 0),
          ],
        ),
    );
  }
}
