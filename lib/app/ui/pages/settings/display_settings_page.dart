import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Translations;
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/pages/settings/layout_settings_page.dart';
import 'package:i_iwara/app/ui/pages/settings/navigation_order_settings_page.dart';
import 'package:i_iwara/app/ui/pages/settings/settings_page.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/common/constants.dart';

class DisplaySettingsPage extends StatelessWidget {
  final bool isWideScreen = false;
  final bool useSettingsNavi;

  const DisplaySettingsPage({super.key, this.useSettingsNavi = false});

  @override
  Widget build(BuildContext context) {
    final configService = Get.find<ConfigService>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          BlurredSliverAppBar(
            title: slang.t.displaySettings.title,
            isWideScreen: isWideScreen,
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildNavigationOrderCard(context),
                _buildLayoutSettingsCard(context),
                _buildPaginationModeCard(context, configService),
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
            () => Column(
              children: [
                SwitchListTile(
                  title: Text(slang.t.settings.useTraditionalPaginationMode),
                  subtitle: Text(
                    slang.t.settings.useTraditionalPaginationModeDesc,
                  ),
                  value: configService[ConfigKey.DEFAULT_PAGINATION_MODE],
                  onChanged: (value) {
                    configService[ConfigKey.DEFAULT_PAGINATION_MODE] = value;
                    CommonConstants.isPaginated = value;
                  },
                ),
                const Divider(height: 1),
                _buildPaginationModeDemo(
                  context,
                  configService[ConfigKey.DEFAULT_PAGINATION_MODE],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationModeDemo(BuildContext context, bool isPaginated) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                slang.t.settings.previewEffect,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: isPaginated
                ? _buildTraditionalPaginationDemo(context)
                : _buildInfiniteScrollDemo(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTraditionalPaginationDemo(BuildContext context) {
    return Container(
      key: const ValueKey('traditional'),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // 模拟列表项
          ...List.generate(
            3,
            (index) => _buildDemoListItem(context, index + 1),
          ),
          const SizedBox(height: 8),
          // 分页按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDemoPageButton(context, Icons.chevron_left, false),
              const SizedBox(width: 8),
              _buildDemoPageIndicator(context, '1'),
              const SizedBox(width: 4),
              _buildDemoPageIndicator(context, '2'),
              const SizedBox(width: 4),
              _buildDemoPageIndicator(context, '3'),
              const SizedBox(width: 8),
              _buildDemoPageButton(context, Icons.chevron_right, true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfiniteScrollDemo(BuildContext context) {
    return Container(
      key: const ValueKey('infinite'),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // 模拟列表项
          ...List.generate(
            3,
            (index) => _buildDemoListItem(context, index + 1),
          ),
          const SizedBox(height: 8),
          // 加载更多指示器
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                slang.t.common.loadingMore,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDemoListItem(BuildContext context, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Icon(
                Icons.image_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 6,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoPageButton(
    BuildContext context,
    IconData icon,
    bool enabled,
  ) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: enabled
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        icon,
        size: 16,
        color: enabled
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
      ),
    );
  }

  Widget _buildDemoPageIndicator(BuildContext context, String page) {
    final isActive = page == '1';
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          page,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isActive
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
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

  Widget _buildNavigationOrderCard(BuildContext context) {
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
              slang.t.displaySettings.navigationOrderSettings,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.drag_handle),
            title: Text(slang.t.displaySettings.customNavigationOrder),
            subtitle: Text(slang.t.displaySettings.customNavigationOrderDesc),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              if (useSettingsNavi) {
                // 宽屏模式：使用设置页面的内部导航
                SettingsPage.navigateToNestedPage(
                  NavigationOrderSettingsPage(isWideScreen: isWideScreen),
                );
              } else {
                // 窄屏模式：使用全局导航
                NaviService.navigateToNavigationOrderSettingsPage();
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
