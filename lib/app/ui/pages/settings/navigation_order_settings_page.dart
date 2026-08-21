import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Translations;
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/routes/home_shell_navigation.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_floating_tab_bar.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
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
  late Set<String> _hiddenItems;
  bool _isDragMode = false;

  // 预览区域的可交互演示状态：让用户能在预览里点一下，
  // 直观感受选中态的滑动高亮/指示条动画，而不是死图。
  int _previewTabIndex = 0;
  int _previewRailIndex = 0;

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
    // 论坛与新闻已合并为「社区」一栏（页内用 header 下拉切换），
    // 与 AppService.navigationItems 保持同一套键。
    'community': NavigationItem(
      key: 'community',
      title: slang.t.settings.community,
      icon: Icons.forum,
      description: slang.t.navigationOrderSettings.communityDescription,
    ),
  };

  @override
  void initState() {
    super.initState();
    _configService = Get.find<ConfigService>();
    _loadSettings();
  }

  void _loadSettings() {
    final orderRaw = _configService[ConfigKey.NAVIGATION_ORDER];
    final normalizedOrder = _normalizeNavigationOrder(orderRaw);
    _navigationOrder = normalizedOrder;

    final storedOrder = orderRaw is List
        ? orderRaw.whereType<String>().toList()
        : const <String>[];
    if (!listEquals(storedOrder, normalizedOrder)) {
      _configService.saveSetting(ConfigKey.NAVIGATION_ORDER, normalizedOrder);
    }

    _hiddenItems = HomeShellNavigation.normalizeHidden(
      _configService[ConfigKey.NAVIGATION_HIDDEN],
    ).toSet();
  }

  /// Toggle visibility of a hideable navigation item (forum / news).
  /// Applied live via [ConfigService.setSetting] so the rail / bottom nav
  /// update immediately without an app restart.
  void _toggleVisibility(String key) {
    if (!HomeShellNavigation.hideableKeys.contains(key)) return;
    setState(() {
      if (_hiddenItems.contains(key)) {
        _hiddenItems.remove(key);
      } else {
        _hiddenItems.add(key);
      }
    });
    _configService.setSetting(
      ConfigKey.NAVIGATION_HIDDEN,
      _hiddenItems.toList(),
    );
  }

  void _saveSettings() {
    final normalizedOrder = _normalizeNavigationOrder(_navigationOrder);
    _navigationOrder = normalizedOrder;
    _configService.saveSetting(ConfigKey.NAVIGATION_ORDER, normalizedOrder);
    // 触发重建
    setState(() {});
  }

  /// Navigation order with hidden items removed — mirrors what the live nav
  /// UI renders. Used by the preview cards.
  List<String> get _visibleNavigationOrder =>
      _navigationOrder.where((key) => !_hiddenItems.contains(key)).toList();

  /// 复用 [HomeShellNavigation] 的那一份实现，不要就地再写一遍：
  /// 老配置里的 `forum` / `news` 需要被折叠成 `community`（合并迁移），
  /// 本页还会把归一化结果**写回**配置，实现分叉的话会把顺序写坏。
  List<String> _normalizeNavigationOrder(dynamic rawOrder) {
    return HomeShellNavigation.normalizeOrder(rawOrder);
  }

  void _resetToDefaults() {
    setState(() {
      _navigationOrder = List<String>.from(
        ConfigKey.NAVIGATION_ORDER.defaultValue,
      );
      _hiddenItems = <String>{};
    });
    _configService.setSetting(ConfigKey.NAVIGATION_HIDDEN, <String>[]);
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = computeBottomSafeInset(MediaQuery.of(context));
    return GlassSettingsScaffold(
      title: slang.t.navigationOrderSettings.title,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildDescriptionCard(),
              _buildNavigationOrderCard(),
              _buildPreviewCard(),
            ]),
          ),
        ),
      ],
    );
  }

  /// 卡片标题行右侧的动作胶囊：编辑/完成拖拽模式 · 重置。
  ///
  /// 位置维持原样（卡片标题行内，不挪去页面 header），只是把裸的
  /// `OutlinedButton.icon` 换成全站统一的 [GlassButtonGroup] + [GlassIconButton]。
  Widget _buildActionGroup() {
    return GlassButtonGroup(
      children: [
        GlassIconButton(
          icon: Icon(_isDragMode ? Icons.check : Icons.drag_handle),
          tooltip: _isDragMode
              ? slang.t.navigationOrderSettings.done
              : slang.t.navigationOrderSettings.edit,
          onPressed: () => setState(() => _isDragMode = !_isDragMode),
        ),
        GlassIconButton(
          icon: const Icon(Icons.refresh),
          tooltip: slang.t.navigationOrderSettings.reset,
          onPressed: _showResetConfirmDialog,
        ),
      ],
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
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.2),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          slang.t.navigationOrderSettings.hideHint,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.errorContainer.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.2),
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
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
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
                const SizedBox(width: 8),
                _buildActionGroup(),
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
              onReorderItem: (oldIndex, newIndex) {
                setState(() {
                  final item = _navigationOrder.removeAt(oldIndex);
                  _navigationOrder.insert(newIndex, item);
                });
                _saveSettings();
              },
              itemBuilder: (context, index) {
                final itemKey = _navigationOrder[index];
                final item = _navigationItems[itemKey]!;
                final isHideable = HomeShellNavigation.hideableKeys.contains(
                  itemKey,
                );
                final isHidden = _hiddenItems.contains(itemKey);

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
                              color: isHidden
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isHidden
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                    subtitle: Text(
                      item.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isHideable) ...[
                          GlassIconButton(
                            standalone: true,
                            size: 36,
                            icon: Icon(
                              isHidden
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            iconSize: 18,
                            color: isHidden
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : Theme.of(context).colorScheme.primary,
                            tooltip: isHidden
                                ? slang.t.navigationOrderSettings.show
                                : slang.t.navigationOrderSettings.hide,
                            onPressed: () => _toggleVisibility(itemKey),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isHidden
                                ? Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest
                                : Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isHidden
                                ? slang.t.navigationOrderSettings.hidden
                                : '${index + 1}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isHidden
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant
                                      : Theme.of(
                                          context,
                                        ).colorScheme.onSecondaryContainer,
                                ),
                          ),
                        ),
                      ],
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
    // 预览必须跟 HomeShellScaffold 实际渲染的东西一致（浮动玻璃胶囊 + 独立
    // 搜索圆钮 / NavigationRail），而不是自己另画一套方盒子——不然设置页
    // 和真实效果对不上，用户按预览排完序会觉得「跟我看到的不一样」。
    final visibleOrder = _visibleNavigationOrder;
    if (_previewTabIndex >= visibleOrder.length) _previewTabIndex = 0;
    if (_previewRailIndex >= visibleOrder.length) _previewRailIndex = 0;

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
                _buildBottomNavPreview(visibleOrder),
                const SizedBox(height: 16),
                Text(
                  slang.t.navigationOrderSettings.sidebarPreview,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                _buildSidebarPreview(visibleOrder),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 移动端浮动底栏预览：真实的 [GlassFloatingTabBar] + 独立搜索圆钮，
  /// 叠在一块模拟内容背景上，才能看出玻璃胶囊的半透明质感。
  Widget _buildBottomNavPreview(List<String> visibleOrder) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 148,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.primaryContainer.withValues(alpha: 0.55),
              cs.tertiaryContainer.withValues(alpha: 0.55),
            ],
          ),
        ),
        child: Stack(
          children: [
            // 模拟内容（卡片网格），仅用于给玻璃胶囊提供反差背景。
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 60),
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(
                  3,
                  (_) => DecoratedBox(
                    decoration: BoxDecoration(
                      color: cs.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 8,
              child: GlassFloatingTabBar(
                currentIndex: _previewTabIndex,
                onTap: (index) => setState(() => _previewTabIndex = index),
                items: visibleOrder.map((key) {
                  final item = _navigationItems[key]!;
                  return GlassTabItem(icon: item.icon, label: item.title);
                }).toList(),
                trailing: GlassIconButton(
                  standalone: true,
                  size: GlassTokens.floatingActionSize,
                  iconSize: 26,
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 宽屏侧栏预览：真实的 [NavigationRail]（与 HomeShellScaffold 同一套
  /// Material 组件），旁边留一小块内容区做参照。
  Widget _buildSidebarPreview(List<String> visibleOrder) {
    final cs = Theme.of(context).colorScheme;
    final destinations = visibleOrder.map((key) {
      final item = _navigationItems[key]!;
      return NavigationRailDestination(
        icon: Icon(item.icon),
        label: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      );
    }).toList();

    // 与 HomeShellScaffold._buildNavigationRail 同一口径的最小高度估算
    // （每项约 72，加上 trailing 区块与呼吸），否则窄容器里 NavigationRail
    // 自身的 intrinsic 高度会超出预览框，画出溢出警示条。
    final double railHeight = destinations.length * 72.0 + 2 * 48.0 + 32.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: railHeight,
        color: cs.surface,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NavigationRail(
              labelType: NavigationRailLabelType.all,
              selectedIndex: _previewRailIndex,
              onDestinationSelected: (index) =>
                  setState(() => _previewRailIndex = index),
              destinations: destinations,
            ),
            VerticalDivider(width: 1, color: Theme.of(context).dividerColor),
            Expanded(
              child: Container(color: cs.surfaceContainerLowest),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmDialog() {
    showAppDialog(
      AlertDialog(
        // 标题行关闭钮走全局约定的玻璃圆钮
        title: Row(
          children: [
            Expanded(
              child: Text(
                slang.t.navigationOrderSettings.confirmResetNavigationOrder,
              ),
            ),
            GlassIconButton(
              standalone: true,
              icon: const Icon(Icons.close),
              tooltip: slang.t.common.close,
              onPressed: () => AppService.tryPop(),
            ),
          ],
        ),
        content: Text(
          slang.t.navigationOrderSettings.confirmResetNavigationOrderDesc,
        ),
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
