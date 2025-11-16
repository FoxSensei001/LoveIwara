import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/setting_item_widget.dart';

import '../../../../../utils/logger_utils.dart';
import '../../../../services/config_service.dart';

import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'base_proxy_widget.dart';

class ProxySettingsWidget extends BaseProxyWidget {
  const ProxySettingsWidget({super.key});

  @override
  BaseProxyWidgetState<ProxySettingsWidget> createState() => _ProxySettingsWidgetState();
}

class _ProxySettingsWidgetState extends BaseProxyWidgetState<ProxySettingsWidget> {

  @override
  ConfigService get configService => Get.find();

  @override
  Widget build(BuildContext context) {
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
                  buildProxySwitch(context),
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
