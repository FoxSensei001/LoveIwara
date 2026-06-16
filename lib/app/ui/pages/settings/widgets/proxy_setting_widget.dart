import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/setting_item_widget.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';

import '../../../../../utils/logger_utils.dart';
import '../../../../services/config_service.dart';

import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'base_proxy_widget.dart';

class ProxySettingsWidget extends BaseProxyWidget {
  /// 是否以「嵌入」模式展示（例如播放器设置弹窗内）：
  /// 去掉自身的滚动与外层 16px 内边距，并让卡片与同弹窗内其它分组卡片对齐。
  final bool embedded;

  const ProxySettingsWidget({super.key, this.embedded = false});

  @override
  BaseProxyWidgetState<ProxySettingsWidget> createState() =>
      _ProxySettingsWidgetState();
}

class _ProxySettingsWidgetState
    extends BaseProxyWidgetState<ProxySettingsWidget> {
  @override
  ConfigService get configService => Get.find();

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final bool embedded = widget.embedded;

    final Widget card = Card(
      elevation: embedded ? 1 : 2,
      margin: embedded ? EdgeInsets.zero : null,
      clipBehavior: embedded ? Clip.antiAlias : Clip.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(embedded ? 16 : 12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.settings.proxyConfig,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : null,
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
              labelSuffix: buildProxyAddressInput(context),
              initialValue: proxyController.text,
              validator: (value) {
                if (value.isEmpty) {
                  return t.settings.proxyAddressCannotBeEmpty;
                }
                if (!isValidProxyAddress(value)) {
                  return t.settings
                      .invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort;
                }
                return null;
              },
              onValid: (value) {
                configService[ConfigKey.PROXY_URL] = value;
                LogUtils.d('保存代理地址: $value', BaseProxyWidgetState.tag);
                if (isProxyEnabled.value) {
                  setFlutterEngineProxy(value.trim());
                }
              },
              icon: Icon(
                Icons.computer,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : null,
              ),
              splitTwoLine: true,
              inputDecoration: InputDecoration(
                hintText: t
                    .settings
                    .pleaseEnterTheUrlOfTheProxyServerForExample1270018080,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            buildProxySwitch(context),
          ],
        ),
      ),
    );

    // 嵌入模式：直接返回卡片，由外层容器统一负责内边距与滚动。
    if (embedded) {
      return card;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          card,
          SizedBox(height: computeBottomSafeInset(MediaQuery.of(context))),
        ],
      ),
    );
  }
}
