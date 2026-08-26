import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Translations;
import 'package:i_iwara/app/models/block_rule.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/content_block_service.dart';
import 'package:i_iwara/app/services/conversation_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_composer.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_header_overlay.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_menu.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_morph.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_adaptive_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_segmented_control.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_tokens.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_toast.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';

class BlockSettingsPage extends StatefulWidget {
  final bool isWideScreen;

  const BlockSettingsPage({super.key, this.isWideScreen = false});

  @override
  State<BlockSettingsPage> createState() => _BlockSettingsPageState();
}

class _BlockSettingsPageState extends State<BlockSettingsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  ContentBlockService get _service => Get.find<ContentBlockService>();

  slang.TranslationsSettingsBlockSettingsEn get _t =>
      slang.t.settings.blockSettings;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: BlockRuleType.values.length,
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    // 动画途中 indexIsChanging 为 true，只关心落定后的那次
    if (_tabController.indexIsChanging) return;
    if (mounted) setState(() {});
  }

  /// 返回：统一交给 [AppService.tryPop]，由 PopCoordinator 按栈深决定是退回
  /// 设置列表还是离开整个设置树——和系统返回键、Esc 走的是同一条链。
  void _handleBack() {
    AppService.tryPop();
  }

  void _addRule(BuildContext context, {BlockRule? existing}) {
    // 新增规则时，根据当前所处的 tab 自动选择对应的规则类型。
    BlockRuleType? initialType;
    if (existing == null) {
      final index = _tabController.index;
      if (index >= 0 && index < BlockRuleType.values.length) {
        initialType = BlockRuleType.values[index];
      }
    }
    showAppBottomSheet(
      _RuleEditorSheet(
        existing: existing,
        initialType: initialType,
        onSubmit: (rule) async {
          if (existing == null) {
            await _service.addRule(
              type: rule.type,
              value: rule.value,
              label: rule.label,
              caseSensitive: rule.caseSensitive,
              enabled: rule.enabled,
            );
          } else {
            await _service.updateRule(rule);
          }
          // 提交后自动跳到该规则类型对应的 tab。
          final targetIndex = BlockRuleType.values.indexOf(rule.type);
          if (targetIndex >= 0 && _tabController.index != targetIndex) {
            _tabController.animateTo(targetIndex);
          }
        },
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _export(BuildContext context) async {
    try {
      final ok = await _service.exportRulesToFile();
      if (ok) {
        showGlassToast(_t.exportSuccess, type: GlassToastType.success);
      }
    } catch (e) {
      LogUtils.e('导出屏蔽规则失败', tag: 'BlockSettingsPage', error: e);
      showGlassToast(_t.exportFailed, type: GlassToastType.error);
    }
  }

  Future<void> _import(BuildContext context) async {
    try {
      final added = await _service.importRulesFromFile();
      if (added == null) return; // 用户取消
      showGlassToast(
        _t.importSuccess(count: added.toString()),
        type: GlassToastType.success,
      );
    } catch (e) {
      LogUtils.e('导入屏蔽规则失败', tag: 'BlockSettingsPage', error: e);
      showGlassToast(_t.importFailed, type: GlassToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottomInset = computeBottomSafeInset(mq);
    final double statusBarHeight = mq.padding.top;
    final double headerExtent = statusBarHeight + GlassTokens.headerRowHeight;

    final tabItems = [
      for (final type in BlockRuleType.values)
        GlassSegmentItem(label: _typeLabel(type), icon: Icon(_typeIcon(type))),
    ];

    return Scaffold(
      body: GlassHeaderOverlay(
        headerExtent: headerExtent,
        headerTop: statusBarHeight,
        solidExtent: statusBarHeight,
        liquid: true,
        body: TabBarView(
          controller: _tabController,
          physics: const ClampingScrollPhysics(),
          children: [
            for (final type in BlockRuleType.values)
              _Centered(
                child: _buildTypeList(context, type, headerExtent, bottomInset),
              ),
          ],
        ),
        // header 行：左 返回圆钮（窄屏才有）/ 中 类型分段胶囊 / 右 动作胶囊
        header: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // 宽屏是双栏布局、左栏就是导航，返回钮整体淡出而不是瞬间消失
              GlassShapeSwitcher(
                child: widget.isWideScreen
                    ? const SizedBox.shrink(key: ValueKey('block-back-hidden'))
                    : Padding(
                        key: const ValueKey('block-back'),
                        padding: const EdgeInsets.only(right: 8),
                        child: GlassIconButton(
                          standalone: true,
                          icon: const Icon(Icons.arrow_back),
                          tooltip: slang.t.common.back,
                          onPressed: _handleBack,
                        ),
                      ),
              ),
              Expanded(
                // 空间够就平铺分段胶囊，露不出 2.5 个完整段就退化成下拉钮
                // （全站同一条约定，见 GlassAdaptiveSegmentedControl）。
                child: GlassAdaptiveSegmentedControl(
                  selectedIndex: _tabController.index,
                  progress: _tabController.animation,
                  onChanged: _tabController.animateTo,
                  items: tabItems,
                ),
              ),
              const SizedBox(width: 8),
              _buildActionGroup(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 右侧动作胶囊：新增规则 · 导入/导出二级菜单。
  Widget _buildActionGroup(BuildContext context) {
    return GlassButtonGroup(
      children: [
        GlassIconButton(
          icon: const Icon(Icons.add),
          tooltip: _t.addRule,
          onPressed: () => _addRule(context),
        ),
        // 导入/导出二级菜单：Builder 包一层拿到触发件自身 context 作为
        // showGlassMenu 的锚点；GlassIconButton 非 standalone，因为它就在
        // 这个 GlassButtonGroup 的透明图标位里。
        Builder(
          builder: (anchorContext) => GlassIconButton(
            icon: const Icon(Icons.import_export),
            tooltip: _t.importExport,
            // 这枚键就是菜单的触发钮：长按也能打开，且长按不抬手可以直接划到某一条上
            // 松手选中（见 GlassTapArea.opensOverlay）。
            opensOverlay: true,
            onPressed: () => _openImportExportMenu(anchorContext),
          ),
        ),
      ],
    );
  }

  /// 导入/导出玻璃菜单：对应原来 PopupMenuButton 的两条 item。
  Future<void> _openImportExportMenu(BuildContext anchorContext) async {
    final picked = await showGlassMenu<String>(
      anchorContext: anchorContext,
      entries: [
        GlassMenuOption(
          value: 'import',
          icon: Icons.file_download_outlined,
          label: _t.importRules,
        ),
        GlassMenuOption(
          value: 'export',
          icon: Icons.file_upload_outlined,
          label: _t.exportRules,
        ),
      ],
    );
    if (picked == null) return;
    if (!mounted) return;
    if (picked == 'import') {
      _import(context);
    } else if (picked == 'export') {
      _export(context);
    }
  }

  /// 单个类型的规则列表（每条规则一张卡片）。
  ///
  /// 列表铺满整个区域，用 [headerExtent] 让出玻璃 header 的高度，卡片可以从
  /// header 背后滚过去；顶部一行说明 + 启用数概览，替代原先的概览大卡。
  Widget _buildTypeList(
    BuildContext context,
    BlockRuleType type,
    double headerExtent,
    double bottomInset,
  ) {
    return Obx(() {
      final rules = _service.rules.where((r) => r.type == type).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final enabledCount = rules.where((r) => r.enabled).length;

      return ListView.separated(
        padding: EdgeInsets.fromLTRB(
          16,
          headerExtent + 8,
          16,
          24 + bottomInset,
        ),
        // 首项是说明行，其余是规则卡；空态时只有说明行 + 空占位
        itemCount: (rules.isEmpty ? 1 : rules.length) + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          if (i == 0) {
            return _buildTypeSummary(context, rules.length, enabledCount);
          }
          if (rules.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 32),
              child: _EmptyState(text: _t.noRules),
            );
          }
          final rule = rules[i - 1];
          return _RuleTile(
            rule: rule,
            onToggle: (v) => _service.toggleRule(rule.id, v),
            onEdit: () => _addRule(context, existing: rule),
            onDelete: () => _service.removeRule(rule.id),
          );
        },
      );
    });
  }

  /// 列表顶部说明行：一句用途说明 + 本类型「已启用/总数」。
  Widget _buildTypeSummary(BuildContext context, int total, int enabled) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              _t.subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.3,
              ),
            ),
          ),
          if (total > 0) ...[
            const SizedBox(width: 12),
            _StatChip(icon: Icons.toggle_on, label: '$enabled/$total'),
          ],
        ],
      ),
    );
  }
}

/// 统一的内容宽度约束 + 居中（宽屏限制 720，移动端铺满）。
class _Centered extends StatelessWidget {
  final Widget child;

  const _Centered({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: child,
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// 规则类型选择卡：图标在上、文字在下，纵向堆叠，窄屏不易换行。
class _TypeChoiceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChoiceCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fg = selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;
    return Material(
      color: selected
          ? scheme.primaryContainer
          : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? scheme.primary
                  : theme.dividerColor.withValues(alpha: 0.15),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: fg),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: fg,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _typeLabel(BlockRuleType type) {
  final t = slang.t.settings.blockSettings;
  switch (type) {
    case BlockRuleType.keyword:
      return t.keyword;
    case BlockRuleType.regex:
      return t.regex;
    case BlockRuleType.userId:
      return t.userId;
  }
}

IconData _typeIcon(BlockRuleType type) {
  switch (type) {
    case BlockRuleType.keyword:
      return Icons.text_fields;
    case BlockRuleType.regex:
      return Icons.code;
    case BlockRuleType.userId:
      return Icons.person_off_outlined;
  }
}

class _RuleTile extends StatelessWidget {
  final BlockRule rule;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RuleTile({
    required this.rule,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = slang.t.settings.blockSettings;
    final titleText = rule.type == BlockRuleType.userId
        ? (rule.label?.isNotEmpty == true ? rule.label! : rule.value)
        : rule.value;
    final subtitleParts = <String>[];
    if (rule.type == BlockRuleType.userId) {
      subtitleParts.add(rule.value);
    } else if (rule.caseSensitive) {
      subtitleParts.add(t.caseSensitive);
    }
    final dimmed = !rule.enabled;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.12)),
      ),
      child: Opacity(
        opacity: dimmed ? 0.55 : 1,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 2,
          ),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _typeIcon(rule.type),
              size: 18,
              color: scheme.onSecondaryContainer,
            ),
          ),
          title: Text(
            titleText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: subtitleParts.isEmpty
              ? null
              : Text(
                  subtitleParts.join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(value: rule.enabled, onChanged: onToggle),
              // 菜单走全站统一的玻璃面板（原来是 PopupMenuButton）。
              Builder(
                builder: (anchorContext) => GlassPressable(
                  // 长按也能打开，且长按不抬手可以直接划到某一条上松手选中
                  // （见 GlassTapArea.opensOverlay）。
                  opensOverlay: true,
                  onTap: () async {
                    final action = await showGlassMenu<String>(
                      anchorContext: anchorContext,
                      entries: [
                        GlassMenuOption<String>(
                          value: 'edit',
                          icon: Icons.edit_outlined,
                          label: t.editRule,
                        ),
                        GlassMenuOption<String>(
                          value: 'delete',
                          icon: Icons.delete_outline,
                          label: t.deleteRule,
                          destructive: true,
                        ),
                      ],
                    );
                    if (action == 'edit') {
                      onEdit();
                    } else if (action == 'delete') {
                      onDelete();
                    }
                  },
                  builder: (context, pressed) => const SizedBox.square(
                    dimension: 40,
                    child: Icon(Icons.more_vert),
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

class _EmptyState extends StatelessWidget {
  final String text;

  const _EmptyState({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shield_outlined,
              size: 40,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// 新增 / 编辑规则底部弹窗。提交时通过 [onSubmit] 回传规则（编辑时保留原 id），
/// 并使用 [AppService.tryPop] 关闭弹窗。
class _RuleEditorSheet extends StatefulWidget {
  final BlockRule? existing;
  // 新增规则时的初始规则类型（来自当前 tab）；为空则默认关键词。
  final BlockRuleType? initialType;
  final Future<void> Function(BlockRule rule) onSubmit;

  const _RuleEditorSheet({
    this.existing,
    this.initialType,
    required this.onSubmit,
  });

  @override
  State<_RuleEditorSheet> createState() => _RuleEditorSheetState();
}

class _RuleEditorSheetState extends State<_RuleEditorSheet> {
  late BlockRuleType _type;
  late final TextEditingController _valueController;
  late bool _caseSensitive;
  String? _error;

  // userId 类型通过搜索选择的用户
  String? _selectedUserId;
  String? _selectedUserName;
  String? _selectedUserAvatarUrl;

  ContentBlockService get _service => Get.find<ContentBlockService>();

  @override
  void initState() {
    super.initState();
    _type =
        widget.existing?.type ?? widget.initialType ?? BlockRuleType.keyword;
    _valueController = TextEditingController(
      text: widget.existing?.type == BlockRuleType.userId
          ? ''
          : widget.existing?.value ?? '',
    );
    _caseSensitive = widget.existing?.caseSensitive ?? false;
    if (widget.existing?.type == BlockRuleType.userId) {
      _selectedUserId = widget.existing!.value;
      _selectedUserName = widget.existing!.label;
    }
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  /// 打开正则表达式参考弹窗；每条示例都用一个真实标题演示「会命中什么」，
  /// 点击某条示例会直接把该正则填入输入框。
  void _showRegexHelp() {
    final t = slang.t.settings.blockSettings;
    // (正则, 说明, 演示用的示例标题)
    final examples = <(String, String, String)>[
      (t.regexEx1Pattern, t.regexEx1Desc, t.regexEx1Sample),
      (t.regexEx2Pattern, t.regexEx2Desc, t.regexEx2Sample),
      (t.regexEx3Pattern, t.regexEx3Desc, t.regexEx3Sample),
      (t.regexEx4Pattern, t.regexEx4Desc, t.regexEx4Sample),
      (t.regexEx5Pattern, t.regexEx5Desc, t.regexEx5Sample),
      (t.regexEx6Pattern, t.regexEx6Desc, t.regexEx6Sample),
      (t.regexEx7Pattern, t.regexEx7Desc, t.regexEx7Sample),
      (t.regexEx8Pattern, t.regexEx8Desc, t.regexEx8Sample),
      (t.regexEx9Pattern, t.regexEx9Desc, t.regexEx9Sample),
      (t.regexEx10Pattern, t.regexEx10Desc, t.regexEx10Sample),
    ];
    final width = math.min(420.0, MediaQuery.sizeOf(context).width - 48);

    // 富内容弹窗一律走 Dialog + 标题行(图标/标题/玻璃关闭圆钮) 的形制，
    // 而不是系统默认 AlertDialog 外壳；抄 comment_actions_sheet.dart 的
    // _SelectCopyDialog / glass_title_pill.dart 的 _GlassFullTitleDialog。
    showAppDialog(
      Dialog(
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: width,
            maxHeight: MediaQuery.sizeOf(context).height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.code,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.regexHelpTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
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
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.regexHelpIntro,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      for (final e in examples)
                        _RegexExampleTile(
                          pattern: e.$1,
                          desc: e.$2,
                          sample: e.$3,
                          sampleLabel: t.regexHelpSampleLabel,
                          matchedTag: t.regexHelpMatchedTag,
                          noMatchTag: t.regexHelpNoMatch,
                          onTap: () {
                            _valueController.text = e.$1;
                            _valueController.selection =
                                TextSelection.collapsed(offset: e.$1.length);
                            setState(() => _error = null);
                            AppService.tryPop();
                          },
                        ),
                      const SizedBox(height: 4),
                      Text(
                        t.regexHelpTapHint,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openUserSearch() {
    showAppBottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _UserSearchSheet(
          scrollController: scrollController,
          onUserSelected: (user) {
            AppService.tryPop();
            setState(() {
              _selectedUserId = user.id;
              _selectedUserName = user.name.isNotEmpty
                  ? user.name
                  : user.username;
              _selectedUserAvatarUrl = user.avatar?.avatarUrl;
              _error = null;
            });
          },
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// userId 类型的取值区域：搜索选人 + 校验错误提示。
  Widget _buildUserField(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _openUserSearch,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: _error != null
                    ? theme.colorScheme.error
                    : theme.dividerColor,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (_selectedUserAvatarUrl != null)
                  AvatarWidget(avatarUrl: _selectedUserAvatarUrl, size: 32)
                else
                  const Icon(Icons.person_search),
                const SizedBox(width: 10),
                Expanded(
                  child: _selectedUserId == null
                      ? Text(
                          slang.t.conversation.errors.clickToSelectAUser,
                          style: TextStyle(color: theme.hintColor),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedUserName?.isNotEmpty == true
                                  ? _selectedUserName!
                                  : _selectedUserId!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _selectedUserId!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.hintColor,
                              ),
                            ),
                          ],
                        ),
                ),
                const Icon(Icons.search),
              ],
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 6),
          Text(
            _error!,
            style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
          ),
        ],
      ],
    );
  }

  /// 关键词 / 正则类型的取值区域：文本输入框（正则带帮助入口）+ 大小写开关。
  Widget _buildValueField(
    BuildContext context,
    ThemeData theme,
    slang.TranslationsSettingsBlockSettingsEn t,
    bool isRegex,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassInputSurface(
          borderRadius: 8,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          error: _error != null,
          child: TextField(
            controller: _valueController,
            autofocus: true,
            decoration:
                glassFieldDecoration(
                  context,
                  label: t.value,
                  hint: isRegex ? t.regexHint : null,
                  errorText: _error,
                ).copyWith(
                  suffixIcon: isRegex
                      ? IconButton(
                          icon: const Icon(Icons.help_outline),
                          tooltip: t.regexHelp,
                          onPressed: _showRegexHelp,
                        )
                      : null,
                ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
        ),
        if (isRegex) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _showRegexHelp,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.lightbulb_outline, size: 16),
              label: Text(t.regexHelp),
            ),
          ),
        ],
        const SizedBox(height: 4),
        GlassSwitchItem(
          title: Text(t.caseSensitive),
          value: _caseSensitive,
          onChanged: (v) => setState(() => _caseSensitive = v),
        ),
      ],
    );
  }

  void _submit() {
    final t = slang.t.settings.blockSettings;
    if (_type == BlockRuleType.userId) {
      if (_selectedUserId == null || _selectedUserId!.isEmpty) {
        setState(() => _error = slang.t.conversation.errors.pleaseSelectAUser);
        return;
      }
      final base =
          widget.existing ??
          BlockRule(
            id: '',
            type: _type,
            value: _selectedUserId!,
            createdAt: DateTime.now().millisecondsSinceEpoch,
          );
      final rule = base.copyWith(
        type: BlockRuleType.userId,
        value: _selectedUserId!,
        label: _selectedUserName,
      );
      AppService.tryPop();
      widget.onSubmit(rule);
      return;
    }

    final value = _valueController.text.trim();
    if (value.isEmpty) {
      setState(() => _error = t.valueRequired);
      return;
    }
    if (_type == BlockRuleType.regex && !_service.isValidRegex(value)) {
      setState(() => _error = t.invalidRegex);
      return;
    }
    final base =
        widget.existing ??
        BlockRule(
          id: '',
          type: _type,
          value: value,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );
    final rule = base.copyWith(
      type: _type,
      value: value,
      caseSensitive: _caseSensitive,
    );
    AppService.tryPop();
    widget.onSubmit(rule);
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.t.settings.blockSettings;
    final theme = Theme.of(context);
    final isRegex = _type == BlockRuleType.regex;
    final isUser = _type == BlockRuleType.userId;
    // 同时兼顾键盘与底部安全区（手势条/导航条），见 computeSheetBottomInset。
    final bottomPad = computeSheetBottomInset(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部拖动条
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.existing == null ? t.addRule : t.editRule,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.ruleType, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  // 用图标 + 文字纵向堆叠的选项卡替代 SegmentedButton，
                  // 避免窄屏 Modal 中横向空间不足导致文字疯狂换行。
                  Row(
                    children: [
                      for (final type in BlockRuleType.values) ...[
                        if (type != BlockRuleType.values.first)
                          const SizedBox(width: 8),
                        Expanded(
                          child: _TypeChoiceCard(
                            icon: _typeIcon(type),
                            label: _typeLabel(type),
                            selected: _type == type,
                            onTap: () {
                              if (_type == type) return;
                              setState(() {
                                _type = type;
                                _error = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 切换规则类型时，下面这一整块（用户选择器 ↔ 值输入框，含
                  // 正则专属的帮助按钮/大小写开关）形状差异很大，用
                  // GlassShapeSwitcher 接管「淡出旧的 + 淡入新的 + 容器高度
                  // 连续过渡」，而不是任由 Column 硬切高度。key 按 _type 取，
                  // 关键词↔正则也会各自触发一次过渡（正则专属的帮助按钮就是
                  // 在这两者之间增减的）。
                  GlassShapeSwitcher(
                    sizeAlignment: Alignment.topCenter,
                    layoutAlignment: Alignment.topLeft,
                    child: KeyedSubtree(
                      key: ValueKey(_type),
                      child: isUser
                          ? _buildUserField(context, theme)
                          : _buildValueField(context, theme, t, isRegex),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => AppService.tryPop(),
                    child: Text(slang.t.common.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _submit,
                    child: Text(slang.t.common.confirm),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 用户搜索选择面板，参考「发起会话」弹窗的用户搜索实现。
class _UserSearchSheet extends StatefulWidget {
  final ValueChanged<User> onUserSelected;
  final ScrollController? scrollController;

  const _UserSearchSheet({required this.onUserSelected, this.scrollController});

  @override
  State<_UserSearchSheet> createState() => _UserSearchSheetState();
}

class _UserSearchSheetState extends State<_UserSearchSheet> {
  final ConversationService _conversationService =
      Get.find<ConversationService>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<User> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults.clear());
      return;
    }
    setState(() => _isLoading = true);
    final result = await _conversationService.searchUsers(query: query);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result.isSuccess && result.data != null) {
        _searchResults
          ..clear()
          ..addAll(result.data!.results);
      }
    });
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 500),
      () => _searchUsers(value),
    );
  }

  /// 主动触发搜索：取消防抖、立即按当前输入查询。
  void _triggerSearch() {
    _debounceTimer?.cancel();
    _searchFocusNode.unfocus();
    _searchUsers(_searchController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.t;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    t.conversation.selectAUser,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GlassIconButton(
                  standalone: true,
                  icon: const Icon(Icons.close),
                  tooltip: t.common.close,
                  onPressed: () => AppService.tryPop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: GlassInputSurface(
                    borderRadius: 8,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      textInputAction: TextInputAction.search,
                      onChanged: _onSearchChanged,
                      onSubmitted: (_) => _triggerSearch(),
                      decoration: glassFieldDecoration(
                        context,
                        hint: t.conversation.searchUsers,
                        icon: Icons.search,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _triggerSearch,
                    icon: const Icon(Icons.search, size: 18),
                    label: Text(t.common.search),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ListView.builder(
                controller: widget.scrollController,
                padding: EdgeInsets.only(
                  bottom: computeSheetBottomInset(context),
                ),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final user = _searchResults[index];
                  return ListTile(
                    leading: AvatarWidget(user: user),
                    title: buildUserName(context, user, fontSize: 14),
                    subtitle: Text('@${user.username}'),
                    onTap: () => widget.onUserSelected(user),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// 正则参考弹窗里的单条示例：左侧等宽展示模式，右侧说明，点击填入。
/// 正则参考弹窗里的单条示例：
/// 顶部是正则本身 + 点击填入，中间是说明，底部用一个真实标题演示
/// 「会命中哪一段」——命中的片段高亮，并打上「会被屏蔽」标签。
class _RegexExampleTile extends StatelessWidget {
  final String pattern;
  final String desc;
  final String sample;
  final String sampleLabel;
  final String matchedTag;
  final String noMatchTag;
  final VoidCallback onTap;

  const _RegexExampleTile({
    required this.pattern,
    required this.desc,
    required this.sample,
    required this.sampleLabel,
    required this.matchedTag,
    required this.noMatchTag,
    required this.onTap,
  });

  /// 在示例标题上跑一遍正则，取首个匹配区间（不区分大小写，贴近默认行为）。
  (int, int)? _matchRange() {
    try {
      final m = RegExp(pattern, caseSensitive: false).firstMatch(sample);
      if (m == null || m.end <= m.start) return null;
      return (m.start, m.end);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final range = _matchRange();
    final matched = range != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 正则本身 + 「点击填入」提示
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: scheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          pattern,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.edit_outlined,
                      size: 15,
                      color: scheme.primary.withValues(alpha: 0.8),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 说明
                Text(
                  desc,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                // 效果预览：示例标题 + 命中高亮 + 标签
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$sampleLabel  ',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                    Expanded(child: _buildSamplePreview(context, range)),
                  ],
                ),
                const SizedBox(height: 8),
                _MatchTag(
                  matched: matched,
                  label: matched ? matchedTag : noMatchTag,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 把示例标题渲染成富文本，命中的片段加高亮底色。
  Widget _buildSamplePreview(BuildContext context, (int, int)? range) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final base = theme.textTheme.bodyMedium?.copyWith(height: 1.35);
    if (range == null) {
      return Text(sample, style: base);
    }
    final (start, end) = range;
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          if (start > 0) TextSpan(text: sample.substring(0, start)),
          TextSpan(
            text: sample.substring(start, end),
            style: base?.copyWith(
              color: scheme.onErrorContainer,
              fontWeight: FontWeight.w700,
              backgroundColor: scheme.errorContainer,
            ),
          ),
          if (end < sample.length) TextSpan(text: sample.substring(end)),
        ],
      ),
    );
  }
}

/// 命中 / 未命中标签。
class _MatchTag extends StatelessWidget {
  final bool matched;
  final String label;

  const _MatchTag({required this.matched, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = matched ? scheme.onErrorContainer : scheme.onSurfaceVariant;
    final bg = matched ? scheme.errorContainer : scheme.surfaceContainerHighest;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            matched ? Icons.block : Icons.check_circle_outline,
            size: 13,
            color: fg,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
