import 'package:flutter/material.dart';
import 'package:i_iwara/app/routes/app_router.dart';
import 'package:i_iwara/app/ui/pages/settings/settings_navigation.dart';
import 'package:i_iwara/app/ui/pages/settings/settings_section.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 设置树的两栏骨架，作为 `/settings/**` 那层 `ShellRoute` 的 builder。
///
/// - 宽屏：左栏是常驻的分区列表（**不是路由**，所以切分区时它不参与转场），
///   右栏是 [child]——即设置自己那个嵌套 Navigator。
/// - 窄屏：直接就是 [child]，一级列表由 `/settings` 这条路由自己渲染。
///
/// 左栏高亮完全从 [location] 推导，没有第二份 `currentPage` 状态。
class SettingsShell extends StatefulWidget {
  const SettingsShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  @override
  State<SettingsShell> createState() => _SettingsShellState();
}

class _SettingsShellState extends State<SettingsShell> {
  /// 宽屏「自动选中第一个分区」的幂等闸门。
  /// 离开 `/settings` 根就重新上膛，所以窄屏拖宽时能补触发一次。
  bool _autoSelectScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery 尺寸变化（桌面拖窗 / 旋转 / 分屏）也会走到这里。
    _maybeAutoSelectFirstSection();
  }

  @override
  void didUpdateWidget(covariant SettingsShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location) {
      _maybeAutoSelectFirstSection();
    }
  }

  /// 宽屏停在 `/settings` 时右栏会是空白，这里把它顶替成第一个可用分区。
  ///
  /// 用 `replace` 而非 `pushReplacement`：`replace` 复用 pageKey、不跑转场，
  /// 而此刻整个设置壳本来就在做入场动画，右栏再叠一段推入会显得杂乱。
  /// 顺带的好处是栈里不留 `/settings` 那一页——于是宽屏下从分区返回就直接
  /// 离开设置，不会先落到一个空白右栏。
  void _maybeAutoSelectFirstSection() {
    if (widget.location != kSettingsRootPath) {
      _autoSelectScheduled = false;
      return;
    }
    if (_autoSelectScheduled) return;
    if (!SettingsNavigation.isTwoPane(context)) return;

    _autoSelectScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (SettingsNavigation.currentLocation != kSettingsRootPath) return;
      if (!SettingsNavigation.isTwoPane(context)) return;
      appRouter.replace(SettingsSection.firstAvailable.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!SettingsNavigation.isTwoPane(context)) {
      return widget.child;
    }

    final t = slang.Translations.of(context);
    return Material(
      child: Row(
        children: [
          SizedBox(
            width: 280,
            height: double.infinity,
            child: GlassSettingsScaffold(
              // 返回不给自定义实现：走和系统返回键 / Esc 完全相同的那条链
              // （[AppService.tryPop] → PopCoordinator），按栈深退一层——在分区
              // 根就离开整个设置。
              //
              // 别改回「一次性弹掉整棵设置树」：go_router 的
              // `RouteMatchList.remove(shellMatch)` 在嵌套 Shell 还有多层匹配时
              // 找不到要移除的东西、直接 `return this`，pop 被静默吞掉——表现就是
              // 三级页里点左栏返回钮**毫无反应**。而分多次 pop 也不行：同一帧内
              // 连续 pop 会打到同一个尚未重建的 route，抛
              // `Bad state: Future already completed`。
              title: t.settings.settings,
              slivers: [
                SettingsSectionSliver(location: widget.location),
              ],
            ),
          ),
          Container(
            height: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 0.6,
                ),
              ),
            ),
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

/// `/settings` 这条路由的页面。
///
/// 窄屏是整页的一级列表；宽屏下列表已经常驻在左栏，这里只做一个瞬时占位
/// ——[_SettingsShellState._maybeAutoSelectFirstSection] 会立刻把它顶替掉。
class SettingsListPage extends StatelessWidget {
  const SettingsListPage({super.key, required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    if (SettingsNavigation.isTwoPane(context)) {
      return const SizedBox.shrink();
    }

    final t = slang.Translations.of(context);
    return GlassSettingsScaffold(
      title: t.settings.settings,
      slivers: [SettingsSectionSliver(location: location)],
    );
  }
}

/// 一级分区列表（宽屏左栏与窄屏整页共用）。
class SettingsSectionSliver extends StatelessWidget {
  const SettingsSectionSliver({super.key, required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final selected = SettingsSection.fromLocation(location);
    final groups = settingsSectionGroups
        .map(
          (group) => (
            title: group.title(t),
            sections: group.sections.where((s) => s.isAvailable).toList(),
          ),
        )
        .where((group) => group.sections.isNotEmpty)
        .toList();

    final bottomInset = computeBottomSafeInset(MediaQuery.of(context));
    return SliverPadding(
      padding: EdgeInsets.only(top: 8, bottom: 8 + bottomInset),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, groupIndex) {
          final group = groups[groupIndex];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Card(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      group.title,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  ...List.generate(group.sections.length, (itemIndex) {
                    final section = group.sections[itemIndex];
                    return Column(
                      children: [
                        _SectionTile(
                          section: section,
                          title: section.title(t),
                          isSelected: selected == section,
                        ),
                        if (itemIndex != group.sections.length - 1)
                          Padding(
                            padding: const EdgeInsets.only(left: 48),
                            child: Divider(
                              height: 1,
                              color: Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.1),
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          );
        }, childCount: groups.length),
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.section,
    required this.title,
    required this.isSelected,
  });

  final SettingsSection section;
  final String title;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: isSelected
          ? colorScheme.secondaryContainer.withValues(alpha: 0.3)
          : Colors.transparent,
      child: InkWell(
        onTap: () => SettingsNavigation.openSection(context, section),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                section.icon,
                size: 20,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.normal,
                    color: isSelected ? colorScheme.primary : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
