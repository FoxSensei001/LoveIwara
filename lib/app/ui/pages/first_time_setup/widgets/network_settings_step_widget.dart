import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/layouts.dart';
import 'package:i_iwara/app/ui/pages/first_time_setup/widgets/shared/step_container.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/proxy_config_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class NetworkSettingsStepWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;

  const NetworkSettingsStepWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });

  @override
  State<NetworkSettingsStepWidget> createState() =>
      _NetworkSettingsStepWidgetState();
}

class _NetworkSettingsStepWidgetState extends State<NetworkSettingsStepWidget> {
  final ConfigService configService = Get.find();

  final Key _proxyConfigKey = const ValueKey<int>(0);

  @override
  Widget build(BuildContext context) {
    return StepPageLayout(
      subtitle: widget.subtitle,
      description: widget.description,
      content: GlassSettingSection(
        children: [
          // 代理表单自己那层 Card（投影 + 12 圆角）在这里会变成「卡里套卡」，
          // 所以关掉外壳，由本页统一的分组卡片承载；设置页仍走 wrapWithCard。
          Padding(
            padding: const EdgeInsets.all(StepMetrics.cardPadding),
            child: ProxyConfigWidget(
              key: _proxyConfigKey,
              configService: configService,
              showTitle: false,
              padding: EdgeInsets.zero,
              compactMode: true,
              wrapWithCard: false,
            ),
          ),
        ],
      ),
      // 「重启后才生效」是后果提醒，不是普通说明：用 warning 语气区分。
      tip: StepTipBanner.warning(slang.t.firstTimeSetup.network.tip),
    );
  }
}
