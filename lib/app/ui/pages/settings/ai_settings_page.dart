import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/ai_provider.model.dart';
import 'package:i_iwara/app/models/ai_task.model.dart';
import 'package:i_iwara/app/services/ai_catalog_service.dart';
import 'package:i_iwara/app/services/ai_profile_store.dart';
import 'package:i_iwara/app/services/ai_service.dart';
import 'package:i_iwara/app/services/config_service.dart';
import 'package:i_iwara/app/utils/ai_token_format.dart';
import 'package:i_iwara/app/ui/pages/settings/settings_navigation.dart';
import 'package:i_iwara/app/ui/pages/settings/settings_section.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/ai_provider_wizard.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/glass_setting_tiles.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/settings_app_bar.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_dropdown_field.dart';
import 'package:i_iwara/app/ui/widgets/media_query_insets_fix.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// AI 设置页：供应商列表、功能分配、用量。
///
/// ⭐ 版式是「列表页 → 详情页」两级：供应商在这里只占一行（名字 · 接入方式 ·
/// 几个模型 · 配没配密钥），点进去才是连接、模型、高级那三段。一页塞下全部的
/// 老写法在只有一家供应商时还行，加到三五家就没法管了。
class AiSettingsPage extends StatefulWidget {
  final bool isWideScreen;

  const AiSettingsPage({super.key, this.isWideScreen = false});

  @override
  State<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends State<AiSettingsPage> {
  final AiService _aiService = Get.find<AiService>();
  final ConfigService _configService = Get.find<ConfigService>();

  ConfigProfileStore get _store => _aiService.store as ConfigProfileStore;

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

  /// 把某个用途绑到某条模型上。[modelKey] 为 null＝回到「自动」。
  Future<void> _applyBinding(AiTask task, String? modelKey) async {
    final next = Map<AiTask, String>.from(_store.bindings);
    if (modelKey == null || modelKey.isEmpty) {
      next.remove(task);
    } else {
      next[task] = modelKey;
    }
    await _store.saveBindings(next);
    if (mounted) setState(() {});
  }

  Future<void> _addProvider() async {
    final result = await showAiProviderWizard(
      context,
      takenIds: _store.config.providers.map((e) => e.id).toSet(),
    );
    if (result == null || !mounted) return;

    final current = _store.config;
    await _store.saveConfig(
      AiProviderConfig(
        providers: [...current.providers, result.provider],
        models: [...current.models, ...result.models],
      ),
    );
    if (!mounted) return;
    setState(() {});
    // 建完直接进详情页：用户接下来八成要调点什么，而且这一步顺带让他知道
    // 「点那一行可以进来改」。
    SettingsNavigation.openSubPage(
      SettingsSubRoutes.aiProvider(result.provider.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final bottomInset = computeBottomSafeInset(MediaQuery.of(context));
    final config = _store.config;
    final bindings = _store.bindings;
    final resolved = _store.allResolved;

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
              _hint(cs, t.ai.providersHint),
              const SizedBox(height: 8),
              GlassSettingSection(
                title: t.ai.providers,
                children: [
                  for (final provider in config.providers)
                    _ProviderRow(
                      key: ValueKey(provider.id),
                      provider: provider,
                      modelCount: config.modelsOf(provider.id).length,
                      hasKey: (_store.keyOf(provider.id) ?? '').isNotEmpty,
                      onTap: () async {
                        await SettingsNavigation.openSubPage(
                          SettingsSubRoutes.aiProvider(provider.id),
                        );
                        // 详情页里改完东西回来，这一行的「几个模型 / 配没配密钥」
                        // 要跟着变。
                        if (mounted) setState(() {});
                      },
                    ),
                  GlassSettingTile(
                    icon: Icons.add,
                    title: Text(t.ai.addProvider),
                    onTap: _addProvider,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _hint(cs, t.ai.taskBindingsHint),
              const SizedBox(height: 8),
              GlassSettingSection(
                title: t.ai.taskBindings,
                children: [
                  // 「翻译要不要走 AI」只管翻译这一个用途，所以贴着用途列表放，
                  // 而不是做成整页的总开关。
                  Obx(
                    () => GlassSwitchItem(
                      title: Text(t.translation.aiTranslation),
                      value:
                          _configService[ConfigKey.USE_AI_TRANSLATION] as bool,
                      onChanged: (value) {
                        // DeepLX 的互斥由 ConfigService 自己保证，不重复做。
                        _configService[ConfigKey.USE_AI_TRANSLATION] = value;
                      },
                    ),
                  ),
                  if (resolved.isEmpty)
                    GlassSettingTile(
                      title: Text(
                        t.ai.noProviders,
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    for (final (task, title) in tasks)
                      _BindingRow(
                        label: title,
                        value: _bindingValue(bindings, resolved, task),
                        items: [
                          GlassDropdownItem<String>(
                            value: _autoBindingValue,
                            label: t.ai.taskAuto,
                          ),
                          for (final m in resolved)
                            GlassDropdownItem<String>(
                              value: '${m.providerId}/${m.modelId}',
                              label: _modelLabel(t, m),
                            ),
                        ],
                        onChanged: (picked) => _applyBinding(
                          task,
                          picked == _autoBindingValue ? null : picked,
                        ),
                      ),
                ],
              ),
              const SizedBox(height: 16),
              GlassSettingSection(
                title: t.ai.usage,
                children: [
                  if (isUsageEmpty)
                    GlassSettingTile(
                      title: Text(
                        t.ai.usageEmpty,
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    for (final (task, title) in tasks)
                      Builder(
                        builder: (context) {
                          final stat = _aiService.usageOf(task);
                          return GlassSettingTile(
                            title: Text(title),
                            subtitle: Text(
                              // ⛔ token 一律走 formatTokenCount：这里的量级是
                              // 几万到几百万，裸数字要数位数才知道是 16 万还是
                              // 160 万。
                              '${t.ai.usageCalls}: ${stat.calls}  •  '
                              '${t.ai.usageTokens}: '
                              '${formatTokenCount(stat.totalTokens)}  •  '
                              '${t.ai.usageFailures}: ${stat.failures}',
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                      ),
                  GlassSettingTile(
                    icon: Icons.delete_sweep_outlined,
                    title: Text(t.ai.usageReset),
                    onTap: () async {
                      await _aiService.resetUsage();
                      if (mounted) setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 目录的身份。⭐ 它会随 CDN 静默更新，用户至少要能看出「我这份是
              // 什么时候的」——否则「怎么没有新模型」这种问题无从自查。
              Obx(() {
                final snapshot = Get.isRegistered<AiCatalogService>()
                    ? AiCatalogService.to.snapshot.value
                    : null;
                return _hint(
                  cs,
                  snapshot == null
                      ? t.ai.catalogMissing
                      : t.ai.catalogVersion(version: snapshot.toString()),
                );
              }),
            ]),
          ),
        ),
      ],
    );
  }

  /// 下拉当前该选中哪一项。
  ///
  /// ⛔ 绑定值指向的模型已被删掉时要落回「自动」，不能原样传给下拉——
  /// `GlassDropdownField` 的 value 不在 items 里时显示的是一片空白，
  /// 用户会以为这一项坏了。
  String _bindingValue(
    Map<AiTask, String> bindings,
    List<AiResolvedModel> resolved,
    AiTask task,
  ) {
    final bound = bindings[task];
    if (bound == null) return _autoBindingValue;
    final exists = resolved.any((m) => '${m.providerId}/${m.modelId}' == bound);
    return exists ? bound : _autoBindingValue;
  }

  static String _modelLabel(slang.Translations t, AiResolvedModel m) =>
      m.modelName.isEmpty
      ? '${m.providerName} · ${t.ai.serverDefaultModel}'
      : '${m.providerName} · ${m.modelName}';

  Widget _hint(ColorScheme cs, String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Text(
      text,
      style: TextStyle(fontSize: 12, height: 1.35, color: cs.onSurfaceVariant),
    ),
  );
}

/// 「某个用途 → 哪条模型」一行。
///
/// ⛔ **不做成 [GlassSettingTile] 的 trailing**：绑定值是「供应商 · 模型」两截
/// 拼出来的，`shuai · DeepSeek: DeepSeek V4.1 Flash` 这种长度是常态，挤在右边
/// 一栏里只剩开头几个字——而这一行要给的信息**全在那个值上**，截断等于这一行
/// 白画。标签自己占一行，选择器占满下面一整行（版式与供应商详情页的
/// `_field` 是同一套：12/w600 的小标签 + 下面一条撑满的控件）。
class _BindingRow extends StatelessWidget {
  const _BindingRow({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<GlassDropdownItem<String>> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          // 撑满（不传 shrinkWrap）＝箭头贴右、文字有整行可用。
          GlassDropdownField<String>(
            value: value,
            items: items,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// 供应商列表里的一行。
///
/// 左边一枚状态点：⛔ 「配没配好」必须是**看得见**的，否则用户要点进每一家才
/// 知道哪一家缺密钥。
class _ProviderRow extends StatelessWidget {
  const _ProviderRow({
    super.key,
    required this.provider,
    required this.modelCount,
    required this.hasKey,
    required this.onTap,
  });

  final AiProvider provider;
  final int modelCount;
  final bool hasKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final catalog = AiCatalogService.providerOf(provider.catalogId);
    final name = provider.name ?? catalog?.name ?? provider.id;
    final kind = provider.kind ?? catalog?.kind ?? AiProviderKind.openai;
    final needsKey = catalog?.needsApiKey ?? AiProviderKind.needsApiKey(kind);
    final ready = !needsKey || hasKey;

    final subtitle = [
      modelCount == 0
          ? t.ai.noModels
          : t.ai.providerModelCount(count: modelCount),
      if (!ready) t.ai.missingApiKey,
    ].join(' · ');

    return GlassSettingTile(
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(
          ready ? Icons.circle : Icons.circle_outlined,
          size: 10,
          color: !provider.enabled
              ? cs.onSurfaceVariant.withValues(alpha: 0.5)
              : (ready ? Colors.green : cs.error),
        ),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                // 关掉的供应商整行降透明度：禁用是一种**状态**，必须画出来。
                color: provider.enabled
                    ? null
                    : cs.onSurface.withValues(alpha: 0.38),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: cs.secondaryContainer.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              AiProviderKind.displayName(kind),
              style: TextStyle(fontSize: 10, color: cs.onSecondaryContainer),
            ),
          ),
        ],
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          color: ready ? cs.onSurfaceVariant : cs.error,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
