import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/proxy_config_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class ProxySettingsPage extends StatelessWidget {
  final bool isWideScreen;

  const ProxySettingsPage({super.key, this.isWideScreen = false});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final configService = Get.find<ConfigService>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          BlurredSliverAppBar(
            title: t.settings.networkSettings,
            isWideScreen: isWideScreen,
          ),
          SliverFillRemaining(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProxyConfigWidget(
                    configService: configService,
                    showTitle: true,
                    padding: const EdgeInsets.all(16),
                    compactMode: false,
                    wrapWithCard: true,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
