import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i_iwara/app/models/signature_provider.model.dart';
import 'package:i_iwara/app/services/signature_service.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/signature_variable_picker.dart';
import 'package:i_iwara/app/ui/pages/settings/widgets/signature_provider_wizard.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_alert_dialog.dart';
import 'package:i_iwara/app/ui/widgets/glass/glass_surface.dart';
import 'package:i_iwara/app/utils/show_app_dialog.dart';
import 'package:i_iwara/i18n/strings.g.dart' as slang;

/// 设置页里的「数据源」整块：小尾巴能引用的那些接口。
///
/// ⭐ 一言在这张列表里就是**第一条**，和用户自己接的接口并列。它不是一个藏在
/// 编辑器里的特殊变量——用户只需要理解「数据源」这一个概念，理解完就顺带会用
/// 自己的接口了。
///
/// 外壳（Card / 标题行）由设置页提供，与 `SignatureSettingsBody` 同一个约定。
class SignatureProvidersBody extends StatefulWidget {
  const SignatureProvidersBody({super.key});

  @override
  State<SignatureProvidersBody> createState() => _SignatureProvidersBodyState();
}

class _SignatureProvidersBodyState extends State<SignatureProvidersBody> {
  final SignatureService _service = Get.find<SignatureService>();

  /// 刚刚测出来的值，按数据源 id 存。测完就显示在那一行上——这是用户验收
  /// 一个源「到底会给我什么」的唯一地方。
  final Map<String, String> _tested = {};
  final Map<String, String> _failed = {};

  Future<void> _test(SignatureProvider provider) async {
    try {
      final value = await _service.fetchWith(provider);
      if (!mounted) return;
      setState(() {
        _failed.remove(provider.id);
        if (value == null || value.trim().isEmpty) {
          _failed[provider.id] = slang.t.settings.signatureSourceTestFailed;
        } else {
          _tested[provider.id] = value.trim();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _failed[provider.id] = e.toString());
    }
  }

  Future<void> _edit({SignatureProvider? existing}) async {
    final custom = _service.customProviders;
    final result = await showSignatureProviderWizard(
      context,
      initial: existing,
      // ⛔ 正在编辑的那条要从「已占用」里排掉，**内置那份也算**：编辑内置的
      // 一言时若把 `hitokoto` 当成被占，向导会给它改名成 `hitokoto_2`，
      // 用户模板里写好的 `{hitokoto}` 当场指空。
      takenIds: {
        ...SignatureProvider.builtins.map((e) => e.id),
        ...custom.map((e) => e.id),
      }..remove(existing?.id),
    );
    if (result == null) return;

    final next = List.of(custom);
    final index = next.indexWhere((e) => e.id == existing?.id);
    if (index >= 0) {
      next[index] = result;
    } else {
      next.add(result);
    }
    await _service.saveCustomProviders(next);
    if (mounted) setState(() {});
  }

  Future<void> _delete(SignatureProvider provider) async {
    final t = slang.t;
    // 内置源的位子上删掉的只是「用户改过的那份」，删完它会变回出厂的样子。
    final isRestore = SignatureService.isBuiltinSlot(provider.id);
    final confirmed = await showAppDialog<bool>(
      GlassAlertDialog(
        title: provider.name.isEmpty ? provider.id : provider.name,
        content: Text(provider.url),
        actions: [
          GlassDialogAction(
            label: t.common.cancel,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          GlassDialogAction(
            label: isRestore
                ? t.settings.signatureRestoreDefault
                : t.common.delete,
            destructive: !isRestore,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final next = _service.customProviders
        .where((e) => e.id != provider.id)
        .toList();
    await _service.saveCustomProviders(next);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final providers = _service.providers;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.settings.signatureSourcesHint,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          // 增删一条时列表是长出来 / 收回去的，不是硬切。
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final provider in providers)
                  _ProviderRow(
                    key: ValueKey(provider.id),
                    provider: provider,
                    // 测过就显示刚取到的；没测过就显示上次发评论时取到的。
                    value:
                        _tested[provider.id] ??
                        _service.lastValueOf(provider.id),
                    error: _failed[provider.id],
                    onTest: () => _test(provider),
                    // 内置源也能编辑：改完存成同名的覆盖，模板不用动。
                    onEdit: () => _edit(existing: provider),
                    // 出厂状态的内置源没什么可删的（删掉等于什么都没发生），
                    // 被改过之后那枚钮才有意义——那时它是「恢复默认」。
                    onDelete: provider.builtin ? null : () => _delete(provider),
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
                    label: t.settings.signatureAddSource,
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

class _ProviderRow extends StatelessWidget {
  const _ProviderRow({
    super.key,
    required this.provider,
    required this.value,
    required this.error,
    required this.onTest,
    required this.onEdit,
    required this.onDelete,
  });

  final SignatureProvider provider;

  /// 这个源最近给出的那句话（刚测的，或上次发评论时取到的）。
  final String? value;
  final String? error;

  final Future<void> Function() onTest;

  final VoidCallback onEdit;

  /// 出厂状态的内置源没有这枚钮（见 `SignatureProvidersBody`）。
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final t = slang.Translations.of(context);
    final cs = Theme.of(context).colorScheme;
    final subtitle = error ?? value;
    final options = SignatureVariableLabels.optionSummary(t, provider);
    final builtinSlot = SignatureService.isBuiltinSlot(provider.id);

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
                              SignatureVariableLabels.providerName(t, provider),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (builtinSlot) ...[
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
                                t.settings.signatureBuiltinSource,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: cs.onSecondaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      // 模板里怎么引用它。这一行是这张列表存在的主要理由。
                      // 选项摘要跟在后面：同一个一言接两条时，这是唯一的区别。
                      Row(
                        children: [
                          Text(
                            '{${provider.id}}',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: cs.primary,
                            ),
                          ),
                          if (options.isNotEmpty)
                            Flexible(
                              child: Text(
                                '  $options',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (subtitle != null && subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.3,
                            color: error != null
                                ? cs.error
                                : cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                GlassAsyncIconButton(
                  icon: const Icon(Icons.play_arrow_outlined),
                  tooltip: t.settings.signatureSourceTest,
                  standalone: true,
                  onPressed: onTest,
                ),
                if (onDelete != null)
                  GlassIconButton(
                    icon: const Icon(Icons.delete_outline),
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
