import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';

import '../../../../utils/proxy/proxy_util.dart';
import '../../../routes/app_routes.dart';
import 'app_settings_page.dart';
import 'player_settings_page.dart';
import 'proxy_settings_page.dart';
import 'theme_settings_page.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'about_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Worker? _selectedIndexWorker;

  @override
  void dispose() {
    _selectedIndexWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    // 获取屏幕宽度
    final double screenWidth = MediaQuery.of(context).size.width;
    // 定义宽屏的阈值
    const double wideScreenThreshold = 800;
    // 是否是宽屏
    final bool isWideScreen = screenWidth >= wideScreenThreshold;

    // 定义设置项列表
    final List<SettingItem> settingItems = [
      if (ProxyUtil.isSupportedPlatform())
        SettingItem(
          title: t.settings.networkSettings,
          subtitle: t.settings.configureYourProxyServer,
          icon: Icons.wifi,
          page: ProxySettingsPage(isWideScreen: isWideScreen),
          route: Routes.PROXY_SETTINGS_PAGE,
        ),
      SettingItem(
        title: t.settings.appSettings,
        subtitle: t.settings.configureYourAppSettings,
        icon: Icons.settings,
        page: AppSettingsPage(isWideScreen: isWideScreen),
        route: Routes.APP_SETTINGS_PAGE,
      ),
      SettingItem(
        title: t.settings.playerSettings,
        subtitle: t.settings.customizeYourPlaybackExperience,
        icon: Icons.play_circle_outline,
        page: PlayerSettingsPage(isWideScreen: isWideScreen),
        route: Routes.PLAYER_SETTINGS_PAGE,
      ),
      SettingItem(
        title: t.settings.themeSettings,
        subtitle: t.settings.chooseYourFavoriteAppAppearance,
        icon: Icons.color_lens,
        page: ThemeSettingsPage(isWideScreen: isWideScreen),
        route: Routes.THEME_SETTINGS_PAGE,
      ),
      SettingItem(
        title: t.settings.about,
        subtitle: t.settings.checkForUpdates,
        icon: Icons.info_outline,
        page: AboutPage(isWideScreen: isWideScreen),
        route: Routes.ABOUT_PAGE,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings.settings, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 2,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: Get.isDarkMode ? Colors.white : null),
      ),
      body: isWideScreen
          ? _buildWideScreenLayout(context, settingItems)
          : _buildNarrowScreenLayout(context, settingItems),
    );
  }

  Widget _buildWideScreenLayout(
      BuildContext context, List<SettingItem> settingItems) {
    // 使用 GetX 管理当前选中的设置项，并从 ConfigService 中获取保存的值
    final selectedIndex = (Get.find<ConfigService>()
            [ConfigService.SETTINGS_SELECTED_INDEX_KEY] as int? ?? 0)
        .obs;

    // 监听选中索引的变化并保存到 ConfigService
    _selectedIndexWorker?.dispose(); // 确保之前的监听器被清理
    _selectedIndexWorker = ever(selectedIndex, (int index) {
      Get.find<ConfigService>()
          .setSetting(ConfigService.SETTINGS_SELECTED_INDEX_KEY, index);
    });

    return Row(
      children: [
        // 左侧菜单
        SizedBox(
          width: 300,
          child: Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            // color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: settingItems.length,
              itemBuilder: (context, index) {
                final item = settingItems[index];
                return Obx(() => _buildSettingsListTile(
                      context,
                      item,
                      isSelected: selectedIndex.value == index,
                      onTap: () => selectedIndex.value = index,
                    ));
              },
            ),
          ),
        ),
        // 右侧内容区域
        Expanded(
          child: Card(
            margin: const EdgeInsets.fromLTRB(0, 16, 16, 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Obx(() => settingItems[selectedIndex.value].page),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowScreenLayout(
      BuildContext context, List<SettingItem> settingItems) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: settingItems.length,
      itemBuilder: (context, index) {
        final item = settingItems[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildSettingsCard(context, item),
        );
      },
    );
  }

  Widget _buildSettingsListTile(
    BuildContext context,
    SettingItem item, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      selected: isSelected,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          item.icon,
          color: isSelected ? Colors.white : Get.isDarkMode ? Colors.white : null,
        ),
      ),
      title: Text(
        item.title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(item.subtitle),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, SettingItem item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.toNamed(item.route),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: Get.isDarkMode ? Colors.white : null),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// 设置项数据模型
class SettingItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;
  final String route;

  SettingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.page,
    required this.route,
  });
}
