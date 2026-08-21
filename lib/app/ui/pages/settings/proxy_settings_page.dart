import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/proxy_config_widget.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

class ProxySettingsPage extends StatelessWidget {
  final bool isWideScreen;

  const ProxySettingsPage({super.key, this.isWideScreen = false});

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final configService = Get.find<ConfigService>();
    final bottomInset = computeBottomSafeInset(MediaQuery.of(context));

    return GlassSettingsScaffold(
      title: t.settings.networkSettings,
      slivers: [
        // 单层滚动交给骨架的 CustomScrollView：这里不能再套
        // SliverFillRemaining + SingleChildScrollView，那会与骨架让位的
        // spacer 叠出一屏多的高度，且形成双层滚动。
        SliverPadding(
          padding: EdgeInsets.only(bottom: bottomInset),
          sliver: SliverToBoxAdapter(
            child: ProxyConfigWidget(
              configService: configService,
              showTitle: true,
              padding: const EdgeInsets.all(16),
              compactMode: false,
              wrapWithCard: true,
            ),
          ),
        ),
      ],
    );
  }
}
