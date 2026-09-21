import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/ai_task.model.dart';
import 'package:i_iwara/app/services/ai_profile_store.dart';
import 'package:i_iwara/app/services/ai_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/ai_providers_card.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dropdown_field.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// AI 配置页：供应商列表、功能分配与用量统计。
class AiSettingsPage extends StatefulWidget {
  final bool isWideScreen;

  const AiSettingsPage({super.key, this.isWideScreen = false});

  @override
  State<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends State<AiSettingsPage> {
  final AiService _aiService = Get.find<AiService>();
  ConfigProfileStore get _store => _aiService.store as ConfigProfileStore;
  final ConfigService _configService = Get.find<ConfigService>();

  /// 下拉里代表「自动（第一条可用的）」那一项。绑定表里**没有**这个值，
  /// 选中它等于把这个用途从表里删掉。
  static const String _autoBindingValue = '__auto__';

  @override
  void initState() {
    super.initState();
    _store.ensureReady().then((_) {
      if (mounted) setState(() {});
    });
  }

  /// 把某个用途绑到某份档案上。[profileId] 为 null＝回到「自动」。
  ///
  /// ⛔ 这里不自己弹菜单：表单里的下拉一律收口到 GlassDropdownField（玻璃
  /// 风格闸门盯着这条）。Material 的 DropdownButton 吐出来是块不透明卡片，
  /// 和玻璃触发件接不上。
  Future<void> _applyBinding(AiTask task, String? profileId) async {
    final next = Map<AiTask, String>.from(_store.bindings);
    if (profileId == null || profileId.isEmpty) {
      next.remove(task);
    } else {
      next[task] = profileId;
    }
    await _store.saveBindings(next);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final bottomInset = computeBottomSafeInset(MediaQuery.of(context));
    final profiles = _store.profiles;
    final bindings = _store.bindings;

    final tasks = [
      (AiTask.translate, t.ai.taskTranslate),
      (AiTask.searchQuery, t.ai.taskSearch),
      (AiTask.signature, t.ai.taskSignature),
    ];

    final isUsageEmpty = tasks.every((item) {
      final s = _aiService.usageOf(item.$1);
      return s.calls == 0 && s.totalTokens == 0 && s.failures == 0;
    });

    return GlassSettingsScaffold(
      title: t.ai.title,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // 1. 供应商卡片
              Card(
                elevation: 2,
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        t.ai.providers,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(height: 1),
                    AiProvidersBody(onChanged: () => setState(() {})),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 2. 功能分配卡片
              Card(
                elevation: 2,
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.ai.taskBindings,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t.ai.taskBindingsHint,
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    if (profiles.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          t.ai.noProviders,
                          style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      )
                    else ...[
                      // 「翻译要不要走 AI」原先住在已删掉的那张 AI 翻译子页里，
                      // 跟着配置一起搬到这儿。它只管翻译这一个用途，所以贴着
                      // 用途列表放，而不是做成整页的总开关。
                      Obx(
                        () => SwitchListTile(
                          title: Text(t.translation.aiTranslation),
                          value:
                              _configService[ConfigKey.USE_AI_TRANSLATION]
                                  as bool,
                          onChanged: (value) {
                            // DeepLX 的互斥由 ConfigService 自己保证，不重复做。
                            _configService[ConfigKey.USE_AI_TRANSLATION] =
                                value;
                          },
                        ),
                      ),
                      const Divider(height: 1, indent: 16),
                      for (var i = 0; i < tasks.length; i++) ...[
                        if (i > 0) const Divider(height: 1, indent: 16),
                        Builder(
                          builder: (tileContext) {
                            final task = tasks[i].$1;
                            final taskTitle = tasks[i].$2;
                            final boundId = bindings[task];
                            final boundProfile = boundId == null
                                ? null
                                : profiles.firstWhereOrNull(
                                    (p) => p.id == boundId,
                                  );

                            return ListTile(
                              title: Text(taskTitle),
                              // shrinkWrap: true ＝ 按内容收缩。撑满会把左边的
                              // 标题挤没（见 GlassDropdownField.shrinkWrap）。
                              trailing: GlassDropdownField<String>(
                                shrinkWrap: true,
                                value: boundProfile?.id ?? _autoBindingValue,
                                items: [
                                  GlassDropdownItem<String>(
                                    value: _autoBindingValue,
                                    label: t.ai.taskAuto,
                                  ),
                                  for (final p in profiles)
                                    GlassDropdownItem<String>(
                                      value: p.id,
                                      label: p.name,
                                    ),
                                ],
                                onChanged: (picked) => _applyBinding(
                                  task,
                                  picked == _autoBindingValue ? null : picked,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 3. 用量卡片
              Card(
                elevation: 2,
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              t.ai.usage,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          GlassIconButton(
                            standalone: true,
                            icon: const Icon(Icons.delete_sweep_outlined),
                            tooltip: t.ai.usageReset,
                            onPressed: () async {
                              await _aiService.resetUsage();
                              if (mounted) setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    if (isUsageEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          t.ai.usageEmpty,
                          style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      for (var i = 0; i < tasks.length; i++) ...[
                        if (i > 0) const Divider(height: 1, indent: 16),
                        Builder(
                          builder: (context) {
                            final task = tasks[i].$1;
                            final taskTitle = tasks[i].$2;
                            final stat = _aiService.usageOf(task);

                            return ListTile(
                              title: Text(taskTitle),
                              subtitle: Text(
                                '${t.ai.usageCalls}: ${stat.calls}  •  ${t.ai.usageTokens}: ${stat.totalTokens}  •  ${t.ai.usageFailures}: ${stat.failures}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}
