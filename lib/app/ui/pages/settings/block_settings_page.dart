import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Translations;
import 'package:i_iwara/app/models/block_rule.model.dart';
import 'package:i_iwara/app/models/user.model.dart';
import 'package:i_iwara/app/services/app_service.dart';
import 'package:i_iwara/app/services/content_block_service.dart';
import 'package:i_iwara/app/services/conversation_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/widgets/avatar_widget.dart';
import 'package:i_iwara/app/ui/widgets/md_toast_widget.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/app/ui/widgets/user_name_widget.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;
import 'package:i_iwara/utils/logger_utils.dart';
import 'package:oktoast/oktoast.dart';

class BlockSettingsPage extends StatelessWidget {
  final bool isWideScreen;

  const BlockSettingsPage({super.key, this.isWideScreen = false});

  ContentBlockService get _service => Get.find<ContentBlockService>();

  slang.TranslationsSettingsBlockSettingsEn get _t =>
      slang.t.settings.blockSettings;

  void _addRule(BuildContext context, {BlockRule? existing}) {
    showAppDialog(
      _RuleEditorDialog(
        existing: existing,
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
        },
      ),
    );
  }

  Future<void> _export(BuildContext context) async {
    try {
      final ok = await _service.exportRulesToFile();
      if (ok) {
        showToastWidget(
          MDToastWidget(message: _t.exportSuccess, type: MDToastType.success),
        );
      }
    } catch (e) {
      LogUtils.e('导出屏蔽规则失败', tag: 'BlockSettingsPage', error: e);
      showToastWidget(
        MDToastWidget(message: _t.exportFailed, type: MDToastType.error),
      );
    }
  }

  Future<void> _import(BuildContext context) async {
    try {
      final added = await _service.importRulesFromFile();
      if (added == null) return; // 用户取消
      showToastWidget(
        MDToastWidget(
          message: _t.importSuccess(count: added.toString()),
          type: MDToastType.success,
        ),
      );
    } catch (e) {
      LogUtils.e('导入屏蔽规则失败', tag: 'BlockSettingsPage', error: e);
      showToastWidget(
        MDToastWidget(message: _t.importFailed, type: MDToastType.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = computeBottomSafeInset(MediaQuery.of(context));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addRule(context),
        icon: const Icon(Icons.add),
        label: Text(_t.addRule),
      ),
      body: CustomScrollView(
        slivers: [
          BlurredSliverAppBar(title: _t.title, isWideScreen: isWideScreen),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 96 + bottomInset),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Obx(() {
                    final rules = _service.rules.toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeaderCard(context, rules),
                        const SizedBox(height: 16),
                        if (rules.isEmpty)
                          _EmptyState(text: _t.noRules)
                        else
                          ..._buildGroupedSections(context, rules),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 顶部概览卡：图标、说明、各类型规则数量统计、导入/导出。
  Widget _buildHeaderCard(BuildContext context, List<BlockRule> rules) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabledCount = rules.where((r) => r.enabled).length;

    int countOf(BlockRuleType type) =>
        rules.where((r) => r.type == type).length;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.block, color: scheme.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _t.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (rules.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatChip(
                    icon: Icons.toggle_on,
                    label: '$enabledCount/${rules.length}',
                  ),
                  _StatChip(
                    icon: _typeIcon(BlockRuleType.keyword),
                    label:
                        '${_typeLabel(BlockRuleType.keyword)} ${countOf(BlockRuleType.keyword)}',
                  ),
                  _StatChip(
                    icon: _typeIcon(BlockRuleType.regex),
                    label:
                        '${_typeLabel(BlockRuleType.regex)} ${countOf(BlockRuleType.regex)}',
                  ),
                  _StatChip(
                    icon: _typeIcon(BlockRuleType.userId),
                    label:
                        '${_typeLabel(BlockRuleType.userId)} ${countOf(BlockRuleType.userId)}',
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            // 导入 / 导出：窄屏换行，宽屏一行
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _import(context),
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: Text(_t.importRules),
                ),
                OutlinedButton.icon(
                  onPressed: () => _export(context),
                  icon: const Icon(Icons.file_upload_outlined, size: 18),
                  label: Text(_t.exportRules),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 按类型分组的规则区块，每组一张卡。
  List<Widget> _buildGroupedSections(
    BuildContext context,
    List<BlockRule> rules,
  ) {
    final theme = Theme.of(context);
    final sections = <Widget>[];

    for (final type in BlockRuleType.values) {
      final group = rules.where((r) => r.type == type).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (group.isEmpty) continue;

      sections.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card(
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.12),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Icon(
                        _typeIcon(type),
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _typeLabel(type),
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${group.length}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                for (int i = 0; i < group.length; i++) ...[
                  if (i != 0)
                    Divider(
                      height: 1,
                      indent: 16,
                      color: theme.dividerColor.withValues(alpha: 0.1),
                    ),
                  _RuleTile(
                    rule: group[i],
                    onToggle: (v) => _service.toggleRule(group[i].id, v),
                    onEdit: () => _addRule(context, existing: group[i]),
                    onDelete: () => _service.removeRule(group[i].id),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }
    return sections;
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

    return Opacity(
      opacity: dimmed ? 0.55 : 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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
            PopupMenuButton<String>(
              tooltip: '',
              icon: const Icon(Icons.more_vert),
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 18),
                      const SizedBox(width: 10),
                      Text(t.editRule),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: scheme.error,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        t.deleteRule,
                        style: TextStyle(color: scheme.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
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

/// 新增 / 编辑规则对话框。提交时通过 [onSubmit] 回传规则（编辑时保留原 id），
/// 并使用 [AppService.tryPop] 关闭对话框。
class _RuleEditorDialog extends StatefulWidget {
  final BlockRule? existing;
  final Future<void> Function(BlockRule rule) onSubmit;

  const _RuleEditorDialog({this.existing, required this.onSubmit});

  @override
  State<_RuleEditorDialog> createState() => _RuleEditorDialogState();
}

class _RuleEditorDialogState extends State<_RuleEditorDialog> {
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
    _type = widget.existing?.type ?? BlockRuleType.keyword;
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

  /// 打开正则表达式参考弹窗；点击某条示例会直接填入输入框。
  void _showRegexHelp() {
    final t = slang.t.settings.blockSettings;
    final examples = <(String, String)>[
      (t.regexEx1Pattern, t.regexEx1Desc),
      (t.regexEx2Pattern, t.regexEx2Desc),
      (t.regexEx3Pattern, t.regexEx3Desc),
      (t.regexEx4Pattern, t.regexEx4Desc),
      (t.regexEx5Pattern, t.regexEx5Desc),
    ];

    showAppDialog(
      AlertDialog(
        title: Text(t.regexHelpTitle),
        content: SizedBox(
          width: 380,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.regexHelpIntro,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                for (final e in examples)
                  _RegexExampleTile(
                    pattern: e.$1,
                    desc: e.$2,
                    onTap: () {
                      _valueController.text = e.$1;
                      _valueController.selection = TextSelection.collapsed(
                        offset: e.$1.length,
                      );
                      setState(() => _error = null);
                      AppService.tryPop();
                    },
                  ),
                const SizedBox(height: 8),
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
        actions: [
          TextButton(
            onPressed: () => AppService.tryPop(),
            child: Text(slang.t.common.confirm),
          ),
        ],
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

    return AlertDialog(
      title: Text(widget.existing == null ? t.addRule : t.editRule),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.ruleType, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<BlockRuleType>(
              segments: [
                ButtonSegment(
                  value: BlockRuleType.keyword,
                  label: Text(t.keyword),
                ),
                ButtonSegment(
                  value: BlockRuleType.regex,
                  label: Text(t.regex),
                ),
                ButtonSegment(
                  value: BlockRuleType.userId,
                  label: Text(t.userId),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) {
                setState(() {
                  _type = s.first;
                  _error = null;
                });
              },
            ),
            const SizedBox(height: 16),
            if (isUser) ...[
              InkWell(
                onTap: _openUserSearch,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
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
                        AvatarWidget(
                          avatarUrl: _selectedUserAvatarUrl,
                          size: 32,
                        )
                      else
                        const Icon(Icons.person_search),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _selectedUserId == null
                            ? Text(
                                slang
                                    .t
                                    .conversation
                                    .errors
                                    .clickToSelectAUser,
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
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
            ] else ...[
              TextField(
                controller: _valueController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: t.value,
                  hintText: isRegex ? t.regexHint : null,
                  errorText: _error,
                  border: const OutlineInputBorder(),
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
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.caseSensitive),
                value: _caseSensitive,
                onChanged: (v) => setState(() => _caseSensitive = v),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => AppService.tryPop(),
          child: Text(slang.t.common.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(slang.t.common.confirm),
        ),
      ],
    );
  }
}

/// 用户搜索选择面板，参考「发起会话」弹窗的用户搜索实现。
class _UserSearchSheet extends StatefulWidget {
  final ValueChanged<User> onUserSelected;
  final ScrollController? scrollController;

  const _UserSearchSheet({
    required this.onUserSelected,
    this.scrollController,
  });

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
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.conversation.selectAUser,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => AppService.tryPop(),
                  icon: const Icon(Icons.close),
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
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    textInputAction: TextInputAction.search,
                    onChanged: _onSearchChanged,
                    onSubmitted: (_) => _triggerSearch(),
                    decoration: InputDecoration(
                      hintText: t.conversation.searchUsers,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
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
class _RegexExampleTile extends StatelessWidget {
  final String pattern;
  final String desc;
  final VoidCallback onTap;

  const _RegexExampleTile({
    required this.pattern,
    required this.desc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    pattern,
                    style: const TextStyle(
                      fontFamily: "monospace",
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    desc,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.25,
                    ),
                  ),
                ),
                Icon(
                  Icons.north_west,
                  size: 15,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
