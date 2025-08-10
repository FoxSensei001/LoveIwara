import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/ai_translation_setting_widget.dart';

import '../../../../utils/proxy/proxy_util.dart';
import '../../../routes/app_routes.dart';
import 'app_settings_page.dart';
import 'player_settings_page.dart';
import 'forum_settings_page.dart';
import 'proxy_settings_page.dart';
import 'theme_settings_page.dart';
import 'download_settings_page.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'about_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Worker? _selectedIndexWorker;
  bool? _wasWideScreen;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // 只有当前页面是设置页面时才处理屏幕切换
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != '/settings_page') {
      return;
    }
    
    final screenWidth = MediaQuery.of(context).size.width;
    const double wideScreenThreshold = 800;
    final bool isWideScreen = screenWidth >= wideScreenThreshold;
    
    // 处理从窄屏到宽屏的切换
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_wasWideScreen != null && _wasWideScreen == false && isWideScreen) {
        // 从窄屏切换到宽屏，如果有其他页面在栈上，则回到设置页
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).popUntil((route) => 
            route.settings.name == '/settings_page'
          );
        }
      }
      _wasWideScreen = isWideScreen;
    });
  }

  @override
  void dispose() {
    _selectedIndexWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settings.settings,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 2,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: Get.isDarkMode ? Colors.white : null),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 定义宽屏的阈值
          const double wideScreenThreshold = 800;
          // 是否是宽屏
          final bool isWideScreen = constraints.maxWidth >= wideScreenThreshold;

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
        title: t.translation.translation,
        subtitle: t.translation.configureTranslationStrategy,
        icon: Icons.translate,
        page: AITranslationSettingsPage(isWideScreen: isWideScreen),
        route: Routes.AI_TRANSLATION_SETTINGS_PAGE,
      ),
      SettingItem(
        title: t.settings.appSettings,
        subtitle: t.settings.configureYourAppSettings,
        icon: Icons.settings,
        page: AppSettingsPage(isWideScreen: isWideScreen),
        route: Routes.APP_SETTINGS_PAGE,
      ),
      SettingItem(
        title: t.settings.chatSettings.name,
        subtitle: t.settings.chatSettings.configureYourChatSettings,
        icon: Icons.forum,
        page: ForumSettingsPage(isWideScreen: isWideScreen),
        route: Routes.FORUM_SETTINGS_PAGE,
      ),
      SettingItem(
        title: t.settings.downloadSettings.downloadSettingsTitle,
        subtitle: t.settings.downloadSettings.downloadSettingsSubtitle,
        icon: Icons.download,
        page: DownloadSettingsPage(isWideScreen: isWideScreen),
        route: Routes.DOWNLOAD_SETTINGS_PAGE,
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

          return isWideScreen
              ? _buildWideScreenLayout(context, settingItems)
              : _buildNarrowScreenLayout(context, settingItems);
        },
      ),
    );
  }

  Widget _buildWideScreenLayout(BuildContext context, List<SettingItem> settingItems) {
    final selectedIndex = (Get.find<ConfigService>()[ConfigKey.SETTINGS_SELECTED_INDEX_KEY] as int? ?? 0).obs;
    
    _selectedIndexWorker?.dispose();
    _selectedIndexWorker = ever(selectedIndex, (int index) {
      Get.find<ConfigService>().setSetting(ConfigKey.SETTINGS_SELECTED_INDEX_KEY, index);
    });
  
    // 定义分组设置项
    final groupedItems = [
      _SettingGroup(
        // title: '基础设置',
        title: slang.t.settings.basicSettings,
        items: settingItems.where((item) =>
            item.icon == Icons.wifi ||
            item.icon == Icons.translate ||
            item.icon == Icons.settings ||
            item.icon == Icons.download).toList(),
      ),
      _SettingGroup(
        // title: '个性化',
        title: slang.t.settings.personalizedSettings,
        items: settingItems.where((item) =>
            item.icon == Icons.play_circle_outline ||
            item.icon == Icons.color_lens ||
            item.icon == Icons.forum).toList(),
      ),
      _SettingGroup(
        // title: '其他',
        title: slang.t.settings.otherSettings,
        items: settingItems.where((item) => 
            item.icon == Icons.info_outline).toList(),
      ),
    ];
  
    return Row(
      children: [
        // 左侧菜单
        SizedBox(
          width: 300,
          child: Card(
            margin: const EdgeInsets.all(16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: groupedItems.length,
              itemBuilder: (context, groupIndex) {
                final group = groupedItems[groupIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                      child: Text(
                        group.title,
                      ),
                    ),
                    ...List.generate(group.items.length, (itemIndex) {
                      final item = group.items[itemIndex];
                      final globalIndex = groupedItems
                          .take(groupIndex)
                          .fold<int>(0, (sum, group) => sum + group.items.length) + itemIndex;
                      
                      return Obx(() => Column(
                        children: [
                          _buildSettingsListTile(
                            context,
                            item,
                            isSelected: selectedIndex.value == globalIndex,
                            onTap: () => selectedIndex.value = globalIndex,
                          ),
                          if (itemIndex != group.items.length - 1)
                            Padding(
                              padding: const EdgeInsets.only(left: 56),
                              child: Divider(
                                height: 1,
                                color: Theme.of(context).dividerColor.withOpacity(0.1),
                              ),
                            ),
                        ],
                      ));
                    }),
                    if (groupIndex != groupedItems.length - 1)
                      const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ),
        // 右侧内容区域
        Expanded(
          child: Card(
            margin: const EdgeInsets.fromLTRB(0, 16, 16, 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Obx(() {
              // 根据选中的索引找到对应的设置项
              SettingItem? selectedItem;
              int currentIndex = 0;
              
              for (final group in groupedItems) {
                for (final item in group.items) {
                  if (currentIndex == selectedIndex.value) {
                    selectedItem = item;
                    break;
                  }
                  currentIndex++;
                }
                if (selectedItem != null) break;
              }
              
              return selectedItem?.page ?? settingItems[0].page;
            }),
          ),
        ),
      ],
    );
  }
  
  Widget _buildNarrowScreenLayout(
      BuildContext context, List<SettingItem> settingItems) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: SizedBox(height: 8),
        ),
        _buildSettingsGroup(
          context,
          // title: '基础设置',
          title: slang.t.settings.basicSettings,
          items: settingItems.where((item) =>
              item.icon == Icons.wifi ||
              item.icon == Icons.translate ||
              item.icon == Icons.settings ||
              item.icon == Icons.download).toList(),
        ),
        _buildSettingsGroup(
          context,
          // title: '个性化',
          title: slang.t.settings.personalizedSettings,
          items: settingItems.where((item) =>
              item.icon == Icons.play_circle_outline ||
              item.icon == Icons.color_lens ||
              item.icon == Icons.forum).toList(),
        ),
        _buildSettingsGroup(
          context,
          // title: '其他',
          title: slang.t.settings.otherSettings,
          items: settingItems.where((item) => 
              item.icon == Icons.info_outline).toList(),
          isLastGroup: true,
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(
    BuildContext context, {
    required String title,
    required List<SettingItem> items,
    bool isLastGroup = false,
  }) {
    return SliverPadding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: isLastGroup ? 8 : 16,
      ),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                title,
                // style: Theme.of(context).textTheme.titleMedium?.copyWith(
                //       fontWeight: FontWeight.bold,
                //       color: Theme.of(context).primaryColor,
                //     ),
              ),
            ),
            Card(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  return Column(
                    children: [
                      _buildSettingsCard(context, item),
                      if (index != items.length - 1)
                        Padding(
                          padding: const EdgeInsets.only(left: 56),
                          child: Divider(
                            height: 1,
                            color: Theme.of(context).dividerColor.withOpacity(0.1),
                          ),
                        ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsListTile(
    BuildContext context,
    SettingItem item, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  size: 20,
                  color: isSelected 
                      ? Colors.white 
                      : (Get.isDarkMode ? Colors.white : Theme.of(context).primaryColor),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, SettingItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.toNamed(item.route),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  size: 20,
                  color: Get.isDarkMode ? Colors.white : Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
              ),
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

// 新增分组数据模型
class _SettingGroup {
  final String title;
  final List<SettingItem> items;

  _SettingGroup({
    required this.title,
    required this.items,
  });
}
