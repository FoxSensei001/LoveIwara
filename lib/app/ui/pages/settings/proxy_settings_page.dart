import 'package:flutter/material.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/proxy_setting_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class ProxySettingsPage extends StatelessWidget {
  final bool isWideScreen;

  const ProxySettingsPage({super.key, this.isWideScreen = false});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    return Scaffold(
      appBar: SettingsAppBar(
        title: t.settings.networkSettings,
        isWideScreen: isWideScreen,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProxySettingsWidget(),
          ],
        ),
      ),
    );
  }
}
