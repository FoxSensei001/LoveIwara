import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Translations;
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/pages/settings/layout_settings_page.dart';
import 'package:i_iwara/app/ui/pages/settings/settings_page.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/common/constants.dart';

class DisplaySettingsPage extends StatelessWidget {
  final bool isWideScreen = false;
  final bool useSettingsNavi;

  const DisplaySettingsPage({
    super.key,
    this.useSettingsNavi = false,
  });

  @override
  Widget build(BuildContext context) {
    final configService = Get.find<ConfigService>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          BlurredSliverAppBar(title: slang.t.displaySettings.title, isWideScreen: isWideScreen),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildPaginationModeCard(context, configService),
                _buildLayoutSettingsCard(context),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationModeCard(
    BuildContext context,
    ConfigService configService,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              slang.t.settings.listViewMode,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          Obx(
            () => SwitchListTile(
              title: Text(slang.t.settings.useTraditionalPaginationMode),
              subtitle: Text(slang.t.settings.useTraditionalPaginationModeDesc),
              value: configService[ConfigKey.DEFAULT_PAGINATION_MODE],
              onChanged: (value) {
                configService[ConfigKey.DEFAULT_PAGINATION_MODE] = value;
                CommonConstants.isPaginated = value;
              },
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutSettingsCard(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              slang.t.displaySettings.layoutSettings,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.grid_view),
            title: Text(slang.t.displaySettings.gridLayout),
            subtitle: Text(slang.t.displaySettings.layoutSettingsDesc),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              if (useSettingsNavi) {
                // 宽屏模式：使用设置页面的内部导航
                SettingsPage.navigateToNestedPage(
                  LayoutSettingsPage(isWideScreen: isWideScreen),
                );
              } else {
                // 窄屏模式：使用全局导航
                NaviService.navigateToLayoutSettingsPage();
              }
            },
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
