import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Translations;
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/app/utils/show_app_dialog.dart';

class NavigationOrderSettingsPage extends StatefulWidget {
  final bool isWideScreen;

  const NavigationOrderSettingsPage({super.key, this.isWideScreen = false});

  @override
  State<NavigationOrderSettingsPage> createState() =>
      _NavigationOrderSettingsPageState();
}

class _NavigationOrderSettingsPageState
    extends State<NavigationOrderSettingsPage> {
  late ConfigService _configService;
  late List<String> _navigationOrder;
  bool _isDragMode = false;

  // 导航项配置
  final Map<String, NavigationItem> _navigationItems = {
    'video': NavigationItem(
      key: 'video',
      title: slang.t.common.video,
      icon: Icons.video_library,
      description: slang.t.navigationOrderSettings.videoDescription,
    ),
    'gallery': NavigationItem(
      key: 'gallery',
      title: slang.t.common.gallery,
      icon: Icons.photo,
      description: slang.t.navigationOrderSettings.galleryDescription,
    ),
    'subscription': NavigationItem(
      key: 'subscription',
      title: slang.t.common.subscriptions,
      icon: Icons.subscriptions,
      description: slang.t.navigationOrderSettings.subscriptionDescription,
    ),
    'forum': NavigationItem(
      key: 'forum',
      title: slang.t.settings.forum,
      icon: Icons.forum,
      description: slang.t.navigationOrderSettings.forumDescription,
    ),
  };

  @override
  void initState() {
    super.initState();
    _configService = Get.find<ConfigService>();
    _loadSettings();
  }

  void _loadSettings() {
    final orderRaw = _configService[ConfigKey.NAVIGATION_ORDER] as List<dynamic>;
    _navigationOrder = List<String>.from(orderRaw);
  }

  void _saveSettings() {
    _configService.saveSetting(ConfigKey.NAVIGATION_ORDER, _navigationOrder);
    // 触发重建
    setState(() {});
  }

  void _resetToDefaults() {
    setState(() {
      _navigationOrder = List<String>.from(
        ConfigKey.NAVIGATION_ORDER.defaultValue,
      );
    });
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = computeBottomSafeInset(MediaQuery.of(context));
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          BlurredSliverAppBar(
            title: slang.t.navigationOrderSettings.title,
            isWideScreen: widget.isWideScreen,
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + bottomInset,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildDescriptionCard(),
                _buildNavigationOrderCard(),
                _buildPreviewCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.drag_handle,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slang.t.navigationOrderSettings.customNavigationOrder,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    slang.t.navigationOrderSettings.customNavigationOrderDesc,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          slang.t.navigationOrderSettings.restartRequired,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationOrderCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    slang.t.navigationOrderSettings.navigationItemSorting,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      icon: Icon(
                        _isDragMode ? Icons.check : Icons.drag_handle,
                        size: 18,
                      ),
                      label: Text(_isDragMode ? slang.t.navigationOrderSettings.done : slang.t.navigationOrderSettings.edit),
                      onPressed: () {
                        setState(() {
                          _isDragMode = !_isDragMode;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(slang.t.navigationOrderSettings.reset),
                      onPressed: () => _showResetConfirmDialog(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Container(
            constraints: const BoxConstraints(minHeight: 200),
            padding: const EdgeInsets.only(bottom: 8),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _navigationOrder.length,
              buildDefaultDragHandles: false,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = _navigationOrder.removeAt(oldIndex);
                  _navigationOrder.insert(newIndex, item);
                });
                _saveSettings();
              },
              itemBuilder: (context, index) {
                final itemKey = _navigationOrder[index];
                final item = _navigationItems[itemKey]!;

                return Card(
                  key: ValueKey(itemKey),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isDragMode)
                          ReorderableDragStartListener(
                            index: index,
                            child: const MouseRegion(
                              cursor: SystemMouseCursors.grab,
                              child: Icon(Icons.drag_handle, size: 20),
                            ),
                          ),
                        if (_isDragMode) const SizedBox(width: 8),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              item.icon,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      item.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              slang.t.navigationOrderSettings.previewEffect,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slang.t.navigationOrderSettings.bottomNavigationPreview,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _navigationOrder.map((itemKey) {
                      final item = _navigationItems[itemKey]!;
                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.icon,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.title,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  slang.t.navigationOrderSettings.sidebarPreview,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _navigationOrder.asMap().entries.map((entry) {
                      final index = entry.key;
                      final itemKey = entry.value;
                      final item = _navigationItems[itemKey]!;
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          item.icon,
                          size: 20,
                          color: index == 0
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        title: Text(
                          item.title,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: index == 0
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                fontWeight: index == 0
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmDialog() {
    showAppDialog(
      AlertDialog(
        title: Text(slang.t.navigationOrderSettings.confirmResetNavigationOrder),
        content: Text(slang.t.navigationOrderSettings.confirmResetNavigationOrderDesc),
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(slang.t.navigationOrderSettings.cancel),
          ),
          TextButton(
            onPressed: () {
              _resetToDefaults();
              AppService.tryPop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: Text(slang.t.navigationOrderSettings.reset),
          ),
        ],
      ),
    );
  }
}

class NavigationItem {
  final String key;
  final String title;
  final IconData icon;
  final String description;

  NavigationItem({
    required this.key,
    required this.title,
    required this.icon,
    required this.description,
  });
}
