import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Translations;
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/popular_media_list/widgets/common_media_list_widgets.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/pages/settings/settings_navigation.dart';
import 'package:i_iwara/app/ui/pages/settings/settings_section.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/ui/widgets/my_loading_more_indicator_widget.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/common/constants.dart';
import 'package:loading_more_list/loading_more_list.dart';

class DisplaySettingsPage extends StatelessWidget {
  const DisplaySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final configService = Get.find<ConfigService>();
    final bottomInset = computeBottomSafeInset(MediaQuery.of(context));

    return GlassSettingsScaffold(
      title: slang.t.displaySettings.title,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildNavigationOrderCard(context),
              _buildLayoutSettingsCard(context),
              _buildPaginationModeCard(context, configService),
            ]),
          ),
        ),
      ],
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
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        children: [
          // 模拟列表项
          ...List.generate(
            3,
            (index) => _buildDemoListItem(context, index + 1),
          ),
          // 与 MediaListView 同一份 PaginationBar，而不是手绘假分页按钮——
          // 这样这里的样式才会随分页栏的真实改版一起变，不会看起来是另一套东西。
          PaginationBar(
            currentPage: 0,
            totalPages: 3,
            totalItems: 42,
            isLoading: false,
            onPageChanged: (_) {},
            useBlurEffect: true,
            showBottomPadding: false,
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
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
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
          // 与列表页同一份「加载更多」指示器（loading_more_list 包），
          // 而不是手绘的转圈+文字。
          myLoadingMoreIndicator(
            context,
            IndicatorStatus.loadingMoreBusying,
            isSliver: false,
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
                    ).colorScheme.onSurface.withValues(alpha: 0.2),
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
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
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
              SettingsNavigation.openSubPage(SettingsSubRoutes.displayLayout);
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
              SettingsNavigation.openSubPage(SettingsSubRoutes.displayNavigationOrder);
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
