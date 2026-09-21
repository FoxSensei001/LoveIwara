import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/ai_provider.model.dart';
import 'package:i_iwara/app/models/ai_task.model.dart';
import 'package:i_iwara/app/services/ai_profile_store.dart';
import 'package:i_iwara/app/services/ai_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/ai_provider_editor.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// AI 设置页里的「供应商列表」内容区。
///
/// 遵循 `SignatureProvidersBody` 的视觉与交互范式：
/// 一张列表 + 每行测试/删除 + 点行即编辑 + 底部新增按钮。
class AiProvidersBody extends StatefulWidget {
  const AiProvidersBody({super.key, this.onChanged});

  final VoidCallback? onChanged;

  @override
  State<AiProvidersBody> createState() => _AiProvidersBodyState();
}

class _AiProvidersBodyState extends State<AiProvidersBody> {
  final AiService _aiService = Get.find<AiService>();
  ConfigProfileStore get _store => _aiService.store as ConfigProfileStore;

  final Map<String, String> _tested = {};
  final Map<String, String> _failed = {};

  @override
  void initState() {
    super.initState();
    _store.ensureReady().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _test(AiProviderProfile profile) async {
    final t = slang.t;
    try {
      final res = await _aiService.test(profile);
      if (!mounted) return;
      final data = res.data;
      setState(() {
        if (data != null && data.connectionValid) {
          _tested[profile.id] = t.ai.testOk;
          _failed.remove(profile.id);
        } else {
          final err = data?.custMessage ?? res.message;
          _failed[profile.id] = err.isNotEmpty ? err : 'Failed';
          _tested.remove(profile.id);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _failed[profile.id] = e.toString();
        _tested.remove(profile.id);
      });
    }
  }

  Future<void> _edit({AiProviderProfile? existing}) async {
    final profiles = _store.profiles;
    final takenIds = profiles.map((p) => p.id).toSet();
    if (existing != null) {
      takenIds.remove(existing.id);
    }
    final result = await showAiProviderEditor(
      context,
      initial: existing,
      takenIds: takenIds,
    );
    if (result == null) return;

    final next = List<AiProviderProfile>.from(profiles);
    final index = next.indexWhere((p) => p.id == (existing?.id ?? result.id));
    if (index >= 0) {
      next[index] = result;
    } else {
      next.add(result);
    }
    await _store.saveProfiles(next);
    if (mounted) setState(() {});
    widget.onChanged?.call();
  }

  Future<void> _delete(AiProviderProfile profile) async {
    final t = slang.t;
    final confirmed = await showAppDialog<bool>(
      GlassAlertDialog(
        title: profile.name.isEmpty ? profile.id : profile.name,
        content: Text(t.ai.deleteProvider),
        actions: [
          GlassDialogAction(
            label: t.common.cancel,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          GlassDialogAction(
            label: t.common.delete,
            destructive: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final next = _store.profiles.where((p) => p.id != profile.id).toList();
    await _store.saveProfiles(next);

    // 删除一条档案后，把绑定表里指向它的那几个用途一并清掉
    final nextBindings = Map<AiTask, String>.from(_store.bindings);
    nextBindings.removeWhere((task, id) => id == profile.id);
    await _store.saveBindings(nextBindings);

    if (mounted) setState(() {});
    widget.onChanged?.call();
  }

  String _usedByText(
    slang.Translations t,
    String profileId,
    Map<AiTask, String> bindings,
  ) {
    final tasks = <String>[];
    if (bindings[AiTask.translate] == profileId) {
      tasks.add(t.ai.taskTranslate);
    }
    if (bindings[AiTask.searchQuery] == profileId) {
      tasks.add(t.ai.taskSearch);
    }
    if (bindings[AiTask.signature] == profileId) {
      tasks.add(t.ai.taskSignature);
    }
    if (tasks.isEmpty) return '';
    return '${t.ai.usedBy}: ${tasks.join(', ')}';
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final profiles = _store.profiles;
    final bindings = _store.bindings;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.ai.providersHint,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final profile in profiles)
                  _AiProviderRow(
                    key: ValueKey(profile.id),
                    profile: profile,
                    usedBy: _usedByText(t, profile.id, bindings),
                    successText: _tested[profile.id],
                    errorText: _failed[profile.id],
                    onTest: () => _test(profile),
                    onEdit: () => _edit(existing: profile),
                    onDelete: () => _delete(profile),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GlassButtonGroup(
                children: [
                  GlassTextActionButton(
                    label: t.ai.addProvider,
                    emphasized: true,
                    onPressed: () => _edit(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiProviderRow extends StatelessWidget {
  const _AiProviderRow({
    super.key,
    required this.profile,
    required this.usedBy,
    required this.successText,
    required this.errorText,
    required this.onTest,
    required this.onEdit,
    required this.onDelete,
  });

  final AiProviderProfile profile;
  final String usedBy;
  final String? successText;
  final String? errorText;
  final Future<void> Function() onTest;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final subtitle = errorText ?? successText;
    final hasModel = profile.model.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              profile.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: cs.secondaryContainer.withValues(
                                alpha: 0.7,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              AiProviderKind.displayName(profile.kind),
                              style: TextStyle(
                                fontSize: 10,
                                color: cs.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasModel ? profile.model : t.ai.notConfigured,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: hasModel ? 'monospace' : null,
                          color: hasModel ? cs.primary : cs.onSurfaceVariant,
                        ),
                      ),
                      if (usedBy.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          usedBy,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (subtitle != null && subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.3,
                            color: errorText != null ? cs.error : Colors.green,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                GlassAsyncIconButton(
                  icon: const Icon(Icons.play_arrow_outlined),
                  tooltip: t.ai.test,
                  standalone: true,
                  onPressed: onTest,
                ),
                // ⛔ 编辑必须有一枚看得见的钮。「点整行即编辑」是隐藏交互——
                // 建完一条之后没人知道还能改（2026-09-21 用户报障）。整行仍然
                // 可点，这枚只是把那条路说出来。
                GlassIconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: t.common.edit,
                  standalone: true,
                  onPressed: onEdit,
                ),
                GlassIconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: t.ai.deleteProvider,
                  standalone: true,
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
